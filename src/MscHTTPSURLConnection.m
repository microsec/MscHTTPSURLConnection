//
//  MscHTTPSURLConnection.m
//  MscHTTPSURLConnection
//
//  Created by Lendvai Richárd on 2014.10.27..
//  Copyright (c) 2014 Lendvai Richárd. All rights reserved.
//

#import "MscHTTPSURLConnection.h"
#import "MscHTTPSValidatorDelegate.h"
#import "MscHTTPSURLConnectionLocalException.h"

#import "MscX509Common/MscPKCS12.h"
#import "MscX509Common/MscX509CommonError.h"
#import "MscX509Common/MscCertificate.h"

@implementation MscHTTPSURLConnection {
    @private
    NSCondition* _condition;
    BOOL _connectionDidFinishLoading;
    NSURLConnection* _connection;
    id<MscHTTPSValidatorDelegate> _validatorDelegate;
    MscPKCS12* _identity;
    NSString* _identityPassword;
    NSHTTPURLResponse* _response;
    NSMutableData* _data;
    NSError* _error;
    MscHTTPSURLConnectionDataCompletionHandler _completionhandler;
}

-(void)sendAsynchronousRequest:(NSURLRequest*)request identity:(MscPKCS12*)identity identityPassword:(NSString*)identityPassword validatorDelegate:(id<MscHTTPSValidatorDelegate>)validatorDelegate completionHandler:(MscHTTPSURLConnectionDataCompletionHandler)completionhandler {
    
    _completionhandler = completionhandler;
    _validatorDelegate = validatorDelegate;
    _identity = identity;
    _identityPassword = identityPassword;
    
    NSLog(@"connection started to: %@", request.URL);
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    NSString *authMethod = [protectionSpace authenticationMethod];
    
    if(authMethod == NSURLAuthenticationMethodServerTrust) {
        
        SecTrustRef trustRef = [protectionSpace serverTrust];
        SecTrustEvaluate(trustRef, NULL);
        
        CFIndex certificateCount = SecTrustGetCertificateCount(trustRef);
        NSLog(@"Number of certificates in chain: %ld", certificateCount);
        NSMutableArray* certificates = [NSMutableArray arrayWithCapacity:certificateCount];
        
        for (signed long i = 0; i < certificateCount; i++) {
            
            SecCertificateRef certRef = SecTrustGetCertificateAtIndex(trustRef, i);
            NSData* certData = (__bridge NSData*)SecCertificateCopyData(certRef);
            
            MscX509CommonError* localError;
            MscCertificate* certificate = [[MscCertificate alloc] initWithData:certData error:&localError];
            
            if (localError) {
                NSLog(@"Failed to read server certificate, error: %@", localError);
                [[challenge sender] cancelAuthenticationChallenge:challenge];
                break;
            }
            else {
                [certificates addObject:certificate];
            }
        }
        
        if (_validatorDelegate && [_validatorDelegate respondsToSelector:@selector(isValidServerCertificateChain:)]) {
            if ([_validatorDelegate isValidServerCertificateChain:certificates]) {
                NSLog(@"server certificate is trusted");
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
            else {
                NSLog(@"server certificate is not trusted, connection cancelled");
                [[challenge sender] cancelAuthenticationChallenge:challenge];
            }
        }
        else {
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
    else if(authMethod == NSURLAuthenticationMethodClientCertificate) {
        
        if (!_identity) {
            NSLog(@"identity is not present, connection cancelled");
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
        else {
            NSURLCredential *newCredential = [NSURLCredential credentialWithIdentity:[self getIdentity] certificates:nil persistence:NSURLCredentialPersistenceNone];
            [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        }
    }
}

-(SecIdentityRef)getIdentity {
    
    CFDataRef inPKCS12Data = (__bridge CFDataRef)[_identity data];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    CFStringRef password = (__bridge CFStringRef)_identityPassword;
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    
    CFRelease(options);
    
    if(securityError == errSecSuccess) {
        
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        return (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        
    } else {
        
        return nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _response = (NSHTTPURLResponse*)response;
    NSLog(@"connection finished, http: %d", (int)[_response statusCode]);
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"returned data in UTF8: %@", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding]);
    _completionhandler(_response, _data, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    _completionhandler(_response, nil, [MscHTTPSURLConnectionError errorWithCode:error.code]);
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    if ([protectionSpace authenticationMethod] == NSURLAuthenticationMethodServerTrust) {
        return YES;
    }
    else if ([protectionSpace authenticationMethod] == NSURLAuthenticationMethodClientCertificate && _identity) {
        return YES;
    }
    return NO;
}

-(void)cancelConnection {
    
    [_connection cancel];
}

@end

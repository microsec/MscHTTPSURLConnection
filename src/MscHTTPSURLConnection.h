//
//  MscHTTPSURLConnection.h
//  MscHTTPSURLConnection
//
//  Created by Lendvai Richárd on 2014.10.27..
//  Copyright (c) 2014 Lendvai Richárd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MscHTTPSURLConnectionError.h"
#import "MscHTTPSValidatorDelegate.h"
#import "MscX509Common/MscPKCS12.h"

@interface MscHTTPSURLConnection : NSObject

typedef void (^MscHTTPSURLConnectionDataCompletionHandler)(NSHTTPURLResponse*, NSData*, MscHTTPSURLConnectionError*);

-(void)sendAsynchronousRequest:(NSURLRequest*)request identity:(MscPKCS12*)identity identityPassword:(NSString*)identityPassword validatorDelegate:(id<MscHTTPSValidatorDelegate>)validatorDelegate completionHandler:(MscHTTPSURLConnectionDataCompletionHandler)completionhandler;

-(void)cancelConnection;

@end

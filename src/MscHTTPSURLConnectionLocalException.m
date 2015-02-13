//
//  MscHTTPSURLConnectionLocalException.m
//  MscHTTPSURLConnection
//
//  Created by Lendvai Richárd on 2014.10.30..
//  Copyright (c) 2014 Lendvai Richárd. All rights reserved.
//

#import "MscHTTPSURLConnectionLocalException.h"

@implementation MscHTTPSURLConnectionLocalException

@synthesize errorCode = _errorCode;

-(id)initWithErrorCode:(NSUInteger)errorCode {
    
    self = [super initWithName:@"MscHTTPSURLConnectionLocalException" reason:nil userInfo:nil];
    if (self) {
        
        _errorCode = errorCode;
    }
    return self;
}

+(id)exceptionWithCode:(NSUInteger)code {
    
    return [[MscHTTPSURLConnectionLocalException alloc] initWithErrorCode:code];
}

@end

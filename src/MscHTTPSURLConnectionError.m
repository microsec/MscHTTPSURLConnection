//
//  MscHTTPSURLConnectionError.m
//  MscHTTPSURLConnection
//
//  Created by Lendvai Richárd on 2014.10.30..
//  Copyright (c) 2014 Lendvai Richárd. All rights reserved.
//

#import "MscHTTPSURLConnectionError.h"

@implementation MscHTTPSURLConnectionError

+(id)errorWithCode:(NSInteger)code {
    
    return [MscHTTPSURLConnectionError errorWithDomain:@"hu.microsec.httpsurlconnection" code:code userInfo:nil];
}

@end

//
//  MscHTTPSURLConnectionLocalException.h
//  MscHTTPSURLConnection
//
//  Created by Lendvai Richárd on 2014.10.30..
//  Copyright (c) 2014 Lendvai Richárd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MscHTTPSURLConnectionLocalException : NSException

@property(readonly) NSUInteger errorCode;

+(id)exceptionWithCode:(NSUInteger)code;

@end

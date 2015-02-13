//
//  MscHTTPSValidatorDelegate.h
//  MscHTTPSURLConnection
//
//  Created by Lendvai Richárd on 2014.10.27..
//  Copyright (c) 2014 Lendvai Richárd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MscHTTPSValidatorDelegate <NSObject>

-(BOOL)isValidServerCertificateChain:(NSArray*)chain;

@end

//
//  ProcessEnvironment.h
//  AnyBar
//
//  Created by Nikita Prokopov on 03/03/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProcessEnvironment : NSObject

+(BOOL) variableExists:(NSString*) envVariable;
+(int) readInt:(NSString*)envVariable usingDefault:(int) defValue;
+(NSString*) readStr:(NSString*)envVariable usingDefault:(NSString*) defValue;

@end

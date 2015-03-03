//
//  ProcessEnvironment.m
//  AnyBar
//
//  Created by Nikita Prokopov on 03/03/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import "ProcessEnvironment.h"

@implementation ProcessEnvironment

+(BOOL) variableExists:(NSString*)envVariable {
    NSString *envStr = [self readStr: envVariable usingDefault: nil];
    
    return envStr != nil;
}

+(int) readInt:(NSString*)envVariable usingDefault:(int) defValue {
    int intVal = defValue;
    
    NSString *envStr = [self readStr: envVariable usingDefault: nil];
    
    if (envStr) {
        NSNumberFormatter *nFormatter = [[NSNumberFormatter alloc] init];
        nFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *number = [nFormatter numberFromString:envStr];
    
        if (!number) {
            @throw([NSException exceptionWithName:@"Argument Exception"
                                        reason:[NSString stringWithFormat:@"Parsing integer from %@ failed", envStr]
                                        userInfo:@{@"argument": envStr}]);
        
        }
    
        intVal = [number intValue];
    }
    
    return intVal;
}

+(NSString*) readStr:(NSString*)envVariable usingDefault:(NSString*) defValue {
    NSString *envStr = [[[NSProcessInfo processInfo]
                         environment] objectForKey:envVariable];
    if (!envStr) {
        return defValue;
    }
    
    return envStr;
}

@end

//
//  AnyBarApp.h
//  AnyBar
//
//  Created by Nikita Prokopov on 04/03/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import "AnyBarApp.h"

@implementation AnyBarApp

-(id) osaImage {
    AppDelegate *delegate = (AppDelegate*)self.delegate;
    return [delegate osaImageBridge];
}

-(void) setOsaImage:(id)imgName {
    AppDelegate *delegate = (AppDelegate*)self.delegate;
    [delegate setOsaImageBridge:imgName];
}

@end

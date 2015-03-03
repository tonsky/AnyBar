//
//  AppDelegate.h
//  AnyBar
//
//  Created by Nikita Prokopov on 14/02/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UdpServer.h"
#import "ProcessEnvironment.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, UdpServerDelegate>

@end

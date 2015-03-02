//
//  AppDelegate.m
//  AnyBar
//
//  Created by Nikita Prokopov on 14/02/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property GCDAsyncUdpSocket *udpSocket;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"white@2x.png"];
    _statusItem.alternateImage = [NSImage imageNamed:@"alternate@2x.png"];
    _statusItem.highlightMode = YES;
    
    NSString *portStr = [[[NSProcessInfo processInfo] environment] objectForKey:@"ANYBAR_PORT"];
    if (!portStr) {
        portStr = @"1738";
    }
    int port = [portStr intValue];
    
    NSMenu *menu = [[NSMenu alloc] init];
    NSString *portTitle = [@"UDP port " stringByAppendingString:portStr];
    [menu addItemWithTitle:portTitle action:nil keyEquivalent:@""];
    [menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
    _statusItem.menu = menu;
    
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil; //maybe we should check this error
    [_udpSocket bindToPort:port error:&error];
    [_udpSocket beginReceiving:&error];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([msg isEqualToString:@"quit"]) {
        [[NSApplication sharedApplication] terminate:nil];
    } else {
        NSString *fileName = [msg stringByAppendingString:@"@2x"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *bundledFile = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:fileName, msg]
                                                                ofType:@"png"];
        
        BOOL fileExistsInBundle = [fileManager fileExistsAtPath:bundledFile];
        if (fileExistsInBundle) {
            _statusItem.image = [[NSImage alloc] initWithContentsOfFile:bundledFile];
        } else {
            // let's lookup for the file in ~/.AnyBar
            NSString *fallbackFile = [NSString stringWithFormat:@"%@/.AnyBar/%@.png", NSHomeDirectory(), fileName];
            BOOL fallbackFileExists = [fileManager fileExistsAtPath:fallbackFile];
            if (fallbackFileExists) {
                _statusItem.image = [[NSImage alloc] initWithContentsOfFile:fallbackFile];
            } else {
                // Logging to Console.app
                NSLog(@"No image for the command %@ found", msg);
            }
        }
    }
}


@end

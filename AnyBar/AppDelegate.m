//
//  AppDelegate.m
//  AnyBar
//
//  Created by Nikita Prokopov on 14/02/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import "AppDelegate.h"

static NSString* const AppConfigDirectoryName = @".AnyBar";
static NSString* const PortEnvironmentName = @"ANYBAR_PORT";
static NSString* const DefaultPort = @"1738";
static NSString* const DefaultImageName = @"white@2x.png";
static NSString* const AlternateImageName = @"alternate@2x.png";
static const int UdpPortMin = 0;
static const int UdpPortMax = 65535;

@interface AppDelegate()

@property (weak, nonatomic) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSImage *defaultImage = [NSImage imageNamed:DefaultImageName];
    NSImage *warnImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
    int port = -1;

    self.statusItem = [self initializeStatusBarItem];
    [self updateStatusImage: defaultImage];

    @try {
        port = [self getUdpPort];

        _udpSocket = [self initializeUdpSocket: port];
    }
    @catch(NSException *ex) {
        NSLog(@"Error: %@: %@", ex.name, ex.reason);

        [self updateStatusImage:warnImage];
    }
    @finally {
        NSString *portTitle = [NSString stringWithFormat:@"UDP port: %@",
                               port >= 0 ? [NSNumber numberWithInt:port] : @"unavailable"];
        NSString *quitTitle = @"Quit";
        _statusItem.menu = [self initializeStatusBarMenu:@{
                                                           portTitle: [NSValue valueWithPointer:nil],
                                                           quitTitle: [NSValue valueWithPointer:@selector(terminate:)]
                                                           }];
    }
}

-(void)applicationWillTerminate:(NSNotification *)aNotification {
    [self shutdownUdpSocket: _udpSocket];
    _udpSocket = nil;

    [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
    _statusItem = nil;
}

-(int) getUdpPort {
    int port = [self readIntFromEnvironmentVariable:PortEnvironmentName usingDefault:DefaultPort];

    if (port < UdpPortMin || port > UdpPortMax) {
        @throw([NSException exceptionWithName:@"Argument Exception"
                            reason:[NSString stringWithFormat:@"UDP Port range is invalid: %d", port]
                            userInfo:@{@"argument": [NSNumber numberWithInt:port]}]);

    }

    return port;
}

-(GCDAsyncUdpSocket*)initializeUdpSocket:(int)port {
    NSError *error = nil;
    GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc]
                                    initWithDelegate:self
                                    delegateQueue:dispatch_get_main_queue()];

    [udpSocket bindToPort:port error:&error];
    if (error) {
        @throw([NSException exceptionWithName:@"UDP Exception"
                            reason:[NSString stringWithFormat:@"Binding to %d failed", port]
                            userInfo:@{@"error": error}]);
    }

    [udpSocket beginReceiving:&error];
    if (error) {
        @throw([NSException exceptionWithName:@"UDP Exception"
                            reason:[NSString stringWithFormat:@"Receiving from %d failed", port]
                            userInfo:@{@"error": error}]);
    }

    return udpSocket;
}

-(void)shutdownUdpSocket:(GCDAsyncUdpSocket*)sock {
    if (sock != nil) {
        [sock close];
    }
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    [self processUdpSocketMsg:sock withData:data fromAddress:address];
}

-(void)processUdpSocketMsg:(GCDAsyncUdpSocket *)sock withData:(NSData *)data
    fromAddress:(NSData *)address {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if ([msg isEqualToString:@"quit"]) {
        [[NSApplication sharedApplication] terminate:nil];
    }
    else {
        NSImage *image = nil;
        NSString *fileName = [msg stringByAppendingString:@"@2x"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *bundledFile = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:fileName, msg]
                                                                ofType:@"png"];

        BOOL fileExists = [fileManager fileExistsAtPath:bundledFile];
        if (fileExists) {
            image = [[NSImage alloc] initWithContentsOfFile:bundledFile];
        }
        else {
            // Let's lookup for the file in ~/.AnyBar
            NSString *fallbackFile = [NSString stringWithFormat:@"%@/%@/%@.png",
                                      NSHomeDirectory(), AppConfigDirectoryName, fileName];
            fileExists = [fileManager fileExistsAtPath:fallbackFile];
            if (fileExists) {
                image = [[NSImage alloc] initWithContentsOfFile:fallbackFile];
            }
        }

        if (fileExists && image != nil) {
            [self updateStatusImage: image];
        }
        else {
            NSLog(@"No image for the command %@ found", msg);
        }
    }
}

-(NSStatusItem*) initializeStatusBarItem {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.alternateImage = [NSImage imageNamed:AlternateImageName];
    statusItem.highlightMode = YES;
    return statusItem;
}

-(NSMenu*) initializeStatusBarMenu:(NSDictionary*)menuDictionary {
    NSMenu *menu = [[NSMenu alloc] init];

    [menuDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSValue* val, BOOL *stop) {
        SEL action = nil;
        [val getValue:&action];
        [menu addItemWithTitle:key action:action keyEquivalent:@""];
    }];

    return menu;
}

-(void) updateStatusImage:(NSImage*) image {
    _statusItem.image = image;
}

-(int) readIntFromEnvironmentVariable:(NSString*) envVariable usingDefault:(NSString*) defStr {
    int intVal = -1;

    NSString *envStr = [[[NSProcessInfo processInfo]
                         environment] objectForKey:envVariable];
    if (!envStr) {
        envStr = defStr;
    }

    NSNumberFormatter *nFormatter = [[NSNumberFormatter alloc] init];
    nFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [nFormatter numberFromString:envStr];

    if (!number) {
        @throw([NSException exceptionWithName:@"Argument Exception"
                            reason:[NSString stringWithFormat:@"Parsing integer from %@ failed", envStr]
                            userInfo:@{@"argument": envStr}]);

    }

    intVal = [number intValue];

    return intVal;
}

@end


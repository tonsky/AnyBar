//
//  AppDelegate.m
//  AnyBar
//
//  Created by Nikita Prokopov on 14/02/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()

@property (weak, nonatomic) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSString *imageName;
@property (assign, nonatomic) BOOL dark;
@property (assign, nonatomic) int udpPort;

@end

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _udpPort = -1;
    _imageName = @"white";
    self.statusItem = [self initializeStatusBarItem];
    [self refreshDarkMode];

    @try {
        _udpPort = [self getUdpPort];
        _udpSocket = [self initializeUdpSocket: _udpPort];
    }
    @catch(NSException *ex) {
        NSLog(@"Error: %@: %@", ex.name, ex.reason);
        _statusItem.image = [NSImage imageNamed:@"exclamation@2x.png"];
    }
    @finally {
        NSString *portTitle = [NSString stringWithFormat:@"UDP port: %@",
                               _udpPort >= 0 ? [NSNumber numberWithInt:_udpPort] : @"unavailable"];
        NSString *quitTitle = @"Quit";
        _statusItem.menu = [self initializeStatusBarMenu:@{
                                                           portTitle: [NSValue valueWithPointer:nil],
                                                           quitTitle: [NSValue valueWithPointer:@selector(terminate:)]
                                                           }];
    }

    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(refreshDarkMode)
                   name: @"AppleInterfaceThemeChangedNotification"
                 object: nil];
}

-(void)applicationWillTerminate:(NSNotification *)aNotification {
    [self shutdownUdpSocket: _udpSocket];
    _udpSocket = nil;

    [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
    _statusItem = nil;
}

-(int) getUdpPort {
    int port = [self readIntFromEnvironmentVariable:@"ANYBAR_PORT" usingDefault:@"1738"];

    if (port < 0 || port > 65535) {
        @throw([NSException exceptionWithName:@"Argument Exception"
                            reason:[NSString stringWithFormat:@"UDP Port range is invalid: %d", port]
                            userInfo:@{@"argument": [NSNumber numberWithInt:port]}]);

    }

    return port;
}

- (void)refreshDarkMode {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    if ([osxMode isEqualToString:@"Dark"])
        self.dark = YES;
    else
        self.dark = NO;
    [self setImage:_imageName];
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

-(NSImage*)tryImage:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
        return [[NSImage alloc] initWithContentsOfFile:path];
    else
        return nil;
}

-(NSString*)bundledImagePath:(NSString *)name {
    return [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
}

-(NSString*)homedirImagePath:(NSString *)name {
    return [NSString stringWithFormat:@"%@/%@/%@.png", NSHomeDirectory(), @".AnyBar", name];
}

-(void)setImage:(NSString*) name {

    NSImage *image = nil;
    if (_dark)
        image = [self tryImage:[self bundledImagePath:[name stringByAppendingString:@"_alt@2x"]]];
    if (!image)
        image = [self tryImage:[self bundledImagePath:[name stringByAppendingString:@"@2x"]]];
    if (_dark && !image)
        image = [self tryImage:[self homedirImagePath:[name stringByAppendingString:@"_alt"]]];
    if (_dark && !image)
        image = [self tryImage:[self homedirImagePath:[name stringByAppendingString:@"_alt@2x"]]];
    if (!image)
        image = [self tryImage:[self homedirImagePath:[name stringByAppendingString:@"@2x"]]];
    if (!image)
        image = [self tryImage:[self homedirImagePath:name]];
    if (!image) {
        if (_dark)
            image = [self tryImage:[self bundledImagePath:@"question_alt@2x"]];
        else
            image = [self tryImage:[self bundledImagePath:@"question@2x"]];
        NSLog(@"Cannot find image '%@'", name);
    }

    _statusItem.image = image;
    _imageName = name;
}

-(void)processUdpSocketMsg:(GCDAsyncUdpSocket *)sock withData:(NSData *)data
    fromAddress:(NSData *)address {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if ([msg isEqualToString:@"quit"])
        [[NSApplication sharedApplication] terminate:nil];
    else
        [self setImage:msg];
}

-(NSStatusItem*) initializeStatusBarItem {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.alternateImage = [NSImage imageNamed:@"black_alt@2x.png"];
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

-(id) osaImageBridge {
    NSLog(@"OSA Event: %@ - %@", NSStringFromSelector(_cmd), _imageName);

    return _imageName;
}


-(void) setOsaImageBridge:(id)imgName {
    NSLog(@"OSA Event: %@ - %@", NSStringFromSelector(_cmd), imgName);

    _imageName = (NSString *)imgName;

    [self setImage:_imageName];
}

@end


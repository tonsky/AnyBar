//
//  UdpServer.m
//  AnyBar
//
//  Created by Nikita Prokopov on 03/03/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import "UdpServer.h"

@interface UdpServer()

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@end

@implementation UdpServer

-(instancetype) initWithPort:(int)port {
    self = [super init];
    
    if (self) {
        _udpSocket = [self initializeUdpSocket: port];
    }
    
    return self;
}

-(void) dealloc {
    [self shutdownUdpSocket:_udpSocket];
    _delegate = nil;
    _udpSocket = nil;
}

-(GCDAsyncUdpSocket*) initializeUdpSocket:(int)port {
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

-(void) shutdownUdpSocket:(GCDAsyncUdpSocket*)sock {
    if (sock != nil) {
        [sock close];
    }
}

-(void) udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    if (!_delegate) {
        return;
    }
    
    BOOL respondsToProto =
        [_delegate respondsToSelector:@selector(processUdpSocketMsg:withData:fromAddress:)];
    if (!respondsToProto) {
        return;
    }
    
    [_delegate processUdpSocketMsg:sock withData:data fromAddress:address];
}

@end

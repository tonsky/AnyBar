//
//  UdpServer.h
//  AnyBar
//
//  Created by Nikita Prokopov on 03/03/15.
//  Copyright (c) 2015 Nikita Prokopov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@protocol UdpServerDelegate <NSObject>

-(void) processUdpSocketMsg:(GCDAsyncUdpSocket *)sock
                   withData:(NSData *)data
                fromAddress:(NSData *)address;

@end

@interface UdpServer : NSObject

@property (weak, nonatomic) id<UdpServerDelegate> delegate;

-(instancetype) initWithPort:(int)port;

@end

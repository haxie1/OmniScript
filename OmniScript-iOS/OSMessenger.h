//
//  REMessenger.h
//  Reins
//
//  Created by Kam Dahlin on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSMessengerDelegate;

@interface OSMessenger : NSObject
@property(nonatomic, readonly, retain) NSString *serviceName;
@property(nonatomic, readonly) BOOL isRunning;
@property(nonatomic, assign) id <OSMessengerDelegate> delegate;

-(void)publishServiceWithName:(NSString *)name;
-(void)connectToServiceWithName:(NSString *)name;
-(void)stop;
-(void)sendData:(NSData *)data;
@end

@protocol OSMessengerDelegate <NSObject>
@required
-(void)messenger:(OSMessenger *)messenger receivedData:(NSData *)data;

@optional
-(void)messengerPublishedSuccessfully:(OSMessenger *)messenger;
-(void)messenger:(OSMessenger *)messenger failedToPublish:(NSError *)error;
-(void)messenger:(OSMessenger *)messenger sentBytes:(NSNumber *)bytes;
-(void)messengerDidConnectSuccessfully:(OSMessenger *)messenger;
-(void)messenger:(OSMessenger *)messenger failedToConnect:(NSError *)error;
@end

//
//  REMessenger.m
//  Reins
//
//  Created by Kam Dahlin on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OSMessenger.h"
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <CFNetwork/CFNetwork.h>
#else
#import <CoreServices/CoreServices.h>
#endif

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@interface OSMessenger () <NSStreamDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate>
@property(nonatomic, readwrite, retain) NSString *serviceName;
@property(nonatomic, readwrite) BOOL isRunning;

// internal
@property(nonatomic, retain) NSNetService *netService;
@property(nonatomic, assign) CFSocketRef listeningSocket;
@property(nonatomic, retain) NSInputStream *inputStream;
@property(nonatomic, retain) NSOutputStream *outputStream;
@property(nonatomic, retain) NSMutableData *readData;
@property(nonatomic, retain) NSNetServiceBrowser *serviceBrowser;

-(OSStatus)_setupSocket;
-(void)_publishNetServiceOnPort:(int)port;
-(NSError *)_errorWithNetServiceErrorDictionary:(NSDictionary *)errorDict;
@end

static NSString *OS_MESSENGER_SERVICE_TYPE = @"_os-messenger._tcp.";

@implementation OSMessenger
@synthesize serviceName = _serviceName;
@synthesize isRunning;
@synthesize delegate = _delegate;
// internal
@synthesize netService = _netService;
@synthesize listeningSocket = _listeningSocket;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize readData = _readData;
@synthesize serviceBrowser = _serviceBrowser;

-(void)dealloc
{
    [self stop];
    [_serviceName release];
    [_netService release];
    [_outputStream release];
    [_inputStream release];
    [_readData release];
    [_serviceBrowser release];
    
    [super dealloc];
}

#pragma mark - API
-(void)publishServiceWithName:(NSString *)name
{
    self.serviceName = name;
    if([self _setupSocket] != noErr) {
        [self stop];
    }
}

-(void)stop
{
    [self.netService stop];
    [self.serviceBrowser stop];
    [self.inputStream close];
    [self.outputStream close];
    self.isRunning = NO;
}

-(void)connectToServiceWithName:(NSString *)name
{
    if(! name) {
        [[NSException exceptionWithName:NSInvalidArgumentException 
                                 reason:@"name can't be nil" 
                               userInfo:nil] raise];
    }
    
    self.serviceName = name;
    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser searchForServicesOfType:OS_MESSENGER_SERVICE_TYPE inDomain:@""];
}

-(void)sendData:(NSData *)data
{
    assert(data);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger bytesSent = [self.outputStream write:[data bytes] maxLength:[data length]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSNumber *bytes = [NSNumber numberWithLong:bytesSent];
            [self.delegate messenger:self sentBytes:bytes];
        });
    });
}

#pragma mark - Accessors
-(void)setInputStream:(NSInputStream *)inputStream
{
    if(inputStream != _inputStream) {
        [inputStream retain];
        [_inputStream release];
        _inputStream = inputStream;
        
        _inputStream.delegate = self;
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream open];
    }
}

-(void)setOutputStream:(NSOutputStream *)outputStream
{
    if(outputStream != _outputStream) {
        [outputStream retain];
        [_outputStream release];
        _outputStream = outputStream;
        
        [_outputStream open];
    }
}

#pragma mark - internal
static void acceptCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    int socket = *(int *)data;
    OSMessenger *me = (OSMessenger *)info;
    
    CFWriteStreamRef writeStream;
    CFReadStreamRef readStream;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, socket, &readStream, &writeStream);
    
    me.inputStream = (NSInputStream *)NSMakeCollectable(readStream);
    me.outputStream = (NSOutputStream *)NSMakeCollectable(writeStream);
    
    CFRelease(writeStream);
    CFRelease(readStream);
    
}

-(OSStatus)_setupSocket
{
    NSLog(@"setupSocket");
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    int yes = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
    
    struct sockaddr_in sockaddr;
    memset(&sockaddr, 0, sizeof(sockaddr));
    
    sockaddr.sin_len = sizeof(sockaddr);
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_port = 0;
    sockaddr.sin_addr.s_addr = INADDR_ANY;
    
    if(bind(fd, (const struct sockaddr *)&sockaddr, sizeof(sockaddr)) != noErr) {
        close(fd);
        OSStatus err = errno;
        return err;
    }
    
    if(listen(fd, 1) != noErr) {
        close(fd);
        OSStatus err = errno;
        return err;
        
    }
    
    socklen_t addrLen = sizeof(sockaddr);
    if(getsockname(fd, (struct sockaddr *)&sockaddr, &addrLen) != noErr) {
        close(fd);
        OSStatus err = errno;
        return err;
    }
    
    int port = htons(sockaddr.sin_port);
    
    CFSocketContext context = {0, self, NULL, NULL, NULL};
    CFSocketRef socket = CFSocketCreateWithNative(kCFAllocatorDefault, 
                                                  fd, 
                                                  kCFSocketAcceptCallBack, 
                                                  acceptCallback, &context);
    assert(socket);
    
    self.listeningSocket = socket;
    //fd = -1; // socket will close
    CFRunLoopSourceRef runLoopSource = NULL;
    runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
    CFRelease(runLoopSource);
    CFRelease(socket);
    
    [self _publishNetServiceOnPort:port];
    
    return noErr;

}

-(void)_publishNetServiceOnPort:(int)port
{
    self.netService = [[[NSNetService alloc] initWithDomain:@"local." 
                                                       type:OS_MESSENGER_SERVICE_TYPE 
                                                       name:self.serviceName 
                                                       port:port] autorelease];
    self.netService.delegate = self;
    [self.netService publish];
}

-(NSError *)_errorWithNetServiceErrorDictionary:(NSDictionary *)errorDict
{
    return [NSError errorWithDomain:[errorDict objectForKey:NSNetServicesErrorDomain] 
                                code:[[errorDict objectForKey:NSNetServicesErrorCode] intValue]
                            userInfo:nil];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"open completed");
            break;
            
        case NSStreamEventHasBytesAvailable:
            NSLog(@"got a bytes available event");
            if(! self.readData) {
                self.readData = [NSMutableData data];
            }
            
            uint8_t bytes[1024];
            NSInteger length = 0;
            
            while([(NSInputStream *)aStream hasBytesAvailable]) {
                length = [(NSInputStream *)aStream read:bytes maxLength:1024];
                if(length > 0) {
                  [self.readData appendBytes:&bytes length:length];  
                }
            }
            
            //NSLog(@"read length: %ld", length);
            if(length < 0) {
                // some kind of error
                //TODO: how to handle this case? 
            } else {
                if([self.readData length] > 0) 
                    [self.delegate messenger:self receivedData:self.readData];
                self.readData = nil;
            }

            break;
        case NSStreamEventEndEncountered:
            NSLog(@"stream event end");
            [self stop];
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"stream event error");
            [self stop];
            break;
        default:
            break;
    }
}

#pragma mark - NSNetServiceDelegate - Publishing
- (void)netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@"published service: %@ on port: %d", sender.name, ntohs(sender.port));
    self.isRunning = YES;
    [self.delegate messengerPublishedSuccessfully:self];
}

-(void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
    NSError *error = [self _errorWithNetServiceErrorDictionary:errorDict];
    [self.delegate messenger:self failedToPublish:error];
    [self stop];
}

- (void)netServiceDidStop:(NSNetService *)sender
{
    NSLog(@"stopped service: %@", sender);
}

#pragma mark - NSNetServiceDelegate - Resolving
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSInputStream *inStream = nil;
    NSOutputStream *outStream = nil;
    
    if([sender getInputStream:&inStream outputStream:&outStream]) {
        NSLog(@"got streams");
        self.inputStream = inStream;
        self.outputStream = outStream;
        
        [self.delegate messengerDidConnectSuccessfully:self];
        
    } else {
        NSError *error = [NSError errorWithDomain:@"NSNetService failed to get connection streams" 
                                             code:-100 //holy made up error code batman
                                         userInfo:nil];
                                         
        [self.delegate messenger:self failedToConnect:error];
    }
    
    [self.serviceBrowser stop];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSError *error = [self _errorWithNetServiceErrorDictionary:errorDict];
    [self.delegate messenger:self failedToConnect:error];
}


#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    NSLog(@"found a service");
    if([aNetService.name isEqualToString:self.serviceName]) {
        self.netService = aNetService;
        self.netService.delegate = self;
        [self.netService resolveWithTimeout:30];
    }
    
    if(! moreComing) {
        NSLog(@"no more services coming");
        [self.serviceBrowser stop];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
    NSLog(@"service browser stopped");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"failed to search because: %@", errorDict);
    NSError *error = [self _errorWithNetServiceErrorDictionary:errorDict];
    [self.delegate messenger:self failedToConnect:error];
}


@end

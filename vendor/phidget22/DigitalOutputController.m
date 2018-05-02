//
//  DigitalOutputController.m
//  DigitalOutput
//
//  Created by Phidgets on 2015-07-14.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#import "DigitalOutputController.h"

@implementation DigitalOutputController

-(void)start:(int)serialNumber port:(int)hubPort  channel:(int)deviceChannel{
    PhidgetReturnCode result;
    BOOL isHubPort = NO, remote = NO, errorOccurred = NO;
	
    
    result = PhidgetDigitalOutput_create(&ch);
    if(result != EPHIDGET_OK){
    	NSLog(@"error!");
    }
	
    // result = [self initChannel:(PhidgetHandle)ch];
	Phidget_setOnAttachHandler(ch, gotAttach, (__bridge void*)self);
	Phidget_setOnDetachHandler(ch, gotDetach, (__bridge void*)self);
	Phidget_setOnErrorHandler(ch, gotError, (__bridge void*)self);
	
    NSLog(@"result is %u", result);
    
    int i = 0;
    
    Phidget_setChannel(ch, (int)deviceChannel);
    Phidget_setDeviceSerialNumber(ch,serialNumber == 0 ? -1 : (int)serialNumber);
    Phidget_setHubPort(ch, (int)hubPort);
   	Phidget_setIsHubPortDevice(ch, isHubPort);
    Phidget_setIsLocal(ch, 1);
	
    result = Phidget_open(ch);
    if(result != EPHIDGET_OK){
    	NSLog(@"error opening phidget!");
    }
}

#pragma mark Event callbacks

static void gotAttach(PhidgetHandle phid, void *context){
   	NSLog(@"got attach %u", phid);
    [(__bridge id)context performSelectorOnMainThread:@selector(onAttachHandler)
                                           withObject:nil
                                        waitUntilDone:NO];
}

static void gotDetach(PhidgetHandle phid, void *context){
    NSLog(@"got detach");
    [(__bridge id)context performSelectorOnMainThread:@selector(onDetachHandler)
                                           withObject:nil
                                        waitUntilDone:NO];
}

static void gotError(PhidgetHandle phid, void *context, Phidget_ErrorEventCode errcode, const char *error){
    [(__bridge id)context performSelectorOnMainThread:@selector(errorHandler:)
                                           withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:errcode], [NSString stringWithUTF8String:error], nil]
                                        waitUntilDone:NO];
}

#pragma mark Attach, detach, and error events
- (void)onAttachHandler{
    PhidgetReturnCode result;
    Phidget_DeviceID deviceID;
    Phidget_ChannelSubclass channelSubclass;
    int outputState;
    
    //Get information from channel which will allow us to configure the GUI properly
    result = Phidget_getDeviceID((PhidgetHandle)ch, &deviceID);
    if(result != EPHIDGET_OK){
        NSLog(@"%u", result);
    }
    result = Phidget_getChannelSubclass((PhidgetHandle)ch, &channelSubclass);
    if(result != EPHIDGET_OK){
        NSLog(@"%u", result);
    }
    result = PhidgetDigitalOutput_getState(ch, &outputState);
    if(result != EPHIDGET_OK){
        NSLog(@"%u", result);
    }
		
	NSDictionary *attachData = [[NSDictionary alloc] initWithObjectsAndKeys: 
							[NSNumber numberWithInt:deviceID],
							@"deviceID", 
							[NSNumber numberWithInt:channelSubclass],
							@"channelSubclass",
							[NSNumber numberWithInt:outputState],
							@"outputState",
							nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"attach_notification_from_phidget" object:nil userInfo:attachData];
    
}

- (void)onDetachHandler{
    NSLog(@"on detatch handler");
}

-(void)errorHandler:(NSArray *)errorEventData{
    const char* errorString = [[errorEventData objectAtIndex:1] UTF8String];
    NSLog(@"error is: %s", errorString);
}

-(void)addError:(PhidgetReturnCode)result{
    const char *errorString;
    Phidget_getErrorDescription(result, &errorString);
    NSLog(@"error is: %s", errorString);
}

#pragma mark commands
- (void)setDutyCycle:(double)value{
    PhidgetDigitalOutput_setDutyCycle(ch, value);
}

- (void)setCurrentLimit:(double)value{
    PhidgetDigitalOutput_setLEDCurrentLimit(ch, value);
}

- (void)setState:(double)value{
    PhidgetDigitalOutput_setState(ch, value);
}

- (void)setOnOff{
    PhidgetReturnCode result;
    int state;
    result = PhidgetDigitalOutput_getState(ch, &state);
    if(result != EPHIDGET_OK){
        [self addError:result];
        return;
    }
    result = PhidgetDigitalOutput_setState(ch, (state == 0) ? 1 : 0);
    if(result != EPHIDGET_OK){
        [self addError:result];
        return;
    }
    
}

@end

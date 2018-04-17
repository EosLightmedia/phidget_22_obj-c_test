//
//  DigitalOutputController.m
//  DigitalOutput
//
//  Created by Phidgets on 2015-07-14.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#import "DigitalOutputController.h"

@implementation DigitalOutputController

-(PhidgetHandle)start{
    PhidgetReturnCode result;
    
    result = PhidgetDigitalOutput_create(&ch);
    if(result != EPHIDGET_OK){
        [self addError:result];
    }
    return result;
    // result = [self initChannel:(PhidgetHandle)ch];
//     NSLog(@"result is %u", result);
//     if(result != EPHIDGET_OK){
//         NSLog(@"ERROR! %u", result);
//         [self addError:result];
//     }
//     NSLog(@"HERE");
}

-(PhidgetReturnCode)initChannel:(PhidgetHandle) channel{
    PhidgetReturnCode result;
	NSLog(@"here");
    
    result = Phidget_setOnAttachHandler(channel, gotAttach, (__bridge void*)self);
    if(result != EPHIDGET_OK){
        return result;
    }
    
    result = Phidget_setOnDetachHandler(channel, gotDetach, (__bridge void*)self);
    if(result != EPHIDGET_OK){
        return result;
    }
    
    result = Phidget_setOnErrorHandler(channel, gotError, (__bridge void*)self);
    if(result != EPHIDGET_OK){
        return result;
    }
    
     Phidget_setDeviceSerialNumber(ch, -1);
     Phidget_setHubPort(ch, 0);
     Phidget_setIsHubPortDevice(ch, 0);
     Phidget_setChannel(ch, 0);
    
	 NSLog(@"Init Channel complete");
    return EPHIDGET_OK;
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
    PhidgetReturnCode result;
    result = PhidgetDigitalOutput_setDutyCycle(ch, value);
    if(result != EPHIDGET_OK){
        [self addError:result];
        return;
    }
}
- (void)setCurrentLimit:(double)value{
    PhidgetReturnCode result;
    result = PhidgetDigitalOutput_setLEDCurrentLimit(ch, value);
    if(result != EPHIDGET_OK){
        [self addError:result];
        return;
    }
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

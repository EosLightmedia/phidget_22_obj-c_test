//
//  HelloWorldController.m
//  HelloWorld
//
//  Created by Phidgets on 2015-07-15.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#import "PhiManager.h"

@implementation PhiManager

-(void)start{
    PhidgetReturnCode result;
    
    //Manage GUI
    
    result = PhidgetManager_create(&ch);
    if(result != EPHIDGET_OK){
        [self addError:result];
    }
    
    result = PhidgetManager_setOnAttachHandler(ch, gotAttach, (__bridge void*)self);
    if(result != EPHIDGET_OK){
        [self addError:result];
    }
    
    result = PhidgetManager_setOnDetachHandler(ch, gotDetach, (__bridge void*)self);
    if(result != EPHIDGET_OK){
        [self addError:result];
    }
    
    result = PhidgetManager_open(ch);
    if(result != EPHIDGET_OK){
        [self addError:result];
    }
}


#pragma mark Event callbacks
static void gotAttach(PhidgetManagerHandle ch, void *ctx, PhidgetHandle channel){
    Phidget_retain(channel);
    [(__bridge id)ctx performSelectorOnMainThread:@selector(onAttachHandler:)
                                           withObject:[NSValue valueWithPointer:channel]
                                        waitUntilDone:NO];
}
static void gotDetach(PhidgetManagerHandle ch, void *ctx, PhidgetHandle channel){
    Phidget_retain(channel);
    [(__bridge id)ctx performSelectorOnMainThread:@selector(onDetachHandler:)
                                           withObject:[NSValue valueWithPointer:channel]
                                        waitUntilDone:NO];
}

#pragma mark Attach, detach, data, and error events
// - (void)onAttachHandler:(NSValue *)phid{
//     PhidgetHandle p = (PhidgetHandle)[phid pointerValue];
//     const char* deviceName;
//     int32_t serialNumber, channel;
//
//     Phidget_getDeviceName(p, &deviceName);
//     Phidget_getDeviceSerialNumber(p, &serialNumber);
//     Phidget_getChannel(p, &channel);
//     NSLog(@"Device Name: %@, Serial Number: %d, Channel: %d\n", [NSString stringWithCString:deviceName encoding:NSASCIIStringEncoding],serialNumber,channel);
//
//     Phidget_release(&p);
// }

- (void)onDetachHandler:(NSValue *)phid{
    PhidgetHandle p = (PhidgetHandle)[phid pointerValue];
    const char* deviceName;
    int32_t serialNumber,channel;
    
    Phidget_getDeviceName(p, &deviceName);
    Phidget_getDeviceSerialNumber(p, &serialNumber);
    Phidget_getChannel(p, &channel);
    NSLog(@"Goodbye device %@, Serial Number: %d, Channel: %d\n", [NSString stringWithCString:deviceName encoding:NSASCIIStringEncoding],serialNumber,channel);
    Phidget_release(&p);
}

static int errorCounter = 0;
-(void) outputError:(const char *)errorString{
    errorCounter++;
    // NSAttributedString *outputString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",[NSString stringWithUTF8String:errorString]]];
	NSLog([NSString stringWithFormat:@"%@\n",[NSString stringWithUTF8String:errorString]]);

}

-(void)errorHandler:(NSArray *)errorEventData{
    const char* errorString = [[errorEventData objectAtIndex:1] UTF8String];
    [self outputError:errorString];
}

-(void)addError:(PhidgetReturnCode)result{
    const char *errorString;
    Phidget_getErrorDescription(result, &errorString);
    [self outputError:errorString];
}

@end

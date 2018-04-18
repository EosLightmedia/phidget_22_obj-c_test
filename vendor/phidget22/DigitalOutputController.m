//
//  DigitalOutputController.m
//  DigitalOutput
//
//  Created by Phidgets on 2015-07-14.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#import "DigitalOutputController.h"

@implementation DigitalOutputController

-(void)start{
    PhidgetReturnCode result;
    
    result = PhidgetDigitalOutput_create(&ch);
    if(result != EPHIDGET_OK){
        [self addError:result];
    }
	// [super test_command];
	
    // return result;
    result = [self initChannel:(PhidgetHandle)ch];
    NSLog(@"result is %u", result);
    if(result != EPHIDGET_OK){
        NSLog(@"ERROR! %u", result);
        [self addError:result];
    }
    NSLog(@"HERE");
    [self openCmdLine:(PhidgetHandle)ch];
	// return result;
	
}

-(void)openCmdLine:(PhidgetHandle)phid{
    BOOL isHubPort = NO, remote = NO, errorOccurred = NO;
    PhidgetReturnCode result;

    NSArray *args = [[NSProcessInfo processInfo] arguments];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger serialNumber = [standardDefaults integerForKey:@"n"];
    NSString *logfile = [standardDefaults stringForKey:@"l"];
    NSInteger hubPort = [standardDefaults integerForKey:@"v"];
    NSInteger deviceChannel = [standardDefaults integerForKey:@"c"];
    NSString *serverName = [standardDefaults stringForKey:@"s"];
    NSString *password = [standardDefaults stringForKey:@"p"];
    NSString *deviceLabel = [standardDefaults stringForKey:@"L"];
    remote = [standardDefaults boolForKey:@"r"];
    isHubPort = [standardDefaults boolForKey:@"h"];
    
    NSLog(@"HERE2");

    
    int i = 0;
//    for(NSString *arg in args){
//        i++;
//        if([arg isEqualToString:@"n"]){
//            serialNumber = [[args objectAtIndex:i] intValue];
//        }
//        else if([arg isEqualToString:@"l"]){
//            logfile = [args objectAtIndex:i];
//        }
//        else if([arg isEqualToString:@"v"]){
//            hubPort = [[args objectAtIndex:i] intValue];
//        }
//        else if([arg isEqualToString:@"c"]){
//            deviceChannel = [[args objectAtIndex:i] intValue];
//        }
//        else if([arg isEqualToString:@"s"]){
//            serverName = [args objectAtIndex:i];
//        }
//        else if([arg isEqualToString:@"p"]){
//            password = [args objectAtIndex:i];
//        }
//        else if([arg isEqualToString:@"L"]){
//            deviceLabel = [args objectAtIndex:i];
//        }
//        else if([arg isEqualToString:@"r"]){
//            remote = YES;
//        }
//        else if([arg isEqualToString:@"h"]){
//            isHubPort = YES;
//        }
//    }
    
    
//    if(logfile != nil){
//        result = PhidgetLog_enable(PHIDGET_LOG_INFO, [logfile cStringUsingEncoding:NSASCIIStringEncoding]);
//        if(result != EPHIDGET_OK){
////            [PhidgetInfoBox error:result];
//            errorOccurred = YES;
//        }
//    }
//    if(deviceLabel != nil){
//        result = Phidget_setDeviceLabel(phid, [deviceLabel cStringUsingEncoding:NSASCIIStringEncoding]);
//        if(result != EPHIDGET_OK){
////            [PhidgetInfoBox error:result];
//            errorOccurred = YES;
//        }
//    }
    
    if(serverName != nil){
        remote = YES;
        result = Phidget_setServerName(phid, [serverName cStringUsingEncoding:NSASCIIStringEncoding]);
        if(result != EPHIDGET_OK){
//            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
        if(password != nil){
            result = PhidgetNet_setServerPassword([serverName cStringUsingEncoding:NSASCIIStringEncoding], [password cStringUsingEncoding:NSASCIIStringEncoding]);
            if(result != EPHIDGET_OK){
//                [PhidgetInfoBox error:result];
                errorOccurred = YES;
            }
        }
    }
    
    result = Phidget_setChannel(phid, (int)deviceChannel);
    if(result != EPHIDGET_OK){
//        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
    result = Phidget_setDeviceSerialNumber(phid,serialNumber == 0 ? -1 : (int)serialNumber);
    if(result != EPHIDGET_OK){
//        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
    result = Phidget_setHubPort(phid, (int)hubPort);
    if(result != EPHIDGET_OK){
//        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
    result = Phidget_setIsHubPortDevice(phid, isHubPort);
    if(result != EPHIDGET_OK){
//        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
    
    if(remote){
        result = Phidget_setIsRemote(phid, 1); //force open to look for remote devices only
        if(result != EPHIDGET_OK){
//            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
        
        result = PhidgetNet_enableServerDiscovery(PHIDGETSERVER_DEVICEREMOTE);
        if(result != EPHIDGET_OK){
//            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
    }
    else{
        result = Phidget_setIsLocal(phid, 1);
        if(result != EPHIDGET_OK){
//            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
    }
    
    if(errorOccurred){
        NSModalResponse returnValue;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:[NSString stringWithFormat:@"Invaid Command Line Argument\nUsage:\n %@ Flags[...]\n\nFlags:\n-n serialNumber: defaults to -1 (any serial number)\n\n-l logFile: enable logging to specified logFile\n\n-v port: defaults to 0\n\n-c deviceChannel: defaults to 0\n\n-h hubPort?: device is a hub port, defaults to 0\n\n-L deviceLabel, assign a label to the device\n\n-r remote, will autoconnect to available servers, no other configuration is required\n\n-s serverName\tuse only if a specific server is known, otherwise use -r for any server\n\n-p password\tomit for no password",[args objectAtIndex:0]]];
        [alert setAlertStyle:NSAlertStyleCritical];
        returnValue = [alert runModal];
        if(returnValue != NSAlertFirstButtonReturn){
            return;
        }
    }
    else{
        result = Phidget_open(phid);
        if(result != EPHIDGET_OK)
//            [PhidgetInfoBox error:result];
            NSLog(@"error!");
    }
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

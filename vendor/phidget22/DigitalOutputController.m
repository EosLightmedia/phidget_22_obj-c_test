//
//  DigitalOutputController.m
//  DigitalOutput
//
//  Created by Phidgets on 2015-07-14.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#import "DigitalOutputController.h"

#pragma mark Event callbacks

static void gotAttach(PhidgetHandle phid, void *context){
	NSLog(@"got attach");
	
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


@implementation DigitalOutputController

- (PhidgetDigitalOutputHandle) createDigitalOuput:(int)serial
{

	NSLog(@"From C- Attempting to open phidget ID %d\n",serial);
	
	// PhidgetDigitalOutput ch;
	PhidgetDigitalOutput_create(&ch);
	Phidget_open((PhidgetHandle)ch);
	// PhidgetDigitalOutput_create(&ch);
	// Phidget_openWaitForAttachment(ch, 5000);
	return ch;
}

-(PhidgetReturnCode)initChannel:(PhidgetHandle) channel{
    PhidgetReturnCode result;
    
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
    
    /*
     * Please review the Phidget22 channel matching documentation for details on the device
     * and class architecture of Phidget22, and how channels are matched to device features.
     */
    
    /*
     * Specifies the serial number of the device to attach to.
     * For VINT devices, this is the hub serial number.
     *
     * The default is any device.
     */
    // Phidget_setDeviceSerialNumber(ch, <YOUR DEVICE SERIAL NUMBER>);
    
    /*
     * For VINT devices, this specifies the port the VINT device must be plugged into.
     *
     * The default is any port.
     */
    // Phidget_setHubPort(ch, 0);
    
    /*
     * Specifies that the channel should only match a VINT hub port.
     * The only valid channel id is 0.
     *
     * The default is 0 (false), meaning VINT hub ports will never match
     */
    // Phidget_setIsHubPortDevice(ch, 1);
    
    /*
     * Specifies which channel to attach to.  It is important that the channel of
     * the device is the same class as the channel that is being opened.
     *
     * The default is any channel.
     */
    // Phidget_setChannel(ch, 0);
    
    /*
     * In order to attach to a network Phidget, the program must connect to a Phidget22 Network Server.
     * In a normal environment this can be done automatically by enabling server discovery, which
     * will cause the client to discovery and connect to available servers.
     *
     * To force the channel to only match a network Phidget, set remote to 1.
     */
    // PhidgetNet_enableServerDiscovery(PHIDGETSERVER_DEVICEREMOTE);
    // Phidget_setIsRemote(ch, 1);
    
    return EPHIDGET_OK;
}



#pragma mark Attach, detach, and error events
- (void)onAttachHandler{
    PhidgetReturnCode result;
    NSArray *supportedForwardVoltages;
    Phidget_DeviceID deviceID;
    Phidget_ChannelSubclass channelSubclass;
    double maxCurrentLimit, minCurrentLimit, currentLimit, minDutyCycle, maxDutyCycle, dutyCycle;
    PhidgetDigitalOutput_LEDForwardVoltage ledForwardVoltage;
    int outputState;
    
    //Get information from channel which will allow us to configure the GUI properly
    result = Phidget_getDeviceID((PhidgetHandle)ch, &deviceID);
    if(result != EPHIDGET_OK){
        // [self addError:result];
    }
    result = Phidget_getChannelSubclass((PhidgetHandle)ch, &channelSubclass);
    if(result != EPHIDGET_OK){
        // [self addError:result];
    }
    result = PhidgetDigitalOutput_getState(ch, &outputState);
    if(result != EPHIDGET_OK){
        // [self addError:result];
    }
    
    switch(deviceID)
    {
		case PHIDID_1031:
		case PHIDID_1032:
            supportedForwardVoltages = [[NSArray alloc] initWithObjects:@"1.7 V", @"2.75 V", @"3.9 V", @"5.0 V", nil];
            break;
        case PHIDID_LED1000:
            supportedForwardVoltages = [[NSArray alloc] initWithObjects:@"3.2 V",@"4.0 V", @"4.8 V", @"5.6 V", nil];
            break;
        default:
            break;
    }
    
    if(channelSubclass == PHIDCHSUBCLASS_DIGITALOUTPUT_LED_DRIVER){
        //get more information about device
        result = PhidgetDigitalOutput_getMaxLEDCurrentLimit(ch, &maxCurrentLimit);
        if(result != EPHIDGET_OK){
            [self addError:result];
        }
        result = PhidgetDigitalOutput_getMinLEDCurrentLimit(ch, &minCurrentLimit);
        if(result != EPHIDGET_OK){
            [self addError:result];
        }
        result = PhidgetDigitalOutput_getLEDCurrentLimit(ch, &currentLimit);
        if(result != EPHIDGET_OK){
            [self addError:result];
        }
        result = PhidgetDigitalOutput_getLEDForwardVoltage(ch, &ledForwardVoltage);
        if(result != EPHIDGET_OK){
            [self addError:result];
        }
    }
    
    if(channelSubclass == PHIDCHSUBCLASS_DIGITALOUTPUT_DUTY_CYCLE || channelSubclass == PHIDCHSUBCLASS_DIGITALOUTPUT_LED_DRIVER){
        result = PhidgetDigitalOutput_getDutyCycle(ch, &dutyCycle);
        if(result != EPHIDGET_OK){
            [self addError:result];
        }
        result = PhidgetDigitalOutput_getMinDutyCycle(ch, &minDutyCycle);
        if(result != EPHIDGET_OK){
            [self addError:result];
        }
        PhidgetDigitalOutput_getMaxDutyCycle(ch, &maxDutyCycle);
    }
    else{
    }
    
}

- (void)onDetachHandler{
    //Taking items out of view
    //Adjusting window height
}

static int errorCounter = 0;
-(void) outputError:(const char *)errorString{
    errorCounter++;
    NSAttributedString *outputString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",[NSString stringWithUTF8String:errorString]]];
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

- (IBAction)clearErrorLog:(id)send{
    errorCounter = 0;
}

#pragma mark GUI Controls
// - (IBAction)setDutyCycle:(id)sender{
//     PhidgetReturnCode result;
//     result = PhidgetDigitalOutput_setDutyCycle(ch, [dutyCycleSlider doubleValue]);
//     if(result != EPHIDGET_OK){
//         [self addError:result];
//         return;
//     }
//     [dutyCycleLabel setStringValue:[NSString stringWithFormat:@"%0.2f",[dutyCycleSlider doubleValue]]];
// }
// - (IBAction)setCurrentLimit:(id)sender{
//     PhidgetReturnCode result;
//     result = PhidgetDigitalOutput_setLEDCurrentLimit(ch, ([currentLimitSlider doubleValue]));
//     if(result != EPHIDGET_OK){
//         [self addError:result];
//         return;
//     }
//     [currentLimitLabel setStringValue:[NSString stringWithFormat:@"%0.3f A",[currentLimitSlider doubleValue]]];
// }
// - (IBAction)setOnOff:(id)sende{
//     PhidgetReturnCode result;
//     int state;
//     result = PhidgetDigitalOutput_getState(ch, &state);
//     if(result != EPHIDGET_OK){
//         [self addError:result];
//         return;
//     }
//     result = PhidgetDigitalOutput_setState(ch, (state == 0) ? 1 : 0);
//     if(result != EPHIDGET_OK){
//         [self addError:result];
//         return;
//     }
//     if(state){
//         [outputStateButton setTitle:@"ON"];
//         [dutyCycleLabel setStringValue:@"0.00"];
//         [dutyCycleSlider setDoubleValue:[dutyCycleSlider minValue]];
//     }
//     else{
//         [outputStateButton setTitle:@"OFF"];
//         [dutyCycleLabel setStringValue:@"1.00"];
//         [dutyCycleSlider setDoubleValue:[dutyCycleSlider maxValue]];
//     }
//
// }
// - (IBAction)setForwardVoltage:(id)sender{
//     PhidgetReturnCode result = EPHIDGET_OK;
//     if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"1.7 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_1_7V);
//     else if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"2.75 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_2_75V);
//     else if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"3.2 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_3_2V);
//     else if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"3.9 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_3_9V);
//     else if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"4.0 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_4_0V);
//     else if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"4.8 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_4_8V);
//     else if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"5.0 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_5_0V);
//     else if([forwardVoltageCombo.titleOfSelectedItem  isEqual: @"5.6 V"])
//         result = PhidgetDigitalOutput_setLEDForwardVoltage(ch, LED_FORWARD_VOLTAGE_5_6V);
//     if(result != EPHIDGET_OK){
//         [self addError:result];
//     }
// }


@end

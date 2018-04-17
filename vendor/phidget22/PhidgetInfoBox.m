//
//  PhidgetInfoBox.m
//  Accelerometer
//
//  Created by Phidgets Inc on 2015-05-20.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhidgetInfoBox.h"

@implementation PhidgetInfoBox

-(void)fillPhidgetInfo:(PhidgetHandle)device{
    int serialNum,hubPortNum,channelNum,versionNum,isHubPort, isRemote;
    const char *deviceNameText;
    Phidget_DeviceClass deviceClass;
    
    //Clearing box
    if(device == nil){
        [deviceTxt setStringValue:@"Nothing"];
        [versionTxt setStringValue:@""];
        [channelTxt setStringValue:@""];
        [serialNumTxt setStringValue:@""];
        [hubPortTxt setStringValue:@""];
        [pictureBox setImage:nil];
        [hubPortLbl setHidden:YES];
        [remoteLbl setHidden:YES];
        return;
    }
    
    //Get some basic information about the device
    Phidget_getChannel((PhidgetHandle)device, &channelNum);
    [channelTxt setStringValue:[NSString stringWithFormat:@"%d",channelNum]];
    Phidget_getDeviceVersion((PhidgetHandle)device, &versionNum);
    [versionTxt setStringValue:[NSString stringWithFormat:@"%d",versionNum]];
    
    //Change settings based on whether device is VINT or USB
    Phidget_getDeviceClass((PhidgetHandle)device, &deviceClass);
    if(deviceClass == PHIDCLASS_VINT){
        [hubPortTxt setHidden:NO];
        [hubPortLbl setHidden:NO];
        Phidget_getIsHubPortDevice((PhidgetHandle)device, &isHubPort);
        Phidget_getDeviceName((PhidgetHandle)device, &deviceNameText);
        
        [deviceTxt setStringValue:[NSString stringWithFormat:@"%s",deviceNameText]];
        [serialNumLbl setStringValue:@"Hub Serial Number: "];
        Phidget_getDeviceSerialNumber((PhidgetHandle)device, &serialNum);
        [serialNumTxt setStringValue:[NSString stringWithFormat:@"%d",serialNum]];
        Phidget_getHubPort((PhidgetHandle)device, &hubPortNum);
        [hubPortTxt setStringValue:@"Hub Port:"];
        [hubPortTxt setStringValue:[NSString stringWithFormat:@"%d",hubPortNum]];
    }
    else{
        [hubPortTxt setHidden:YES];
        [hubPortLbl setHidden:YES];
        Phidget_getDeviceName((PhidgetHandle)device, &deviceNameText);
        [deviceTxt setStringValue:[NSString stringWithFormat:@"%s",deviceNameText]];
        Phidget_getDeviceSerialNumber((PhidgetHandle)device, &serialNum);
        [serialNumTxt setStringValue:[NSString stringWithFormat:@"%d",serialNum]];
    }
    
    //Set picture
    [self setPicture:device];
    
    Phidget_getIsRemote(device, &isRemote);
    if(isRemote)
        [remoteLbl setHidden:NO];
    else
        [remoteLbl setHidden:YES];
}

- (id)initWithFrame:(NSRect)frame{
    NSString* nibName = NSStringFromClass([self class]);
    self = [super initWithFrame:frame];
    if (self){
        if ([NSBundle loadNibNamed:nibName owner:self]) {
            [self.view setFrame:[self bounds]];
            [self addSubview:self.view];
        }
    }
    return self;
}

- (void)setPicture:(PhidgetHandle)phid{
    int hubDevice;
    Phidget_getIsHubPortDevice(phid, &hubDevice);
    if(hubDevice)
        Phidget_getHub(phid, &phid);
    
    const char *skuCString;
    Phidget_getDeviceSKU(phid, &skuCString);
    
    NSString *sku = [NSString stringWithCString:skuCString encoding:NSASCIIStringEncoding];
    
    // 1018 is a special case because it's so common
    if ([sku rangeOfString:@"1018" ].location != NSNotFound)
        sku = @"1018";
    else
        sku = [[sku componentsSeparatedByString:@"/"] objectAtIndex:0];
	
    NSImage *img = [NSImage imageNamed:[sku stringByAppendingString:@".png"]];
    
    //otherwise the images are just painted over each other - and the transparency causes trouble
    [pictureBox setImage:nil];
    [pictureBox display];
    if(img != nil) {
        NSString *appName = [[NSProcessInfo processInfo] processName];
        if(![appName isEqualToString:@"Phidget Control Panel"])
            [NSApp setApplicationIconImage: img];
        [pictureBox setImage:img];
        [pictureBox display];
    }
}

+(void)openCmdLine:(PhidgetHandle)phid{
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

    int i = 0;
    for(NSString *arg in args){
        i++;
        if([arg isEqualToString:@"n"]){
            serialNumber = [[args objectAtIndex:i] intValue];
        }
        else if([arg isEqualToString:@"l"]){
            logfile = [args objectAtIndex:i];
        }
        else if([arg isEqualToString:@"v"]){
            hubPort = [[args objectAtIndex:i] intValue];
        }
        else if([arg isEqualToString:@"c"]){
            deviceChannel = [[args objectAtIndex:i] intValue];
        }
        else if([arg isEqualToString:@"s"]){
            serverName = [args objectAtIndex:i];
        }
        else if([arg isEqualToString:@"p"]){
            password = [args objectAtIndex:i];
        }
        else if([arg isEqualToString:@"L"]){
            deviceLabel = [args objectAtIndex:i];
        }
        else if([arg isEqualToString:@"r"]){
            remote = YES;
        }
        else if([arg isEqualToString:@"h"]){
            isHubPort = YES;
        }
    }
    
    
    if(logfile != nil){
        result = PhidgetLog_enable(PHIDGET_LOG_INFO, [logfile cStringUsingEncoding:NSASCIIStringEncoding]);
        if(result != EPHIDGET_OK){
            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
    }
    if(deviceLabel != nil){
        result = Phidget_setDeviceLabel(phid, [deviceLabel cStringUsingEncoding:NSASCIIStringEncoding]);
        if(result != EPHIDGET_OK){
            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
    }
    
    if(serverName != nil){
        remote = YES;
        result = Phidget_setServerName(phid, [serverName cStringUsingEncoding:NSASCIIStringEncoding]);
        if(result != EPHIDGET_OK){
            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
        if(password != nil){
            result = PhidgetNet_setServerPassword([serverName cStringUsingEncoding:NSASCIIStringEncoding], [password cStringUsingEncoding:NSASCIIStringEncoding]);
            if(result != EPHIDGET_OK){
                [PhidgetInfoBox error:result];
                errorOccurred = YES;
            }
        }
    }
    
    result = Phidget_setChannel(phid, (int)deviceChannel);
    if(result != EPHIDGET_OK){
        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
    result = Phidget_setDeviceSerialNumber(phid,serialNumber == 0 ? -1 : (int)serialNumber);
    if(result != EPHIDGET_OK){
        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
    result = Phidget_setHubPort(phid, (int)hubPort);
    if(result != EPHIDGET_OK){
        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
    result = Phidget_setIsHubPortDevice(phid, isHubPort);
    if(result != EPHIDGET_OK){
        [PhidgetInfoBox error:result];
        errorOccurred = YES;
    }
    
   
    if(remote){
        result = Phidget_setIsRemote(phid, 1); //force open to look for remote devices only
        if(result != EPHIDGET_OK){
            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
        
        result = PhidgetNet_enableServerDiscovery(PHIDGETSERVER_DEVICEREMOTE);
        if(result != EPHIDGET_OK){
            [PhidgetInfoBox error:result];
            errorOccurred = YES;
        }
    }
    else{
        result = Phidget_setIsLocal(phid, 1);
        if(result != EPHIDGET_OK){
            [PhidgetInfoBox error:result];
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
            [PhidgetInfoBox error:result];
        
    }
}

+(void)error:(PhidgetReturnCode)result{
    const char* errorString;
    Phidget_getErrorDescription(result, &errorString);
    NSModalResponse returnValue;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:[NSString stringWithCString:errorString encoding:NSASCIIStringEncoding]];
    returnValue = [alert runModal];
    if(returnValue != NSAlertFirstButtonReturn){
        return;
    }
}

@end

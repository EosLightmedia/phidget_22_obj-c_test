//
//  PhidgetInfoBox.h
//  Accelerometer
//
//  Created by Phidgets Inc on 2015-05-20.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import </Library/Frameworks/Phidget22.framework/Headers/phidget22.h>

@interface PhidgetInfoBox : NSView{
    IBOutlet NSTextField *deviceTxt;
    IBOutlet NSTextField *versionTxt;
    IBOutlet NSTextField *channelTxt;
    IBOutlet NSTextField *serialNumTxt;
    IBOutlet NSTextField *serialNumLbl;
    IBOutlet NSTextField *hubPortTxt;
    IBOutlet NSTextField *hubPortLbl;
    IBOutlet NSTextField *remoteLbl;
    IBOutlet NSImageView *pictureBox;
}

@property (nonatomic, strong) IBOutlet NSView *view;

-(void)fillPhidgetInfo:(PhidgetHandle)ch;
-(void)setPicture:(PhidgetHandle)phid;

+(void)openCmdLine:(PhidgetHandle)p;

@end

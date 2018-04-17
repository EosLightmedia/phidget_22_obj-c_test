//
//  HelloWorldController.h
//  HelloWorld
//
//  Created by Phidgets on 2015-07-15.
//  Copyright (c) 2015 Phidgets. All rights reserved.
//

#include <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import </Library/Frameworks/Phidget22.framework/Headers/phidget22.h>

@interface PhiManager : NSObject <NSWindowDelegate>
{
    PhidgetManagerHandle ch;

    //Errors
    IBOutlet NSPanel *errorEventLogWindow;
    IBOutlet NSTextView *errorEventLog;
    IBOutlet NSTextField *errorEventLogCounter;
}

-(void)start;
@end

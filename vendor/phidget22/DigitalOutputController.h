/* DigitalOutputController */

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import </Library/Frameworks/Phidget22.framework/Headers/phidget22.h>
#import "PhidgetInfoBox.h"


@interface DigitalOutputController : NSObject 
{
    PhidgetDigitalOutputHandle ch;
    PhidgetDigitalOutputHandle phid;

}

//Phidget functions
// - (PhidgetHandle) start;

- (void)start:(int)serialNumber port:(int)hubPort  channel:(int)deviceChannel;
- (void)setState:(double)value;


@end

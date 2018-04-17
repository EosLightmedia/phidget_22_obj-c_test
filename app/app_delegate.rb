class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow
    # mp PhidgetReturnCode
    setup_notifcations
    # PhidgetDigitalInput
    # @phidget.setup_phidget(-1)
    # @phidget.createDigitalOutput(-1)
    # @manager = PhiManager.new
    # @manager.start
    # @phidget.initChannel()
  
    serial = 495511
    # serial = 495377
    @phidget = DigitalOutputController.new
    handle = @phidget.start
    @phidget.initChannel(handle)
    
    # @phi = Phidget888Controller.new
    #     # @phi.createRemoteInterfaceKit(App::Persistence['phidget_id'])
    #     handle = @phi.createInterfaceKit(serial)
    #     mp handle
    #     output_state = @phi.phidgetDigitalOutput_getState(handle)
    #     mp "~~~~~~~~~OUtputstate = #{output_state}"
  end
  
  def setup_notifcations
		$center = NSNotificationCenter.defaultCenter 
    #add the observer for processing digital inputs
		$center.addObserver(self, selector: "process_input:", name: 'input_notification_from_phidget', object: nil )
    #Add the observer for processing sensor or analog inputs
    $center.addObserver(self, selector: "process_sensor:", name: 'sensor_notification_from_phidget', object: nil )
    #Add the observer for processing when a phidget gets added
		$center.addObserver(self, selector: "process_attach:", name: 'attach_notification_from_phidget', object: nil )
    #Add the observer for handling errors
		$center.addObserver(self, selector: "handle_error:", name: 'error_notification_from_phidget', object: nil )
  end
  
  # def onAttachHandler(phid)
  #   mp "on attach handler #{phid}"
  #   # // - (void)onAttachHandler:(NSValue *)phid{
  #   # //     PhidgetHandle p = (PhidgetHandle)[phid pointerValue];
  #   # //     const char* deviceName;
  #   # //     int32_t serialNumber, channel;
  #   # //
  #   # //     Phidget_getDeviceName(p, &deviceName);
  #   # //     Phidget_getDeviceSerialNumber(p, &serialNumber);
  #   # //     Phidget_getChannel(p, &channel);
  #   # //     NSLog(@"Device Name: %@, Serial Number: %d, Channel: %d\n", [NSString stringWithCString:deviceName encoding:NSASCIIStringEncoding],serialNumber,channel);
  #   # //
  #   # //     Phidget_release(&p);
  #   # // }
  # end
  
  #Do something with the input change notification
	def process_input(notification)
		value = notification.userInfo
    mp "value is #{value}_______________"
	end
  
  #Do something with the sensor notification
	def process_sensor(notification)
		value = notification.userInfo
    mp "value is #{value}_______________"
	end
  
  #Handle Errors. Or not.
	def handle_error(notification)
		value = notification.userInfo
    mp "ERROR is #{value}_______________"
	end
  
  #this is called when the phidget 'attaches' to the system (available for talking to)
	def process_attach(notification)
		value = notification.userInfo
    NSLog "Phidget #{value["serial"]} attached (in AppDelegate)"
    # sleep(1) #wait for the phidget to get ready to accept calls. May not need this.
    @phidget_attached = true #this is usefull so you dont' write to a phidget which isn't there
	end

  def buildWindow
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless
  end
end

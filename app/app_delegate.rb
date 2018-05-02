class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    # buildWindow
    # mp PhidgetReturnCode
    setup_notifcations

  
    serial = 495511
    # serial = 495377
    @phidget = DigitalOutputController.new
    channel_handle = @phidget.start(495511, port: 0, channel: 1)
    p "Handle is #{channel_handle}"
    App.run_after(5) {
      @phidget.setState(0)
      sleep 0.5
      @phidget.setState(1)
      sleep 0.5
      @phidget.setState(0)
    }

    
    # @phidget.initChannel(handle)
  end
  
  def test_command
    mp "THIS IS A TEST"
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
  
  
  #Handle Errors. Or not.
	def handle_error(notification)
		value = notification.userInfo
    mp "ERROR is #{value}_______________"
	end
  
  #this is called when the phidget 'attaches' to the system (available for talking to)
	def process_attach(notification)
		value = notification.userInfo
    p "Phidget #{value["serial"]} attached (in AppDelegate)"
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

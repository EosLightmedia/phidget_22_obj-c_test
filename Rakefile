# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'phidget_22_obj-c'
  app.frameworks +=['AppKit', 'Cocoa', 'Foundation', 'Carbon']
  
  app.embedded_frameworks += ['/Library/Frameworks/Phidget22.framework']
  app.bridgesupport_files << 'resources/phidget22.bridgesupport'
  app.vendor_project('./vendor/phidget22', :static)
  
  
  # app.vendor_project('/Library/Frameworks/Phidget22.framework', :static,
  #     :products => ['./vendor/phidget22'],
  #     :headers_dir => 'Headers')
  

  app.info_plist['CFBundleIconName'] = 'AppIcon'
end

require 'funnel/arduino.rb'
require 'funnel/configuration.rb'
require 'funnel/event.rb'
require 'funnel/filter.rb'
require 'funnel/fio.rb'
require 'funnel/gainer.rb'
require 'funnel/iomodule.rb'
require 'funnel/iosystem.rb'
require 'funnel/port.rb'
require 'funnel/xbee.rb'

require 'funnel/scope.rb'

module Funnel
  AIN = Port::AIN
  AOUT = Port::AOUT
  CHANGE = PortEvent::CHANGE
  CONFIGURATION_ERROR = FunnelErrorEvent::CONFIGURATION_ERROR
  DIN = Port::DIN
  DOUT = Port::DOUT
  FALLING_EDGE = PortEvent::FALLING_EDGE
  ERROR = FunnelErrorEvent::ERROR
  IN = Port::DIN
  OUT = Port::DOUT
  PWM = Port::AOUT
  READY = FunnelEvent::READY
  REBOOT_ERROR = FunnelErrorEvent::REBOOT_ERROR
  RISING_EDGE = PortEvent::RISING_EDGE
  UPDATE = GeneratorEvent::UPDATE
end

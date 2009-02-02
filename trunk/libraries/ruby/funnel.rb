require 'funnel/arduino.rb'
require 'funnel/configuration.rb'
require 'funnel/event.rb'
require 'funnel/filter.rb'
require 'funnel/fio.rb'
require 'funnel/gainer.rb'
require 'funnel/matrixled.rb'
require 'funnel/i2c.rb'
require 'funnel/iomodule.rb'
require 'funnel/iosystem.rb'
require 'funnel/pin.rb'
require 'funnel/xbee.rb'

require 'funnel/scope.rb'

module Funnel
  AIN = Pin::AIN
  ALL = IOSystem::ALL
  AOUT = Pin::AOUT
  CHANGE = PinEvent::CHANGE
  CONFIGURATION_ERROR = FunnelErrorEvent::CONFIGURATION_ERROR
  DIN = Pin::DIN
  DOUT = Pin::DOUT
  FALLING_EDGE = PinEvent::FALLING_EDGE
  ERROR = FunnelErrorEvent::ERROR
  IN = Pin::DIN
  OUT = Pin::DOUT
  PWM = Pin::AOUT
  READY = FunnelEvent::READY
  REBOOT_ERROR = FunnelErrorEvent::REBOOT_ERROR
  RISING_EDGE = PinEvent::RISING_EDGE
  UPDATE = GeneratorEvent::UPDATE
end

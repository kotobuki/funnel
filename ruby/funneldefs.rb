#!/usr/bin/env ruby

module Funnel
  # port definitions
  PORT_AIN            = 0
  PORT_DIN            = 1
  PORT_AOUT           = 2
  PORT_DOUT           = 3

  module PortType
    DIGITAL = 0
    ANALOG  = 1
  end

  module PortDirection
    INPUT   = 0
    OUTPUT  = 1
  end

  class Event
    def initialize(type, text = "")
      @type = type
      @text = text
    end
  end

  class PortEvent < Event
    RISING_EDGE         = 0
    FALLING_EDGE        = 1
    CHANGE              = 2

    attr_reader :target

    def initialize(type, target)
      super(type, "")
      @target = target
    end
  end

  module ErrorEvent
    NO_ERROR            = 0
    ERROR               = -1
    REBOOT_ERROR        = -2
    CONFIGURATION_ERROR = -3
  end

  module GainerIO
    MODE_1 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    MODE_2 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    MODE_3 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    MODE_4 = [
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AIN, PORT_AIN, PORT_AIN, PORT_AIN,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT,
      PORT_DOUT, PORT_DIN  # LED, BUTTON
    ]

    MODE_5 = [
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
    ]

    MODE_6 = [
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
    ]

    MODE_7 = [
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 0]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 1]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 2]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 3]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 4]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 5]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 6]
      PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, PORT_AOUT, # [0..7, 7]
    ]

    MODE_8 = [
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DIN, PORT_DIN, PORT_DIN, PORT_DIN,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
      PORT_DOUT, PORT_DOUT, PORT_DOUT, PORT_DOUT,
    ]
  end
end

if __FILE__ == $0
  module Funnel
    p port_def_to_str(PORT_AIN)
  end
end

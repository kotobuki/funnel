#!/usr/bin/env ruby

module Funnel
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

  class ErrorEvent < Event
    NO_ERROR            = 0
    ERROR               = -1
    REBOOT_ERROR        = -2
    CONFIGURATION_ERROR = -3
  end
end

#!/usr/bin/env ruby

module Funnel
  class FunnelEvent
    READY               = 0

    def initialize(type, text = "")
      @type = type
      @text = text
    end
  end

  class PortEvent < FunnelEvent
    RISING_EDGE         = 0
    FALLING_EDGE        = 1
    CHANGE              = 2

    attr_reader :target

    def initialize(type, target)
      super(type, "")
      @target = target
    end
  end

  class GeneratorEvent < FunnelEvent
    UPDATE              = 0
  end

  class FunnelErrorEvent < FunnelEvent
    NO_ERROR            = 0
    ERROR               = -1
    REBOOT_ERROR        = -2
    CONFIGURATION_ERROR = -3
  end
end

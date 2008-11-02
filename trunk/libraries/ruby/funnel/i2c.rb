#!/usr/bin/env ruby -wKU

require 'funnel/iomodule'

module Funnel
  class I2CDevice
    WRITE = 0
    READ = 1
    READ_CONTINUOUS = 2
    STOP_READING = 3

    attr_reader :address

    def handle_sysex(data)
    end
  end

  class HMC6352 < I2CDevice
    attr_reader :heading

    def initialize(iomodule = nil, address = 0x21)
      raise ArgumentError, "no IOModule is supplied" if iomodule == nil

      @iomodule = iomodule
      @address = address
      @heading = 0

      @iomodule.add_sysex_listener self

      # I2C, write, slave address, 'G', ram address, query mode
      @iomodule.send_sysex 0x76, [WRITE, @address, 0x47, 0x74, 0x51]

      # I2C, write, slave address, 'A'
      @iomodule.send_sysex 0x76, [WRITE, @address, 0x41]
    end

    def update
      # I2C, read, slave address, register = 0x7F, 2 bytes
      @iomodule.send_sysex 0x76, [READ, @address, 0x7F, 0x02]
    end

    def handle_sysex(data)
      # data should be: slave address, register, MSB, LSB
      return if data.size != 4
      @heading = (data[2] * 256 + data[3]) / 10.0
    end
  end
end
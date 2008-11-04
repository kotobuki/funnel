#!/usr/bin/env ruby -wKU

require 'funnel/iomodule'

module Funnel
  class I2CDevice
    WRITE = 0
    READ = 1
    READ_CONTINUOUS = 2
    STOP_READING = 3

    attr_reader :address

    def initialize(iomodule = nil, address = nil)
      raise ArgumentError, "no IOModule is supplied" if iomodule == nil
      raise ArgumentError, "please specify a proper slave address" if address == nil
      raise ArgumentError, "slave addresses should be between 0x00 and 0x7F" if address < 0x00 or address > 0x7F

      @iomodule = iomodule
      @address = address

      @iomodule.add_sysex_listener self
    end

    def handle_sysex(data)
    end
  end

  class HMC6352 < I2CDevice
    attr_reader :heading

    def initialize(iomodule = nil, address = 0x21)
      super
      @heading = 0

      # I2C, write, slave address, 'G', ram address, query mode
      @iomodule.send_sysex 0x76, [WRITE, @address, ?G, 0x74, 0x51]

      # I2C, write, slave address, 'A'
      @iomodule.send_sysex 0x76, [WRITE, @address, ?A]
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

  class ADJD_S371_QR999 < I2CDevice
    attr_reader :red
    attr_reader :green
    attr_reader :blue
    attr_reader :clear

    alias :r :red
    alias :g :green
    alias :b :blue
    alias :c :clear

    def initialize(iomodule = nil, address = 0x74)
      super

      @red = 0
      @green = 0
      @blue = 0
      @clear = 0

      # CAPs are 4bit
      @iomodule.send_sysex 0x76, [WRITE, @address, 0x06, 0x03, 0x03, 0x03, 0x03]

      # INTs are 12bit
      @iomodule.send_sysex 0x76, [WRITE, @address, 0x0A, 0xC4, 0x09, 0xC4, 0x09, 0xC4, 0x09, 0xC4, 0x09]
    end

    def update
      # start reading
      @iomodule.send_sysex 0x76, [WRITE, @address, 0x00, 0x01]

      # read data: red, green, blue and clear
      @iomodule.send_sysex 0x76, [READ, @address, 0x40, 0x08]
    end

    def color
      return [@red, @green, @blue, @clear]
    end

    def handle_sysex(data)
      # data should be: slave address, register, {MSB, LSB} * 4
      return if data.size != 10

      # convert from 10bit to 8bit
      @red = (data[2] + data[3] * 256) / 4
      @green = (data[4] + data[5] * 256) / 4
      @blue = (data[6] + data[7] * 256) / 4
      @clear = (data[8] + data[9] * 256) / 4
    end
  end

  class BlinkM < I2CDevice
    def initialize(iomodule = nil, address = 0x09)
      super
    end

    def go_to_rgb_color_now(color)
      @iomodule.send_sysex 0x76, [WRITE, @address, ?n, color[0], color[1], color[2]]
    end

    def fade_to_rgb_color(color, speed = nil)
      @iomodule.send_sysex 0x76, [WRITE, @address, ?f, speed] unless speed == nil
      @iomodule.send_sysex 0x76, [WRITE, @address, ?c, color[0], color[1], color[2]]
    end

    def fade_to_random_rgb_color(color, speed = nil)
      @iomodule.send_sysex 0x76, [WRITE, @address, ?f, speed] unless speed == nil
      @iomodule.send_sysex 0x76, [WRITE, @address, ?C, color[0], color[1], color[2]]
    end

    def fade_to_hsb_color(color, speed = nil)
      @iomodule.send_sysex 0x76, [WRITE, @address, ?f, speed] unless speed == nil
      @iomodule.send_sysex 0x76, [WRITE, @address, ?h, color[0], color[1], color[2]]
    end

    def fade_to_random_hsb_color(color, speed = nil)
      @iomodule.send_sysex 0x76, [WRITE, @address, ?f, speed] unless speed == nil
      @iomodule.send_sysex 0x76, [WRITE, @address, ?H, color[0], color[1], color[2]]
    end

    def set_fade_speed(speed)
      @iomodule.send_sysex 0x76, [WRITE, @address, ?f, speed]
    end

    def play_light_script(script_id, the_number_of_repeats = 1, line_number = 0)
      @iomodule.send_sysex 0x76, [WRITE, @address, ?p, script_id, the_number_of_repeats, line_number]
    end

    def stop_script
      @iomodule.send_sysex 0x76, [WRITE, @address, ?o]
    end

    def handle_sysex(data)
      # TODO: implement if needed
      puts "BlinkM: #{data}"
    end
  end

end
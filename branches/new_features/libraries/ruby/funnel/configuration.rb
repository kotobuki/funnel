#!/usr/bin/env ruby

require 'funnel/pin'

module Funnel
  class Configuration
    (GAINER, ARDUINO, XBEE, FIO) = Array(0..3)
    (MODE1, MODE2, MODE3, MODE4, MODE5, MODE6, MODE7) = Array(1..7)
    (MULTIPOINT, ZB) = Array(0..1)

    attr_reader :ain_pins
    attr_reader :din_pins
    attr_reader :aout_pins
    attr_reader :dout_pins
    attr_reader :analog_pins
    attr_reader :digital_pins
    attr_reader :button
    attr_reader :led

    def initialize(model, mode = 0)
      raise ArgumentError, "model #{model} is not available" unless (GAINER..FIO).include?(model)

      case model
      when GAINER
        case mode
        when MODE1
          @config = [
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN,
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT,
            Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::DOUT,
            Pin::DOUT, Pin::DIN  # LED, BUTTON
          ]
          @ain_pins = [0, 1, 2, 3]
          @din_pins = [4, 5, 6, 7]
          @aout_pins = [8, 9, 10, 11]
          @dout_pins = [12, 13, 14, 15]
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE2
          @config = [
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT,
            Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::DOUT,
            Pin::DOUT, Pin::DIN  # LED, BUTTON
          ]
          @ain_pins = [0, 1, 2, 3, 4, 5, 6, 7]
          @din_pins = nil
          @aout_pins = [8, 9, 10, 11]
          @dout_pins = [12, 13, 14, 15]
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE3
          @config = [
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN,
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT,
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT,
            Pin::DOUT, Pin::DIN  # LED, BUTTON
          ]
          @ain_pins = [0, 1, 2, 3]
          @din_pins = [4, 5, 6, 7]
          @aout_pins = [8, 9, 10, 11, 12, 13, 14, 15]
          @dout_pins = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE4
          @config = [
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT,
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT,
            Pin::DOUT, Pin::DIN  # LED, BUTTON
          ]
          @ain_pins = [0, 1, 2, 3, 4, 5, 6, 7]
          @din_pins = nil
          @aout_pins = [8, 9, 10, 11, 12, 13, 14, 15]
          @dout_pins = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE5
          @config = [
            Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN,
            Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN,
            Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN,
            Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN,
          ]
          @ain_pins = nil
          @din_pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
          @aout_pins = nil
          @dout_pins = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = nil
          @led = nil
        when MODE6
          @config = [
            Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::DOUT,
            Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::DOUT,
            Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::DOUT,
            Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::DOUT,
          ]
          @ain_pins = nil
          @din_pins = nil
          @aout_pins = nil
          @dout_pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
          @analog_pins = nil
          @digital_pins = nil
          @button = nil
          @led = nil
        when MODE7
          @config = [
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 0]
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 1]
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 2]
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 3]
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 4]
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 5]
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 6]
            Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, # [0..7, 7]
          ]
          @ain_pins = nil
          @din_pins = nil
          @aout_pins = nil
          @dout_pins = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = nil
          @led = nil
        end
      when ARDUINO
        @config = [
          Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::AOUT, Pin::DOUT, Pin::AOUT, Pin::AOUT,
          Pin::DOUT, Pin::DOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::DOUT, Pin::DOUT,
          Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN
        ]
        @ain_pins = nil
        @din_pins = nil
        @aout_pins = nil
        @dout_pins = nil
        @analog_pins = [14, 15, 16, 17, 18, 19, 20, 21]
        @digital_pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
        @button = nil
        @led = nil
      when XBEE
        case mode
        when MULTIPOINT # was XBee Series 1, is 802.15.4
          # 8 digital I/O (including 6 ADC inputs)
          @config = [
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::DIN, Pin::DIN
          ]
          @analog_pins = [0, 1, 2, 3, 4, 5]
          @digital_pins = [6, 7]
        when ZB # was XBee Series 2 or ZNet 2.5, is ZB
          # 13 digital I/O (including 4 ADC inputs)
          # NOTE: D6, D8 and D9 are not accessible
          @config = [
            Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN,
            Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN, Pin::DIN
          ]
          @analog_pins = [0, 1, 2, 3]
          @digital_pins = [4, 5, 6, 7, 8, 9, 10, 11, 12]
        end
        @ain_pins = nil
        @din_pins = nil
        @aout_pins = nil
        @dout_pins = nil
        @button = nil
        @led = nil
      when FIO
        @config = [
          Pin::DOUT, Pin::DOUT, Pin::DOUT, Pin::AOUT, Pin::DOUT, Pin::AOUT, Pin::AOUT,
          Pin::DOUT, Pin::DOUT, Pin::AOUT, Pin::AOUT, Pin::AOUT, Pin::DOUT, Pin::DOUT,
          Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN, Pin::AIN
        ]
        @ain_pins = nil
        @din_pins = nil
        @aout_pins = nil
        @dout_pins = nil
        @analog_pins = [14, 15, 16, 17, 18, 19, 20, 21]
        @digital_pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
        @button = nil
        @led = nil
      end
    end

    def set_digital_pin_mode(pin, mode)
      raise ArgumentError, "digital pins are not available" if @digital_pins == nil
      raise ArgumentError, "digital pin is not available at #{pin}" if @digital_pins.at(pin) == nil
      case mode
      when Pin::DIN
        @config[@digital_pins.at(pin)] = Pin::DIN
      when Pin::DOUT
        @config[@digital_pins.at(pin)] = Pin::DOUT
      when Pin::AOUT
        @config[@digital_pins.at(pin)] = Pin::AOUT
      when Pin::SERVO
        @config[@digital_pins.at(pin)] = Pin::SERVO
      else
        raise ArgumentError, "mode #{mode} is not available"
      end
    end

    def to_a
      return @config
    end

    alias :pin_mode :set_digital_pin_mode

  end

end


if __FILE__ == $0
  module Funnel
    puts "TEST: Arduino"
    arduino = Configuration.new(Configuration::ARDUINO)
    arduino.set_digital_pin_mode(2, Configuration::OUT)
    arduino.set_digital_pin_mode(11, Configuration::PWM)
    p arduino.to_a
    puts "ain: #{arduino.ain_pins.join(',')}" if arduino.ain_pins
    puts "din: #{arduino.din_pins.join(',')}" if arduino.din_pins
    puts "aout: #{arduino.aout_pins.join(',')}" if arduino.aout_pins
    puts "dout: #{arduino.dout_pins.join(',')}" if arduino.dout_pins
    puts "analog: #{arduino.analog_pins.join(',')}" if arduino.analog_pins
    puts "digital: #{arduino.digital_pins.join(',')}" if arduino.digital_pins
    puts "button: #{arduino.button.join(',')}" if arduino.button
    puts "led: #{arduino.led.join(',')}" if arduino.led

    puts ""
    puts "TEST: Gainer"
    gainer = Gainer::MODE1
    p gainer.to_a
    puts "ain: #{gainer.ain_pins.join(',')}" if gainer.ain_pins
    puts "din: #{gainer.din_pins.join(',')}" if gainer.din_pins
    puts "aout: #{gainer.aout_pins.join(',')}" if gainer.aout_pins
    puts "dout: #{gainer.dout_pins.join(',')}" if gainer.dout_pins
    puts "analog: #{gainer.analog_pins.join(',')}" if gainer.analog_pins
    puts "digital: #{gainer.digital_pins.join(',')}" if gainer.digital_pins
    puts "button: #{gainer.button.join(',')}" if gainer.button
    puts "led: #{gainer.led.join(',')}" if gainer.led
  end
end

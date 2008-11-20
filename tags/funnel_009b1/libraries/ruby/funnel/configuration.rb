#!/usr/bin/env ruby

require 'funnel/port'

module Funnel
  class Configuration
    (GAINER, ARDUINO, XBEE, FIO) = Array(0..3)
    (MODE1, MODE2, MODE3, MODE4, MODE5, MODE6, MODE7) = Array(1..7)
    (MULTIPOINT, ZB) = Array(0..1)

    attr_reader :ain_ports
    attr_reader :din_ports
    attr_reader :aout_ports
    attr_reader :dout_ports
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
            Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::DIN, Port::DIN, Port::DIN, Port::DIN,
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
            Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
            Port::DOUT, Port::DIN  # LED, BUTTON
          ]
          @ain_ports = [0, 1, 2, 3]
          @din_ports = [4, 5, 6, 7]
          @aout_ports = [8, 9, 10, 11]
          @dout_ports = [12, 13, 14, 15]
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE2
          @config = [
            Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
            Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
            Port::DOUT, Port::DIN  # LED, BUTTON
          ]
          @ain_ports = [0, 1, 2, 3, 4, 5, 6, 7]
          @din_ports = nil
          @aout_ports = [8, 9, 10, 11]
          @dout_ports = [12, 13, 14, 15]
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE3
          @config = [
            Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::DIN, Port::DIN, Port::DIN, Port::DIN,
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
            Port::DOUT, Port::DIN  # LED, BUTTON
          ]
          @ain_ports = [0, 1, 2, 3]
          @din_ports = [4, 5, 6, 7]
          @aout_ports = [8, 9, 10, 11, 12, 13, 14, 15]
          @dout_ports = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE4
          @config = [
            Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
            Port::DOUT, Port::DIN  # LED, BUTTON
          ]
          @ain_ports = [0, 1, 2, 3, 4, 5, 6, 7]
          @din_ports = nil
          @aout_ports = [8, 9, 10, 11, 12, 13, 14, 15]
          @dout_ports = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = [17]
          @led = [16]
        when MODE5
          @config = [
            Port::DIN, Port::DIN, Port::DIN, Port::DIN,
            Port::DIN, Port::DIN, Port::DIN, Port::DIN,
            Port::DIN, Port::DIN, Port::DIN, Port::DIN,
            Port::DIN, Port::DIN, Port::DIN, Port::DIN,
          ]
          @ain_ports = nil
          @din_ports = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
          @aout_ports = nil
          @dout_ports = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = nil
          @led = nil
        when MODE6
          @config = [
            Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
            Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
            Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
            Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
          ]
          @ain_ports = nil
          @din_ports = nil
          @aout_ports = nil
          @dout_ports = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
          @analog_pins = nil
          @digital_pins = nil
          @button = nil
          @led = nil
        when MODE7
          @config = [
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 0]
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 1]
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 2]
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 3]
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 4]
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 5]
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 6]
            Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 7]
          ]
          @ain_ports = nil
          @din_ports = nil
          @aout_ports = nil
          @dout_ports = nil
          @analog_pins = nil
          @digital_pins = nil
          @button = nil
          @led = nil
        end
      when ARDUINO
        @config = [
          Port::DOUT, Port::DOUT, Port::DOUT, Port::AOUT, Port::DOUT, Port::AOUT, Port::AOUT,
          Port::DOUT, Port::DOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::DOUT, Port::DOUT,
          Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN
        ]
        @ain_ports = nil
        @din_ports = nil
        @aout_ports = nil
        @dout_ports = nil
        @analog_pins = [14, 15, 16, 17, 18, 19, 20, 21]
        @digital_pins = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21]
        @button = nil
        @led = nil
      when XBEE
        case mode
        when MULTIPOINT # was XBee Series 1, is 802.15.4
          # 8 digital I/O (including 6 ADC inputs)
          @config = [
            Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::DIN, Port::DIN
          ]
          @analog_pins = [0, 1, 2, 3, 4, 5]
          @digital_pins = [6, 7]
        when ZB # was XBee Series 2 or ZNet 2.5, is ZB
          # 13 digital I/O (including 4 ADC inputs)
          # NOTE: D6, D8 and D9 are not accessible
          @config = [
            Port::AIN, Port::AIN, Port::AIN, Port::AIN,
            Port::DIN, Port::DIN, Port::DIN, Port::DIN, Port::DIN, Port::DIN, Port::DIN, Port::DIN, Port::DIN
          ]
          @analog_pins = [0, 1, 2, 3]
          @digital_pins = [4, 5, 6, 7, 8, 9, 10, 11, 12]
        end
        @ain_ports = nil
        @din_ports = nil
        @aout_ports = nil
        @dout_ports = nil
        @button = nil
        @led = nil
      when FIO
        @config = [
          Port::DOUT, Port::DOUT, Port::DOUT, Port::AOUT, Port::DOUT, Port::AOUT, Port::AOUT,
          Port::DOUT, Port::DOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::DOUT, Port::DOUT,
          Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN, Port::AIN
        ]
        @ain_ports = nil
        @din_ports = nil
        @aout_ports = nil
        @dout_ports = nil
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
      when Port::DIN
        @config[@digital_pins.at(pin)] = Port::DIN
      when Port::DOUT
        @config[@digital_pins.at(pin)] = Port::DOUT
      when Port::AOUT
        @config[@digital_pins.at(pin)] = Port::AOUT
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
    puts "ain: #{arduino.ain_ports.join(',')}" if arduino.ain_ports
    puts "din: #{arduino.din_ports.join(',')}" if arduino.din_ports
    puts "aout: #{arduino.aout_ports.join(',')}" if arduino.aout_ports
    puts "dout: #{arduino.dout_ports.join(',')}" if arduino.dout_ports
    puts "analog: #{arduino.analog_pins.join(',')}" if arduino.analog_pins
    puts "digital: #{arduino.digital_pins.join(',')}" if arduino.digital_pins
    puts "button: #{arduino.button.join(',')}" if arduino.button
    puts "led: #{arduino.led.join(',')}" if arduino.led

    puts ""
    puts "TEST: Gainer"
    gainer = Gainer::MODE1
    p gainer.to_a
    puts "ain: #{gainer.ain_ports.join(',')}" if gainer.ain_ports
    puts "din: #{gainer.din_ports.join(',')}" if gainer.din_ports
    puts "aout: #{gainer.aout_ports.join(',')}" if gainer.aout_ports
    puts "dout: #{gainer.dout_ports.join(',')}" if gainer.dout_ports
    puts "analog: #{gainer.analog_pins.join(',')}" if gainer.analog_pins
    puts "digital: #{gainer.digital_pins.join(',')}" if gainer.digital_pins
    puts "button: #{gainer.button.join(',')}" if gainer.button
    puts "led: #{gainer.led.join(',')}" if gainer.led
  end
end

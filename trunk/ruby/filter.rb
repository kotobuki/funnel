#!/usr/bin/env ruby

module Funnel
  class Filter
    def process_sample(value)
    end
  end

  class Convolution < Filter
    LPF = [1.0/3.0, 1.0/3.0, 1.0/3.0]
    HPF = [1.0/3.0, -2.0/3.0, 1.0/3.0]
    MOVING_AVERAGE = [1.0/8.0, 1.0/8.0, 1.0/8.0, 1.0/8.0, 1.0/8.0, 1.0/8.0, 1.0/8.0, 1.0/8.0]

    def initialize(coef)
      @coef = coef
      @buffer = Array.new(coef.length, 0.0)
    end

    def process_sample(value)
      @buffer[0] = value
      result = 0.0
      @coef.length.times do |i|
        result = result + @buffer[i] * @coef[i]
      end

      (@buffer.length - 1).downto(1) do |i|
        @buffer[i] = @buffer[i - 1]
      end
      
      return result
    end
  end

  class SetPoint < Filter
    def initialize(threshold, hysteresis)
      @threshold = []
      @hysteresis = []
      @range = []
      if threshold.is_a? Array and hysteresis.is_a? Array then
        if threshold.length != hysteresis.length then
          raise ArgumentError, "the length of threshold should be same as the length of hysteresis"
        end
        @threshold = threshold
        @hysteresis = hysteresis
      elsif threshold.is_a? Numeric and hysteresis.is_a? Numeric then
        @threshold = [threshold]
        @hysteresis = [hysteresis]
      else
        raise ArgumentError, "arguments to SetPoint should be (float, float) or (array, array)"
      end
      @range << [0.0, @threshold[0] - @hysteresis[0]]
      points = @threshold.length
      (points - 1).times do |i|
        @range << [@threshold[i] + @hysteresis[i], @threshold[i + 1] - @hysteresis[i + 1]]
      end
      @range << [@threshold[points - 1] + @hysteresis[points - 1], 1.0]
      puts "SetPoint: #{@range}"
      @last_status = 0
    end

    def process_sample(value)
      status = @last_status
      @range.length.times do |i|
        min, max = @range[i]
        status = i if (min <= value) and (value <= max)
      end
      @last_status = status
      return status
    end
  end

  class Osc < Filter
  end

  class Scaler < Filter
  end
end

if __FILE__ == $0
  th = Funnel::SetPoint.new([0.3, 0.7], [0.1, 0.1])
  0.0.step(1.0, 0.1) do |val|
    puts "#{val}: #{th.process_sample(val)}"
  end

  lpf = Funnel::Convolution.new(Funnel::Convolution::MOVING_AVERAGE)
  10.times do |i|
    puts "#{i}: #{lpf.process_sample(1.0)}"
  end
end

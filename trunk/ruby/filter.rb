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
    SIN = lambda { |val|
      0.5 * (1 + Math.sin(2 * Math::PI * val))
    }

    SQUARE = lambda { |val|
      return (val % 1 <= 0.5) ? 1 : 0
    }

    TRIANGLE = lambda { |val|
      val %= 1;
      if (val <= 0.25) then return 2 * val + 0.5
      elsif (val <= 0.75) then return -2 * val + 1.5
      else return 2 * val - 1.5
      end
    }

    SAW = lambda { |val|
      val %= 1;
      if (val <= 0.5) then return val + 0.5
      else return val - 0.5
      end
    }

    IMPULSE = lambda { |val|
      if (val <= 1) then return 1
      else return 0
      end
    }

    MINIMUM_SERVICE_INTERVAL = 5  # i.e. 5ms
    @@interval = 0.033 # i.e. 30fps
    @@service_thread = nil
    @@listeners =[]

    attr_reader :value

    def self.service_interval
      return (@@interval * 1000.0).to_i
    end

    def self.service_interval=(new_interval)
      new_interval = MINIMUM_SERVICE_INTERVAL if new_interval < MINIMUM_SERVICE_INTERVAL
      @@interval = new_interval.to_f / 1000.0
    end

    def initialize(wave_func, frequency, *args)
      @wave_func = wave_func
      if frequency > 0 then
        @frequency = frequency
      else
        raise ArgumentError, "frequency should be greater than 0"
      end

      if args.length == 4 then
        @amplitude = args[0]
        @offset = args[1]
        @phase = args[2]
        @times = args[3]
      elsif args.length == 1 then
        @amplitude = 1.0
        @offset = 0.0
        @phase = 0.0
        @times = args[0]
      else
        raise ArgumentError, "wrong number of arguments"
      end

      @value = 0
      @time = 0
      @start_time = 0
      @auto_update = false

      if @@service_thread == nil then
        @@service_thread = Thread.new do
          loop do
            @@listeners.each do |listener|
              listener.send(:update)
            end
            sleep(@@interval)
          end
        end
      end
    end

    def start
      stop
      @@listeners.push(self)
      @auto_update = true
      update
    end

    def stop
      @auto_update = false
      @@listeners.delete(self)
    end

    def reset
      @time = 0
      @start_time = Time.now.to_f
    end

    def update(*args)
      if args.length == 1 then
        @time = @time + args[0]
      elsif @auto_update then
        @time = Time.now.to_f - @start_time
      else
        @time = @time + @@interval
      end

      if (@times != 0 and @frequency * @time >= @times) then
        @@listeners.delete(self.update)
        @time = @times / @frequency
      end

      @value = @amplitude * @wave_func.call(@frequency * (@time + @phase)) + @offset
    end
  end

  class Scaler < Filter
    LINEAR = lambda { |val|
      return val
    }

    LOG = lambda { |val|
      return Math.log(val * (Math.E - 1) + 1)
    }

    EXP = lambda { |val|
      return (Math.exp(val) - 1) / (Math.E - 1)
    }

    SQUARE = lambda { |val|
      return val * val
    }

    SQUARE_ROOT = lambda { |val|
      return val ** (1.0 / 2)
    }

    CUBE = lambda { |val|
      return val * val * val * val
    }

    CUBE_ROOT = lambda { |val|
      return val ** (1.0 / 4)
    }

    def initialize(in_min, in_max, out_min, out_max, curve_func, limiter = false)
      @in_min = in_min
      @in_max = in_max
      @out_min = out_min
      @out_max = out_max
      @curve_func = curve_func
      @limiter = limiter
    end
    
    def process_sample(value)
      if @limiter then
        value = in_min if value < in_min
        value = in_max if value > in_max
      end

      in_range = @in_max - @in_min
      out_range = @out_max - @out_min
      normalized_val = (value - @in_min) / in_range

      return out_range * @curve_func.call(normalized_val) + @out_min
    end
  end
end

if __FILE__ == $0
  puts "TEST: SetPoint"
  th = Funnel::SetPoint.new([0.3, 0.7], [0.1, 0.1])
  0.0.step(1.0, 0.1) do |val|
    puts "#{val}: #{th.process_sample(val)}"
  end
  puts ""

  puts "TEST: Convolution"
  lpf = Funnel::Convolution.new(Funnel::Convolution::MOVING_AVERAGE)
  10.times do |i|
    puts "#{i}: #{lpf.process_sample(1.0)}"
  end
  puts ""

  puts "TEST: Osc"
  Funnel::Osc.service_interval = 20
  puts "service interval: #{Funnel::Osc.service_interval}"
  osc = Funnel::Osc.new(Funnel::Osc::SIN, 1.0, 0)
  osc.start
  20.times do
    p osc.value
    sleep(0.05)
  end
  osc.stop
  puts ""
  
  puts "TEST: Scaler"
  scaler = Funnel::Scaler.new(0, 1, 0, 1, Funnel::Scaler::SQUARE)
  0.0.step(1.0, 0.1) do |val|
    puts "#{val}: #{scaler.process_sample(val)}"
  end
end

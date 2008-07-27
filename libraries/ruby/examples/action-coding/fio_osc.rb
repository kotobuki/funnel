$: << '../..'

require 'funnel'
include Funnel

R = 11
G = 18
B = 19

def setup
  size 360, 480

  config = Fio.FIRMATA
  config.set_digital_pin_mode(3, PWM)
  config.set_digital_pin_mode(10, PWM)
  config.set_digital_pin_mode(11, PWM)
  @nodes = [1, 2, 3, 4, 5, 6, 7, 8]
  @fio = Fio.new :applet => self, :config => config, :nodes => @nodes
  @osc1 = Osc.new Osc::SQUARE, 0.5, 1, 0, 0, 0

  @fio.io_module(ALL).port(R).value = 0
  @fio.io_module(ALL).port(G).value = 0
  @fio.io_module(ALL).port(B).value = 0
      
  @fio.io_module(ALL).port(G).filters = [@osc1]
  @osc1.start
end

def draw
  background 0
end

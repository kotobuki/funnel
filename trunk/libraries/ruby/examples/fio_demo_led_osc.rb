require 'funnel'
include Funnel

R = 3
G = 10
B = 11

@nodes = [1, 2, 3, 4, 5]
@fio = Fio.new :nodes => @nodes

# @fio.io_module(ALL).port(R).value = 0
# @fio.io_module(ALL).port(G).value = 0
# @fio.io_module(ALL).port(B).value = 0

@osc1 = Osc.new Osc::SIN, 0.5, 1, 0, 0, 50
@osc2 = Osc.new Osc::SIN, 0.5, 1, 0, 0.5, 50
    
@fio.io_module(ALL).port(G).filters = [@osc1]
@fio.io_module(ALL).port(B).filters = [@osc2]
@osc1.start
@osc2.start

sleep 10

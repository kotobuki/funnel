#!/usr/bin/env ruby
require 'port'

module Funnel
  module GainerIO
    MODE_1 = [
      Port::AIN, Port::AIN, Port::AIN, Port::AIN,
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
      Port::DOUT, Port::DIN  # LED, BUTTON
    ]

    MODE_2 = [
      Port::AIN, Port::AIN, Port::AIN, Port::AIN,
      Port::AIN, Port::AIN, Port::AIN, Port::AIN,
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
      Port::DOUT, Port::DIN  # LED, BUTTON
    ]

    MODE_3 = [
      Port::AIN, Port::AIN, Port::AIN, Port::AIN,
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
      Port::DOUT, Port::DIN  # LED, BUTTON
    ]

    MODE_4 = [
      Port::AIN, Port::AIN, Port::AIN, Port::AIN,
      Port::AIN, Port::AIN, Port::AIN, Port::AIN,
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT,
      Port::DOUT, Port::DIN  # LED, BUTTON
    ]

    MODE_5 = [
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
    ]

    MODE_6 = [
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
    ]

    MODE_7 = [
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 0]
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 1]
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 2]
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 3]
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 4]
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 5]
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 6]
      Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, Port::AOUT, # [0..7, 7]
    ]

    MODE_8 = [
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
      Port::DIN, Port::DIN, Port::DIN, Port::DIN,
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
      Port::DOUT, Port::DOUT, Port::DOUT, Port::DOUT,
    ]
  end
end

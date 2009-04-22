#!/usr/bin/env ruby -wKU
$: << '..'

require 'funnel'
include Funnel

mat = MatrixLED.new

loop do
  pixels = []

  64.times do
    pixels << rand
  end

  mat.scan_matrix(pixels)
  sleep(1)
end

$: << '../..'

include_class 'processing.core.PConstants'

require 'funnel'
include Funnel

def setup
  size(340, 480)
  frameRate(30)

  println(PFont.list)
  font = createFont("CourierNewPSMT", 12)
  textFont(font)

  @gio = Gainer.new(Gainer::MODE1)

  @scope = Scope.new(30, 35, 200, 100, "button")
end

def draw
  background(0)
  @scope.draw(self, @gio.button.value)
end


class Scope
  def initialize(l, t, w, h, title)
    @l = l
    @t = t
    @h = h
    @points = w
    @title = title
    @index = 0
    @values = Array.new(@points)
    @values.fill(0)
  end

  def draw(p, value)
    @values[@index] = value

    # draw text lables
    p.smooth()
    p.textSize(12)
    p.text(@title, @l - 24, @t - 8)
    p.text("1.0", @l - 24, @t + 8)
    p.text("0.0", @l - 24, @t + @h)
    p.text("val: #{value}", @l + @points + 8, @t + 8)

    # draw outlines
    p.stroke(200)
    p.noFill()
    p.beginShape()
    p.vertex(@l - 1, @t - 1)
    p.vertex(@l + @points, @t - 1)
    p.vertex(@l + @points, @t + @h)
    p.vertex(@l - 1, @t + @h)
    p.endShape(PConstants::CLOSE)

    # draw the signal
    p.stroke(255)
    p.beginShape()
    @points.times do |i|
      p.vertex(@l + i, @t + @h - @values[(@index + i) % @points] * @h)
    end
    p.endShape()

    @index = (@index + 1) % @points
  end
end

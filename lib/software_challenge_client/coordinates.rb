# frozen_string_literal: true
# Einfache kartesische Koordinaten
class Coordinates
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def to_s
    "(#{x}, #{y})"
  end

  def inspect
    to_s
  end
end

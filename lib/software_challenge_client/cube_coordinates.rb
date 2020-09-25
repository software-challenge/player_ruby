# frozen_string_literal: true
# CubeCoordinates erleichtern viele Berechnungen auf einem hexagonalen Spielfeld. Siehe
# https://www.redblobgames.com/grids/hexagons/#coordinates-cube
class CubeCoordinates
  attr_reader :x, :y, :z

  def initialize(x, y, z = nil)
    @x = x
    @y = y
    @z = z.nil? ? -x - y : z
    throw InvalidArgumentException("sum of coordinates #{@x}, #{@y}, #{@z} have to be equal 0") if (@x + @y + @z).nonzero?
  end

  def ==(other)
    x == other.x && y == other.y && z == other.z
  end

  def to_s
    "(#{x}, #{y}, #{z})"
  end

  def inspect
    to_s
  end
end

# encoding: utf-8

require 'typesafe_enum'
class Direction < TypesafeEnum::Base
  new :UP
  new :UP_RIGHT
  new :RIGHT
  new :DOWN_RIGHT
  new :DOWN
  new :DOWN_LEFT
  new :LEFT
  new :UP_LEFT

  def translate(coordinates)
    case key
    when :UP
      Coordinates.new(coordinates.x, coordinates.y + 1)
    when :UP_RIGHT
      Coordinates.new(coordinates.x + 1, coordinates.y + 1)
    when :RIGHT
      Coordinates.new(coordinates.x + 1, coordinates.y)
    when :DOWN_RIGHT
      Coordinates.new(coordinates.x + 1, coordinates.y - 1)
    when :DOWN
      Coordinates.new(coordinates.x, coordinates.y - 1)
    when :DOWN_LEFT
      Coordinates.new(coordinates.x - 1, coordinates.y - 1)
    when :LEFT
      Coordinates.new(coordinates.x - 1, coordinates.y)
    when :UP_LEFT
      Coordinates.new(coordinates.x - 1, coordinates.y + 1)
    end
  end
end

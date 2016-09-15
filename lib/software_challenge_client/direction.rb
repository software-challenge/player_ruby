# encoding: UTF-8

require 'typesafe_enum'
class Direction < TypesafeEnum::Base
  new :RIGHT
  new :UP_RIGHT
  new :UP_LEFT
  new :LEFT
  new :DOWN_LEFT
  new :DOWN_RIGHT

  def self.get_turn_direction(direction, turns)
    # order of directions is equal to counterclockwise turning
    Direction.find_by_ord((direction.ord + turns) % 6)
  end
end

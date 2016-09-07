# encoding: UTF-8
require_relative 'field_type'

# A field on the game board
class Field
  # @!attribute [rw] type
  # @return [PlayerColor] the field's type
  attr_accessor :type
  # @!attribute [r] x
  # @return [Integer] the field's x-coordinate
  attr_reader :x
  # @!attribute [r] y
  # @return [Integer] the field's y-coordinate
  attr_reader :y

  # @!attribute [r] direction
  # @return [Integer] the direction of the tile which the field belongs to
  attr_reader :direction

  # @!attribute [r] index
  # @return [Integer] the index of the tile which the field belongs to
  attr_reader :index

  # @!attribute [r] points
  # @return [Integer] the points awarded to a player placed on this field additionally to points for current tile and passengers
  attr_reader :points

  # Initializer
  #
  # @param type [FieldType] field type
  # @param x [Integer] x-coordinate
  # @param y [Integer] y-coordinate
  # @param index [Integer] index of tile
  # @param direction [Integer] direction of tile
  # @param points [Integer] points
  def initialize(type, x, y, index, direction, points)
    self.type = type
    @x = x
    @y = y
    @index = index
    @direction = direction
    @points = points
  end

  def ==(another_field)
    return self.type == another_field.type &&
      self.x == another_field.x &&
      self.y == another_field.y
  end

  def to_s
    return "Field: x = #{self.x}, y = #{self.y}, type = #{self.type}"
  end
end

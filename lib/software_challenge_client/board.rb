# encoding: UTF-8
require_relative './util/constants'
require_relative 'game_state'
require_relative 'player'
require_relative 'field_type'
require_relative 'field'

# A representation of a mississippi queen game board
class Board

  # @!attribute [r] fields
  # @note Better use {#field} to access fields.
  # @return [Hash<Field>] A field will be stored at the hash of the
  # coordinate-tuple (2-element-array) of the field.
  attr_reader :fields

  # Initializes the board
  def initialize
    @fields = {}
  end

  def to_s
    fields.values.map { |f| f.type.key.to_s[0] }.join(' ')
  end

  def ==(other)
    fields.each_with_index do |row, x|
      row.each_with_index do |field, y|
        return false if field != other.field(x, y)
      end
    end
    true
  end

  def add_field(field)
    fields[[field.x, field.y]] = field
  end

  # @return [Integer, Integer] The coordinates of the neighbor of the field
  #                            specified by given coordinates in specified
  #                            direction.
  def get_neighbor(x, y, direction)
    directions = {
                   even_row: {
                     Direction::RIGHT.key=> [+1,  0],
                     Direction::UP_RIGHT.key=>[+1, -1],
                     Direction::UP_LEFT.key=>[0, -1],
                     Direction::LEFT.key=>[-1,  0],
                     Direction::DOWN_LEFT.key=>[0, +1],
                     Direction::DOWN_RIGHT.key=>[+1, +1]
                   },
                   odd_row: {
                     Direction::RIGHT.key=> [+1,  0],
                     Direction::UP_RIGHT.key=> [ 0, -1],
                     Direction::UP_LEFT.key=> [-1, -1],
                     Direction::LEFT.key=> [-1, 0],
                     Direction::DOWN_LEFT.key=> [-1, +1],
                     Direction::DOWN_RIGHT.key=> [ 0, +1]
                   }
                 }

    parity = y.odd? ? :odd_row : :even_row
    dir = directions[parity][direction.key]
    return x + dir[0], y + dir[1]
  end

  # @return [Field] The field in given direction with given distance from the
  #                 field with given coordinates.
  def get_in_direction(from_x, from_y, direction, distance = 1)
    x = from_x
    y = from_y
    distance.times do
      x, y = get_neighbor(x, y, direction)
    end
    if !field(x, y).nil?
      return field(x, y)
    else
      raise FieldUnavailableException.new(x, y)
    end
  end

  # @return [Array<Field>] A list of fields in given direction up to given
  #                        distance from the field with given coordinates.
  #                        The start field is excluded.
  def get_all_in_direction(from_x, from_y, direction, distance = 1)
    (1..distance).to_a.map do |i|
      get_in_direction(
        from_x, from_y, direction, i
      )
    end
  end

  # Access fields of the board.
  #
  # @param x [Integer] The x-coordinate of the field.
  # @param y [Integer] The y-coordinate of the field.
  # @return [Field] the field at the given coordinates.
  def field(x, y)
    fields[[x,y]]
  end
end

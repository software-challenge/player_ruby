# encoding: UTF-8
require_relative './util/constants'
require_relative 'game_state'
require_relative 'player'
require_relative 'field_type'
require_relative 'field'

# A representation of a mississippi queen game board
class Board

  # @!attribute [r] fields
  # @return [Hash<Field>] A field will be stored at the hash of the
  # coordinate-tuple of the field.
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
        return false if field != other.fields[x][y]
      end
    end
    true
  end

  def add_field(field)
    fields[field.x] = {} unless fields.key? field.x
    fields[field.x][field.y] = field
  end

  # @return [Integer, Integer] The coordinates of the neighbor of the field
  # specified by given coordinated in specified direction
  def get_neighbor(x, y, direction)
    directions = {
                   even_row: {
                     Direction::RIGHT => [+1,  0],
                     Direction::UP_RIGHT =>[+1, -1],
                     Direction::UP_LEFT =>[0, -1],
                     Direction::LEFT =>[-1,  0],
                     Direction::DOWN_LEFT =>[0, +1],
                     Direction::DOWN_RIGHT =>[+1, +1]
                   },
                   odd_row: {
                     Direction::RIGHT => [+1,  0],
                     Direction::UP_RIGHT => [ 0, -1],
                     Direction::UP_LEFT => [-1, -1],
                     Direction::LEFT => [-1, 0],
                     Direction::DOWN_LEFT => [-1, +1],
                     Direction::DOWN_RIGHT => [ 0, +1]
                   }
                 }

    parity = y.odd? ? :odd_row : :even_row
    dir = directions[parity][direction]
    return x + dir[0], y + dir[1]
  end

  # @return [Field] The field in given direction with given distance from the
  # field with given coordinates.
  def get_in_direction(from_x, from_y, direction, distance = 1)
    x = from_x
    y = from_y
    distance.times do
      x, y = get_neighbor(x, y, direction)
    end
    if !fields[x].nil? && !fields[x][y].nil?
      return fields[x][y]
    else
      raise FieldUnavailableException.new(x, y)
    end
  end

  # @return [Array<Field>] A list of fields in given direction up to given
  # distance from the field with given coordinates. The start field is excluded.
  def get_all_in_direction(from_x, from_y, direction, distance = 1)
    (1..distance).to_a.map do |i|
      get_in_direction(
        from_x, from_y, direction, i
      )
    end
  end
end

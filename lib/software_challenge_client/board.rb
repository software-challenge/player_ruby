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
end

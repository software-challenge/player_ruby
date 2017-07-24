# encoding: utf-8
require_relative './util/constants'
require_relative 'game_state'
require_relative 'player'
require_relative 'field_type'
require_relative 'field'

# Ein Spielbrett bestehend aus 65 Feldern.
class Board
  # @!attribute [r] fields
  # @note Besser über die {#field} Methode auf Felder zugreifen.
  # @return [Array<Field>] Ein Feld wird an der Position entsprechend seines
  #   Index im Array gespeichert.
  attr_reader :fields

  # Initializes the board
  def initialize
    @fields = []
  end

  def to_s
    fields.values.map { |f| f.type.key.to_s[0] }.join(' ')
  end

  def ==(other)
    fields.each_with_index do |field, index|
      return false if field != other.field(index)
    end
    true
  end

  def add_field(field)
    fields[field.index] = field
  end

  # Zugriff auf die Felder des Spielfeldes
  #
  # @param index [Integer] Der Index des Feldes
  # @return [Field] Das Feld mit dem gegebenen Index. Falls das Feld nicht
  #   exisitert (weil der Index ausserhalb von 0..64 liegt), wird ein neues
  #   Feld vom Typ INVALID zurückgegeben.
  def field(index)
    fields.fetch(index, Field.new(FieldType::INVALID, index))
  end
end

# encoding: UTF-8
require_relative 'field_type'

# Ein Feld des Spielfelds. Ein Spielfeld ist durch den index eindeutig identifiziert.
# Das type Attribut gibt an, um welchen Feldtyp es sich handelt
class Field
  # @!attribute [rw] type
  # @return [FieldType] der Typ des Feldes
  attr_accessor :type
  # @!attribute [r] index
  # @return [Integer] der Index des Feldes (0 bis 64)
  attr_reader :index

  # Konstruktor
  #
  # @param type [FieldType] Feldtyp
  # @param index [Integer] Index
  def initialize(type, index)
    self.type = type
    @index = index
  end

  def ==(another_field)
    return self.type == another_field.type &&
      self.index == another_field.index
  end

  def to_s
    return "Feld ##{self.index}, Typ = #{self.type}"
  end
end

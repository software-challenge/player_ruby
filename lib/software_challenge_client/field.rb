# encoding: UTF-8
require_relative 'field_type'

# Ein Feld des Spielfelds. Ein Spielfeld ist durch die Koordinaten eindeutig identifiziert.
# Das type Attribut gibt an, um welchen Feldtyp es sich handelt
class Field
  # @!attribute [rw] type
  # @return [FieldType] der Typ des Feldes
  attr_accessor :type
  # @!attribute [r] x
  # @return [Integer] die X-Koordinate des Feldes (0 bis 9, 0 ist ganz links, 9 ist ganz rechts)
  attr_reader :x
  # @!attribute [r] y
  # @return [Integer] die Y-Koordinate des Feldes (0 bis 9, 0 ist ganz unten, 9 ist ganz oben)
  attr_reader :y

  # Konstruktor
  #
  # @param type [FieldType] Feldtyp
  # @param x [Integer] X-Koordinate
  # @param y [Integer] Y-Koordinate
  def initialize(type, x, y)
    @type = type
    @x = x
    @y = y
  end

  def ==(other)
    type == other.type &&
      x == other.x &&
      y == other.y
  end

  def to_s
    "Feld (#{x},#{y}), Typ = #{type}"
  end
end

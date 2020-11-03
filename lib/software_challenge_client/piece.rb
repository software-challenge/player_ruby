# frozen_string_literal: true

# Ein Spielstein mit Ausrichtung, Koordinaten und Farbe
class Piece
  # @!attribute [r] Farbe
  # @return [PlayerColor]
  attr_reader :color

  # @!attribute [r] Form
  # @return [PieceShape]
  attr_reader :kind

  # @!attribute [r] Drehung
  # @return [Rotation]
  attr_reader :rotation

  # @!attribute [r] Ob der Stein an der Y-Achse gespiegelt ist
  # @return [Boolean]
  attr_reader :is_flipped

  # @!attribute [r] Koordinaten
  # @return [Coordinates]
  attr_reader :position

  attr_reader :coords

  def initialize(color, kind, rotation = Rotation::NONE, is_flipped = false, position = Coordinates.origin)
    @color = color
    @kind = kind
    @rotation = rotation
    @is_flipped = is_flipped
    @position = position

    @coords = coords_priv
  end

  def ==(other)
    color == other.color &&
      kind == other.kind &&
      rotation == other.rotation &&
      is_flipped == other.is_flipped &&
      position == other.position
  end

  def to_s
    "#{color.key} #{kind.key} at #{position} rotation #{rotation.key}#{is_flipped ? ' (flipped)' : ''}"
  end

  def inspect
    to_s
  end

  private
  def coords_priv
    kind.transform(@rotation, @is_flipped).transform do |it|
      Coordinates.new(it.x + @position.x, it.y + @position.y)
    end.coordinates
  end
end

# frozen_string_literal: true

# Ein Spielstein mit Ausrichtung, Koordinaten und Farbe
class Piece
  # @!attribute [r] Farbe
  # @return [Color]
  attr_reader :color

  # @!attribute [r] Typ des Spielsteins
  # @return [PieceType]
  attr_reader :type

  # @!attribute [r] Koordinaten
  # @return [Coordinates]
  attr_reader :position

  # @!attribute [r] tower_height
  # @return [Integer] Die Anzahl Spielsteine unter diesem
  attr_reader :tower_height

  # Erstellt einen neuen leeren Spielstein.
  def initialize(color, type, position = Coordinates.origin)
    @color = color
    @type = type
    @position = position
    @tower_height = 0
  end

  # Berechnet die Koordinaten zu denen sich dieser Spielstein bewegen könnte.
  #
  # @return [Array<Coordinates>] Die Zielkoordinaten 
  def target_coords
    ydir = 0
    if color == Color::RED
      ydir = 1
    else
      ydir = -1
    end

    case type
    when PieceType::COCKLE
      coords = [Coordinates.new(-1,ydir), Coordinates.new(1,ydir)]
    when PieceType::GULL
      coords = [Coordinates.new(1,0), Coordinates.new(-1,0), Coordinates.new(0,1), 
        Coordinates.new(0,-1)]
    when PieceType::STARFISH
      coords = [Coordinates.new(0,ydir), Coordinates.new(1,1), Coordinates.new(-1,1), 
        Coordinates.new(1,-1), Coordinates.new(-1,-1)]
    when PieceType::SEAL
      coords = [Coordinates.new(-1,2), Coordinates.new(1,2), Coordinates.new(-2,1), 
        Coordinates.new(2,1), Coordinates.new(-1,-2), Coordinates.new(1,-2), 
        Coordinates.new(-2,-1), Coordinates.new(2,-1)]
    end

    coords.map{ |x| x + position }.to_a
  end

  def ==(other)
    color == other.color &&
      coords == other.coords &&
      type == other.type
  end

  def to_s
    "#{color.key} #{type.key} at #{position}"
  end

  def inspect
    to_s
  end
end

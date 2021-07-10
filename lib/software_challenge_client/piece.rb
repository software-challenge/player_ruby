# frozen_string_literal: true

# Ein Spielstein mit Ausrichtung, Koordinaten und Farbe
class Piece
  # @!attribute [r] Team
  # @return [Team]
  attr_reader :team

  # @!attribute [r] Typ des Spielsteins
  # @return [PieceType]
  attr_reader :type

  # @!attribute [r] Koordinaten
  # @return [Coordinates]
  attr_reader :position

  # @!attribute [r] tower_height
  # @return [Integer] Die Anzahl Spielsteine übereinander inklusive des obersten
  attr_reader :height

  # Erstellt einen neuen Spielstein.
  def initialize(team, type, position = Coordinates.origin, height = 0)
    @team = team
    @type = type
    @position = position
    @height = height
  end

  def set_color(color)
    @team = color.to_t
  end

  # Berechnet die Koordinaten zu denen sich dieser Spielstein bewegen könnte.
  #
  # @return [Array<Coordinates>] Die Zielkoordinaten 
  def target_coords
    ydir = 0
    if team.to_c == Color::RED
      ydir = 1
    else
      ydir = -1
    end

    case type
    when PieceType::Herzmuschel
      coords = [Coordinates.new(-1,ydir), Coordinates.new(1,ydir)]
    when PieceType::Moewe
      coords = [Coordinates.new(1,0), Coordinates.new(-1,0), Coordinates.new(0,1), 
        Coordinates.new(0,-1)]
    when PieceType::Seestern
      coords = [Coordinates.new(0,ydir), Coordinates.new(1,1), Coordinates.new(-1,1), 
        Coordinates.new(1,-1), Coordinates.new(-1,-1)]
    when PieceType::Robbe
      coords = [Coordinates.new(-1,2), Coordinates.new(1,2), Coordinates.new(-2,1), 
        Coordinates.new(2,1), Coordinates.new(-1,-2), Coordinates.new(1,-2), 
        Coordinates.new(-2,-1), Coordinates.new(2,-1)]
    end

    coords.map{ |x| x + position }.to_a
  end

  def set_position(coords)
    @position = coords
  end

  def ==(other)
    !other.nil? &&
      team == other.team &&
      position == other.position &&
      type == other.type
  end

  def to_s
    "#{team.key} #{type.key} at #{position}"
  end

  def inspect
    to_s
  end
end

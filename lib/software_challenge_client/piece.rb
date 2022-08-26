# frozen_string_literal: true

require_relative 'direction'

# Ein Spielstein mit Ausrichtung, Koordinaten und Farbe
class Piece
  include Constants
  
  # @!attribute [rw] Team
  # @return [Team]
  attr_accessor :team

  # @!attribute [rw] Koordinaten
  # @return [Coordinates]
  attr_accessor :position

  # Erstellt einen neuen Spielstein.
  def initialize(team, position = Coordinates.origin)
    @team = team
    @position = position
  end

  # Berechnet die Koordinaten zu denen sich dieser Spielstein bewegen könnte.
  #
  # @return [Array<Coordinates>] Die Zielkoordinaten 
  def target_coords
    coords = []

    Direction.each { |d|
      x = position.d_x
      y = position.d_y
      disp = d.to_vec()

      # doubled taversal
      for i in 0..8 do
        x += disp.x
        y += disp.y
        coords.push(Coordinates.new(x, y))
      end
    }

    coords.map{ |x| Coordinates.doubled_to_oddr(x) }.select{ |c| c.x >= 0 && c.y >=0 && c.x < BOARD_SIZE && c.y < BOARD_SIZE}.to_a
  end

  def ==(other)
    !other.nil? &&
      team == other.team &&
      position == other.position &&
      type == other.type
  end

  # @return [String] Gibt die String-Repräsentation zurück
  def to_s
    "#{team.key} at #{position}"
  end

  # To short string
  # @return [String] Gibt eine Kurzfassung der String-Repräsentation zurück
  def to_ss
    "#{team.key.to_s[0]}"
  end

  def inspect
    to_s
  end
end

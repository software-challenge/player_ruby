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
  attr_accessor :coords

  # Erstellt einen neuen Spielstein.
  def initialize(team, coords = Coordinates.origin)
    @team = team
    @coords = coords
  end

  def ==(other)
    !other.nil? &&
      team == other.team &&
      coords == other.coords
  end

  # @return [String] Gibt die String-Repräsentation zurück
  def to_s
    "#{team.key} at #{coords}"
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

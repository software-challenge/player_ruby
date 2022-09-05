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

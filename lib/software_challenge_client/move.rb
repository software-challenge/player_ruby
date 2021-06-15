# frozen_string_literal: true

require_relative 'has_hints'

# Ein Move repräsentiert eine Bewegung eines Steins auf dem Spielbrett
class Move
  include HasHints

  attr_reader :piece

  attr_reader :target_coords

  # Erstellt ein neuen leeren Legezug.
  def initialize(piece, target_coords)
    @piece = piece
    @target_coords = target_coords
    @hints = []
  end

  def ==(other)
    piece == other.piece
  end

  def to_s
    "Move(#{piece})"
  end
end

# frozen_string_literal: true

require_relative 'has_hints'

# Ein Move repräsentiert eine Bewegung eines Steins auf dem Spielbrett
class Move
  include HasHints

  # @!attribute [r] Koordinaten von dem der Spielstein in diesem Zug wegbewegt wird
  # @return [Coordinates]
  attr_reader :from

  # @!attribute [r] Koordinaten zu denen der Spielstein in diesem Zug hinbewegt wird
  # @return [Coordinates]
  attr_reader :to

  # Erstellt ein neuen leeren Legezug.
  def initialize(from, to)
    @from = from
    @to = to
    @hints = []
  end

  def ==(other)
    piece == other.piece
  end

  def to_s
    "Move(#{piece})"
  end
end

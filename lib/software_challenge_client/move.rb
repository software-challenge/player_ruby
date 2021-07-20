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

  # Erstellt ein neuen Zug.
  def initialize(from, to)
    @from = from
    @to = to
    @hints = []
  end

  def piece(gamestate)
    gamestate.board.field_at(from).piece
  end

  def piece_t(gamestate)
    gamestate.board.field_at(to).piece
  end

  def ==(other)
    from == other.from &&
      to == other.to
  end

  # @return [String] Gibt die String-Repräsentation zurück
  def to_s
    "Move(#{from}->#{to})"
  end
end

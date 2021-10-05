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

  # @!attribute [r] 
  # @return [Integer] Bewertung des Zuges
  attr_reader :value

  # Erstellt ein neuen Zug.
  def initialize(from, to)
    @from = from
    @to = to
    @hints = []
    @value = 1.0
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

  def <=>(other)
    value <=> other.value
  end
  

  # set value to 0, Move should be rejected whenever possible
  def reject
    @value = 0.0
  end

  # set value to Infinity, Move should be selected whenever possible
  def select
    @value = Float::INFINITY
  end

  # multiply value by number, number > 1 increase,
  # number < 0 decrease preference for this Move
  def multiply_by(number)
    @value = @value * number
    self
  end

  # @return [String] Gibt die String-Repräsentation zurück
  def to_s
    "Move(#{from}->#{to}|#{value})"
  end
end

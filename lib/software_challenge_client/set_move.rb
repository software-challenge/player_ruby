# frozen_string_literal: true

require_relative 'has_hints'

# Ein SetMove platziert einen Stein auf dem Spielbrett
class SetMove
  include HasHints

  attr_reader :piece

  # Erstellt ein neuen leeren Legezug.
  def initialize(piece)
    @piece = piece
    @hints = []
  end

  def ==(other)
    piece == other.piece
  end

  def to_s
    "SetMove(#{piece}"
  end
end

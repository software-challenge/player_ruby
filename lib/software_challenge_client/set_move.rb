# frozen_string_literal: true

require_relative 'has_hints'

# Ein SetMove platziert einen Stein auf dem Spielbrett
class SetMove
  include HasHints

  attr_reader :piece

  def initialize(piece)
    @piece = piece
    @hints = []
  end

  def ==(other)
    piece == other.piece
  end
end

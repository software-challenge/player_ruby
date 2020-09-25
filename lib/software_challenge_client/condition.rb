# encoding: UTF-8
# frozen_string_literal: true
require_relative 'player'

# Das Ergebnis eines Spieles. Ist im `GameState#condition` zu finden, wenn das Spiel beendet wurde.
class Condition
  # @!attribute [r] winner
  # @return [Player] Spieler, der das Spiel gewonnen hat.
  attr_reader :winner

  # @!attribute [r] reason
  # @return [String] Grund fuer Spielende
  attr_reader :reason

  # Initializes the winning Condition with a player
  # @param winner [Player] winning player
  # @param reason [String] why the player has won
  def initialize(winner, reason)
    @winner = winner
    @reason = reason
  end

  def draw?
    @winner.nil?
  end
end

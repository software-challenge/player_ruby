# encoding: UTF-8
require_relative 'player'

# Das Ergebnis eines Spieles. Ist im `GameState#condition` zu finden, wenn das Spiel beendet wurde.
class Condition
  # @!attribute [r] winner
  # @return [Player] Spieler, der das Spiel gewonnen hat.
  attr_reader :winner

  # Initializes the winning Condition with a player
  # @param winer [Player] winning player
  def initialize(winner)
    @winner = winner
  end
end

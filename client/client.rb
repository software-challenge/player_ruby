require 'software_challenge_client'

class Client < ClientInterface
  attr_accessor :gamestate

  def initialize
    puts "Zufallsspieler erstellt."
  end

  # gets called, when it's your turn
  def getMove
    puts "Spielstand: #{self.gamestate.pointsForPlayer(self.gamestate.currentPlayer)} - #{self.gamestate.pointsForPlayer(self.gamestate.otherPlayer)}"
    mov = self.randomMove
    unless mov.nil?
      puts 'Zug gefunden: '
      puts mov.to_s
    end
    return mov
  end

  # choose a random move
  def randomMove
    possibleMoves = self.gamestate.getPossibleMoves
    if possibleMoves.length > 0
      return possibleMoves[SecureRandom.random_number(possibleMoves.length)]
    else
      return nil
    end
  end
end

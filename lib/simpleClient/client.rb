# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative '../game_state'
require_relative '../player_color'
require_relative '../move'
require 'pry'
class Client
  attr_accessor :gamestate
  
  def initialize
    
  end
  
  def getMove
    puts "spielstand: #{self.gamestate.pointsForPlayer(self.gamestate.currentPlayer)} - #{self.gamestate.pointsForPlayer(self.gamestate.otherPlayer)}"
    mov = self.randomMove
    if false && gamestate.currentPlayerColor == PlayerColor::RED
        mov = self.fixedMove
    end
    if !mov.nil?
      puts 'Zug gefunden: '
      puts mov.to_s
    end

    mov
  end

def fixedMove
    if self.gamestate.turn < 24
return Move.new((self.gamestate.turn/2) % 2 + 2,self.gamestate.turn)
else
return Move.new(1,23)
end
    end

  def randomMove
    possibleMoves = self.gamestate.getPossibleMoves
    if possibleMoves.length > 0
      return possibleMoves[SecureRandom.random_number(possibleMoves.length)]
    end
    nil
  end
end

# encoding: UTF-8
require 'software_challenge_client'

class Client < ClientInterface

  include Logging

  attr_accessor :gamestate

  def initialize
    logger.level = Logger::INFO
    logger.info "Zufallsspieler erstellt."
  end

  # gets called, when it's your turn
  def getMove
    logger.info "Spielstand: #{self.gamestate.pointsForPlayer(self.gamestate.currentPlayer)} - #{self.gamestate.pointsForPlayer(self.gamestate.otherPlayer)}"
    mov = self.randomMove
    unless mov.nil?
      logger.debug "Zug gefunden: #{mov}"
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

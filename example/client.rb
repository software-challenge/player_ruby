# encoding: UTF-8
require 'software_challenge_client'

class Client < ClientInterface
  include Logging

  attr_accessor :gamestate

  def initialize(logLevel)
    logger.level = logLevel
    logger.info 'Zufallsspieler erstellt.'
  end

  # gets called, when it's your turn
  def getMove
    logger.info "Spielstand: #{gamestate.points_for_player(gamestate.current_player)} - #{gamestate.points_for_player(gamestate.other_player)}"
    mov = random_move
    logger.debug "Zug gefunden: #{mov}" unless mov.nil?
    mov
  end

  # choose a random move
  def random_move
    gamestate_copy = gamestate.deep_clone
    # try all moves in all directions
    Direction.each do |direction|
      move = Move.new
      # turn in that direction
      move.add_action(Turn.new())
    end
    possibleMoves = gamestate.get_possible_moves(2)
    unless possibleMoves.empty?
      possibleMoves[SecureRandom.random_number(possibleMoves.length)]
    end
    nil
  end
end

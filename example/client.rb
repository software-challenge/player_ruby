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
    # try all moves in all directions
    possibleMoves = []
    Direction.each do |direction|
      move = Move.new
      # turn in that direction
      possible_turn = Direction.from_to(gamestate.current_player.direction, direction)
      if possible_turn.direction != 0
        move.add_action(possible_turn)
      end
      move.add_action(Advance.new(1))
      gamestate_copy = gamestate.deep_clone
      begin
        logger.debug("Teste Zug #{move} auf gueltigkeit")
        move.perform!(gamestate_copy, gamestate_copy.current_player)
        logger.debug("Zug #{move} gueltig!.")
        possibleMoves << move
      rescue InvalidMoveException => e
        logger.debug("Zug #{move} ist ungueltig: #{e}")
      end
    end
    unless possibleMoves.empty?
      possibleMoves.sample
    else
      nil
    end
  end
end

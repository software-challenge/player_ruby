# encoding: UTF-8
require 'software_challenge_client'

# This is an example of a client playing the game using the software challenge
# gem.
class Client < ClientInterface
  include Logging

  attr_accessor :gamestate

  def initialize(log_level)
    logger.level = log_level
    logger.info 'Einfacher Spieler wurde erstellt.'
  end

  # gets called, when it's your turn
  def move_requested
    logger.info "Spielstand: #{gamestate.points_for_player(gamestate.current_player)} - #{gamestate.points_for_player(gamestate.other_player)}"
    logger.debug "Board: #{gamestate.board.to_s}"
    move = best_move
    logger.debug "Zug gefunden: #{move}" unless move.nil?
    move
  end

  def best_move
    logger.debug "Berechne zuege fuer Board #{gamestate.board.to_s}"
    possible_moves = GameRuleLogic.possible_moves(gamestate)
    logger.debug "#{possible_moves.size} moegliche Zuege gefunden"
    possible_moves.sample
  end
end

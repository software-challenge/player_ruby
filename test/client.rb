# encoding: UTF-8
# frozen_string_literal: true
require_relative 'software_challenge_client.rb'

# This is an example of a client playing the game using the software challenge
# gem.
class Client < ClientInterface
  include Logging
  include SoftwareChallengeClient

  attr_accessor :gamestate

  def initialize(log_level)
    logger.level = log_level
    logger.info 'Einfacher Spieler wurde erstellt.'
  end

  # gets called, when it's your turn
  def move_requested
    logger.info "Spielstand: #{gamestate.points_for_player(gamestate.current_player)} - #{gamestate.points_for_player(gamestate.other_player)}"
    logger.debug "Board: #{gamestate.board}"
    move = best_move
    logger.debug "Zug gefunden: #{move}" unless move.nil?
    move
  end

  def best_move
    # gamestate.board.add_field(Field.new(5, 0))
    logger.debug "Berechne zuege fuer Board #{gamestate.board}"
    logger.debug 'Felder'
    
    GameRuleLogic.possible_moves(gamestate).sample
  end
end

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
    mov = best_move
    logger.debug "Zug gefunden: #{mov}" unless mov.nil?
    mov
  end

  # choose a move giving the most points
  def best_move
    # try all moves in all directions
    best = nil
    points_for_best = 0
    Direction.each do |direction|
      [1, 2].each do |speed|
        move = Move.new
        if gamestate.current_player.velocity != speed
          move.add_action(Acceleration.new(speed - gamestate.current_player.velocity))
        end
        # turn in that direction
        possible_turn = Direction.from_to(gamestate.current_player.direction, direction)
        if possible_turn.direction != 0
          move.add_action(possible_turn)
        end
        move.add_action(Advance.new(speed))
        gamestate_copy = gamestate.deep_clone
        begin
          logger.debug("Teste Zug #{move} auf gueltigkeit")
          move.perform!(gamestate_copy, gamestate_copy.current_player)
          points_for_move = gamestate_copy.points_for_player(gamestate_copy.current_player)
          logger.debug("Zug #{move} gueltig und wuerde #{points_for_move} Punkte geben!.")
          on_sandbank = gamestate_copy.board.field(gamestate_copy.current_player.x, gamestate_copy.current_player.y).type == FieldType::SANDBANK
          if !on_sandbank && (best.nil? || points_for_move > points_for_best)
            best = move
            points_for_best = points_for_move
          end
        rescue InvalidMoveException => e
          logger.debug("Zug #{move} ist ungueltig: #{e}")
        end
      end
    end
    best
  end
end

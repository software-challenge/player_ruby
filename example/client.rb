# encoding: UTF-8
require 'software_challenge_client'

# This is an example of a client playing the game using the software challenge
# gem.
class Client < ClientInterface
  include Logging

  attr_accessor :gamestate

  # Anzahl der Spielfelder
  NUM_FIELDS = 65

  def initialize(log_level)
    logger.level = log_level
    logger.info 'Einfacher Spieler wurde erstellt.'
  end

  # gets called, when it's your turn
  def move_requested
    logger.info "Spielstand: #{gamestate.points_for_player(gamestate.current_player)} - #{gamestate.points_for_player(gamestate.other_player)}"
    move = best_move
    logger.debug "Zug gefunden: #{move}" unless move.nil?
    move
  end

  def best_move
    possible_moves = gamestate.possible_moves # Enthält mindestens ein Element
    salad_moves = []
    winning_moves = []
    selected_moves = []

    index = gamestate.current_player.index
    possible_moves.each do |move|
      move.actions.each do |action|
        case action.type
          when :advance
            target_field_index = action.distance + index
            if target_field_index == NUM_FIELDS - 1
              winning_moves << move
            elsif gamestate.field(target_field_index).type == FieldType::SALAD
              salad_moves << move
            else
              selected_moves << move
            end
          when :card
            if action.card_type == CardType::EAT_SALAD
              # Zug auf Hasenfeld und danach Salatkarte
              salad_moves << move
              # Muss nicht zusätzlich ausgewählt werden, wurde schon durch Advance ausgewählt
            end
          when :exchange_carrots
            if action.value == 10 &&
                gamestate.current_player.carrots < 30 &&
                index < 40 &&
                !gamestate.current_player.last_non_skip_action.instance_of?(ExchangeCarrots)
              # Nehme nur Karotten auf, wenn weniger als 30 und nur am Anfang und nicht zwei
              # mal hintereinander
              selected_moves << move
            elsif action.value == -10 &&
                gamestate.current_player.carrots > 30 &&
                index >= 40
              # Abgeben von Karotten ist nur am Ende sinnvoll
              selected_moves << move
            end
          when :fall_back
            if index > 56 && # letztes Salatfeld
                 gamestate.current_player.salads > 0
              # Falle nur am Ende (index > 56) zurück, außer du musst noch einen Salat loswerden
              selected_moves << move
            elsif index <= 56 &&
                  gamestate.previous_field_of_type(FieldType::HEDGEHOG, index) &&
                  index - gamestate.previous_field_of_type(FieldType::HEDGEHOG, index).index < 5
              # Falle zurück, falls sich Rückzug lohnt (nicht zu viele Karotten aufnehmen)
              selected_moves << move
              end
          else
            # Füge Salatessen oder Skip hinzu
            selected_moves << move
          end
      end
    end

    if !winning_moves.empty?
      logger.info("Waehle Gewinnzug")
      winning_moves.sample
    elsif !salad_moves.empty?
      # es gibt die Möglichkeit einen Salat zu essen
      logger.info("Waehle Zug zum Salatessen")
      salad_moves.sample
    elsif !selected_moves.empty?
      selected_moves.sample
    else
      possible_moves.sample
    end
  end
end

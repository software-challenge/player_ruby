# encoding: utf-8
require_relative './util/constants'
require_relative 'player'
require_relative 'board'
require_relative 'move'
require_relative 'condition'
require_relative 'field_type'

# The state of a game, as received from the server.
class GameState
  # @!attribute [rw] turn
  # @return [Integer] turn number
  attr_accessor :turn
  # @!attribute [rw] start_player_color
  # @return [PlayerColor] the start-player's color
  attr_accessor :start_player_color
  # @!attribute [rw] current_player_color
  # @return [PlayerColor] the current player's color
  attr_accessor :current_player_color
  # @!attribute [r] red
  # @return [Player] the red player
  attr_reader :red
  # @!attribute [r] blue
  # @return [Player] the blue player
  attr_reader :blue
  # @!attribute [rw] board
  # @return [Board] the game's board
  attr_accessor :board
  # @!attribute [rw] last_move
  # @return [Move] the last move performed
  attr_accessor :last_move
  # @!attribute [rw] condition
  # @return [Condition] the winner and winning reason
  attr_accessor :condition
  # @!attribute [rw] has_to_play_card
  # @return [Boolean] true if the current player has to play a card
  attr_accessor :has_to_play_card
  alias has_to_play_card? has_to_play_card

  extend Forwardable
  def_delegators :@board, :fields

  def initialize
    @current_player_color = PlayerColor::RED
    @start_player_color = PlayerColor::RED
    @board = Board.new
    @has_to_play_card = false
  end

  # adds a player to the gamestate
  #
  # @param player [Player] the player, that will be added
  def add_player(player)
    if player.color == PlayerColor::RED
      @red = player
    elsif player.color == PlayerColor::BLUE
      @blue = player
    end
  end

  # gets the current player
  #
  # @return [Player] the current player
  def current_player
    if current_player_color == PlayerColor::RED
    then red
    else blue
    end
  end

  # gets the other (not the current) player
  #
  # @return [Player] the other (not the current) player
  def other_player
    return blue if current_player_color == PlayerColor::RED
    return red if current_player_color == PlayerColor::BLUE
  end

  # gets the other (not the current) player's color
  #
  # @return [PlayerColor] the other (not the current) player's color
  def other_player_color
    PlayerColor.opponent_color(current_player_color)
  end

  # gets the current round
  #
  # @return [Integer] the current round
  def round
    turn / 2
  end

  # performs a move on the gamestate
  #
  # @param move [Move] the move, that will be performed
  # @param player [Player] the player, who makes the move
  def perform!(move, player)
    move.actions.each do |action|
      action.perform!(self, player)
    end
  end

  # has the game ended?
  #
  # @return [Boolean] true, if the game has allready ended
  def game_ended?
    !condition.nil?
  end

  # gets the game's winner
  #
  # @return [Player] the game's winner
  def winner
    condition.nil? ? nil : condition.winner
  end

  # gets the winning reason
  #
  # @return [String] the winning reason
  def winning_reason
    condition.nil? ? nil : condition.reason
  end

  # calculates a player's points based on the current gamestate
  #
  # @param player [Player] the player, whos point will be calculated
  # @return [Integer] the points of the player
  def points_for_player(player)
    raise 'TODO'
  end

  # @return [Boolean] true if the given field is occupied by the other (not
  #                   current) player.
  def occupied_by_other_player?(field)
    field.index == other_player.index
  end

  def get_previous_field_by_type(type, index)
    return nil if index < 1
    return nil if index >= board.fields.size
    board.fields.slice(0..(index - 1)).reverse.find { |f| f.type == type }
  end

  def get_next_field_by_type(type, index)
    return nil if index >= board.fields.size
    return nil if index < 0
    board.fields.slice((index + 1)..(board.fields.size - 1)).find {|f| f.type == type}
  end

  # Compared with other state.
  def ==(other)
    turn == other.turn &&
      start_player_color == other.start_player_color &&
      current_player_color == other.current_player_color &&
      red == other.red &&
      blue == other.blue &&
      board == other.board &&
      lastMove == other.lastMove &&
      has_to_play_card == other.has_to_play_card &&
      condition == other.condition
  end

  # Create a deep copy of the gamestate. Can be used to perform moves on without
  # changing the original gamestate.
  def deep_clone
    Marshal.load(Marshal.dump(self))
  end

  def set_last_action(action)
    return if action.kind_of? Skip
    current_player.last_non_skip_action = action
  end

  def current_field
    fields[current_player.index]
  end

  def is_first(player)
    if PlayerColor.opponentColor(player.color) == PlayerColor::RED
      player.index > red.index
    else
      player.index > blue.index
    end
  end
end

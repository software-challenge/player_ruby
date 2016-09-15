# encoding: utf-8
require_relative './util/constants'
require_relative 'player'
require_relative 'board'
require_relative 'move'
require_relative 'condition'
require_relative 'field_type'

# The state of a game
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
  # @!attribute [rw] lastMove
  # @return [Move] the last move, that was made
  attr_accessor :lastMove
  # @!attribute [rw] condition
  # @return [Condition] the winner and winning reason
  attr_accessor :condition
  # @!attribute [rw] free_acceleration
  # @return [Boolean] True if the free acceleration for this turn is still
  # available.
  attr_accessor :free_acceleration
  alias free_acceleration? free_acceleration

  # @!attribute [rw] free_turn
  # @return [Boolean] True if the free turning for this turn is still
  # available.
  attr_accessor :free_turn
  alias free_turn? free_turn

  # @!attribute [rw] additional_free_turn_after_push
  # @return [Boolean] True if the free turning for this turn is still
  # available.
  attr_accessor :additional_free_turn_after_push
  alias additional_free_turn_after_push? additional_free_turn_after_push

  def initialize
    @current_player_color = PlayerColor::RED
    @start_player_color = PlayerColor::RED
    @board = Board.new
    @free_acceleration = true
    @free_turn = true
    @additional_free_turn_after_push = false
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
    if current_player_color == PlayerColor::RED
      return blue
    else
      return red
    end
  end

  # gets the other (not the current) player's color
  #
  # @return [PlayerColor] the other (not the current) player's color
  def other_player_color
    PlayerColor.opponent_color(current_player_color)
  end

  # gets the start player
  #
  # @return [Player] the startPlayer
  def startPlayer
    if startPlayer == PlayerColor::RED
      return red
    else
      return blue
    end
  end

  # switches current player
  def switchCurrentPlayer
    @currentPlayer = if currentPlayer.color == PlayerColor::RED
                       blue
                     else
                       red
                     end
  end

  # gets the current round
  #
  # @return [Integer] the current round
  def round
    turn / 2
  end

  # gets all possible moves
  #
  # @return [Array<Move>] a list of all possible moves
  def getPossibleMoves
    enemyFieldType = current_player.color == PlayerColor::RED ? FieldType::BLUE : FieldType::RED
    moves = []
    for x in 0..(Constants::SIZE - 1)
      for y in 0..(Constants::SIZE - 1)
        if board.fields[x][y].ownerColor == PlayerColor::NONE &&
           board.fields[x][y].type != FieldType::SWAMP &&
           board.fields[x][y].type != enemyFieldType
          moves.push(Move.new(x, y))
        end
      end
    end
    moves
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

  # gets a player's points
  #
  # @param player [Player] the player, whos statistics will be returned
  # @return [Integer] the points of the player
  def playerStats(player)
    playerStatsByColor(player.color)
  end

  # gets a player's points by the player's color
  #
  # @param playerColor [PlayerColor] the player's color, whos statistics will be returned
  # @return [Integer] the points of the player
  def playerStatsByColor(playerColor)
    if playerColor == PlayerColor::RED
      return gameStats[0]
    else
      return gameStats[1]
    end
  end

  # gets the players' statistics
  #
  # @return [Array<Integer>] the points for both players
  def gameStats
    stats = Array.new(2, Array.new(1))

    stats[0][0] = red.points
    stats[1][0] = blue.points

    stats
  end

  # get the players' names
  #
  # @return [Array<String>] the names for both players
  def playerNames
    [red.name, blue.name]
  end

  # sets the game-ended condition
  #
  # @param winner [Player] the winner of the game
  # @param reason [String] the winning reason
  def endGame(winner, reason)
    @condition = Condition.new(winner, reason) if condition.nil?
  end

  # has the game ended?
  #
  # @return [Boolean] true, if the game has allready ended
  def gameEnded?
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
  def winningReason
    condition.nil? ? nil : condition.reason
  end

  # calculates a player's points
  #
  #  @param player [Player] the player, whos point will be calculated
  # @return [Integer] the points of the player
  def pointsForPlayer(_player)
    # TODO
    0
  end

  def occupied_by_other_player?(field)
    field.x == other_player.x && field.y == other_player.y
  end

  def ==(other)
    turn == other.turn &&
      start_player_color == other.start_player_color &&
      current_player_color == other.current_player_color &&
      red == other.red &&
      blue == other.blue &&
      board == other.board &&
      lastMove == other.lastMove &&
      free_acceleration == other.free_acceleration &&
      condition == other.condition
  end
end

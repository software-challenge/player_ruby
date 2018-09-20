# encoding: utf-8
require_relative 'debug_hint'

# A move that can be performed in Piranhas.
class Move
  # @!attribute [r] x
  #
  # @return [Integer] X-coordinate of the piranha to move. Column of the the
  # board. Leftmost column is 0, rightmost column is 9.
  attr_reader :x

  # @!attribute [r] y
  #
  # @return [Integer] Y-coordinate of the piranha to move. Row of the the board.
  # Lower row is 0, upper row is 9.
  attr_reader :y

  # @!attribute [r] direction
  #
  # @return [Direction] Direction in which to move.
  attr_reader :direction

  # @!attribute [r] hints
  # @return [Array<DebugHint>] the move's hints
  attr_reader :hints

  # Initializer
  #
  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
    @hints = []
  end

  # adds a hint to the move
  # @param hint [DebugHint] the added hint
  def add_hint(hint)
    @hints.push(hint)
  end

  def ==(other)
    x == other.x && y == other.y && direction == other.direction
  end

  def to_s
    "Move: (#{x},#{y}) #{direction}"
  end

  def from_field
    Coordinates.new(x, y)
  end

  def valid?(gamestate)
    GameRuleLogic.valid_move(self, gamestate.board)
  end

  def perform!(gamestate)
    if GameRuleLogic.valid_move(self, gamestate.board)
      type = gamestate.board.field(x, y).type
      gamestate.board.change_field(x, y, FieldType::EMPTY)
      target = GameRuleLogic.move_target(self, gamestate.board)
      gamestate.board.change_field(target.x, target.y, type)
    else
      raise InvalidMoveException.new('Invalid move', self)
    end
    # change the state to the next turn
    gamestate.last_move = self
    gamestate.turn += 1
    gamestate.switch_current_player
  end

  def target_field(speed)
    case direction
    when Direction::UP
      Coordinates.new(x, y + speed)
    when Direction::UP_RIGHT
      Coordinates.new(x + speed, y + speed)
    when Direction::RIGHT
      Coordinates.new(x + speed, y)
    when Direction::DOWN_RIGHT
      Coordinates.new(x + speed, y - speed)
    when Direction::DOWN
      Coordinates.new(x, y - speed)
    when Direction::DOWN_LEFT
      Coordinates.new(x - speed, y - speed)
    when Direction::LEFT
      Coordinates.new(x - speed, y)
    when Direction::UP_LEFT
      Coordinates.new(x - speed, y + speed)
    end
  end
end

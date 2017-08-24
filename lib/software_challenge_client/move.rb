# encoding: UTF-8
require_relative 'debug_hint'
require_relative 'action'

# A move that can be performed in Mississippi Queen. A move consists of multiple
# actions in a specific order.
class Move
  # @!attribute [r] actions
  #
  # @return [Array<Action>] List of actions which should be performed in this
  #                         move in the order determined by the array order.
  attr_reader :actions

  # @!attribute [r] hints
  # @return [Array<DebugHint>] the move's hints
  attr_reader :hints

  # Initializer
  #
  def initialize(actions = [], hints = [])
    @actions = actions
    @hints = hints
  end

  # adds a hint to the move
  # @param hint [DebugHint] the added hint
  def add_hint(hint)
    @hints.push(hint)
  end

  def ==(other)
    actions.size == other.actions.size &&
      actions.zip(other.actions).map { |a, b| a == b }.all?
  end

  def to_s
    "Move: #{actions}"
  end

  def add_action(action)
    @actions << action
  end

  def add_action_with_order(action, index)
    @actions[index] = action
  end

  def perform!(gamestate)
    raise InvalidMoveException.new(
        "Zug enthält keine Aktionen (zum Aussetzen die Aktion Skip benutzen).",
        self) if @actions.empty?
    @actions.each do |action|
      action.perform!(gamestate)
    end
    raise InvalidMoveException.new(
      'Es muss eine Karte gespielt werden.',
      self) if gamestate.current_player.must_play_card
    # change the state to the next turn
    gamestate.last_move = self
    gamestate.turn += 1
    gamestate.switch_current_player
    # change carrots for next player if on first/second-position-field
    if gamestate.current_field.type == FieldType::POSITION_1 && gamestate.is_first(gamestate.current_player)
      gamestate.current_player.carrots += 10
    end
    if gamestate.current_field.type == FieldType::POSITION_2 && gamestate.is_second(gamestate.current_player)
      gamestate.current_player.carrots += 30
    end
  end
end

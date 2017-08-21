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
  def initialize
    @actions = []
    @hints = []
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

  def perform!(gamestate, current_player)
    @actions.each { |a| a.perform!(gamestate, current_player) }
  end
end

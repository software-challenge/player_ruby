# encoding: utf-8

# An action is a part of a move. A move can have multiple actions. The specific
# actions are inherited from this Action class which should be considered
# abstract/interface.
class Action
  # @return [ActionType] Type of the action.
  def type
    raise 'must be overridden'
  end

  def ==(_other)
    raise 'must be overridden'
  end

  def perform!(_gamestate)
    raise 'must be overridden'
  end

  # Helper to make raising InvalidMoveExceptions easier. It is defined in the
  # Action class instead of the Move class because performing individual actions
  # normally trigger invalid moves, not the move itself.
  #
  # @param message [String] Message why the move is invalid.
  # @return Nothing. Raises an exception.
  def invalid(message)
    raise InvalidMoveException.new(message, self)
  end
end

# Ein Vorwärtszug, um spezifizierte Distanz. Verbrauchte Karroten werden mit k =
# (distance * (distance + 1)) / 2 berechnet (Gaußsche Summe)
class Advance < Action
  attr_reader :distance

  def initialize(distance)
    @distance = distance
  end

  # Perform the action.
  #
  # @param gamestate [GameState] The game state on which the action will be
  # performed. Performing may change the game state. The action is performed for
  # the current player of the game state.
  def perform!(gamestate)
    required_carrots = distance * (distance + 1) / 2
    player = gamestate.current_player
    # check validty
    if required_carrots > player.carrots
      invalid("Nicht genug Karotten für Vorwärtszug um #{distance} Felder.")
    end
    if gamestate.board.field(player.index + distance).type == FieldType::INVALID
      invalid("Zielfeld Vorwärtszug um #{distance} Felder ist nicht vorhanden (das Spielfeld ist nicht gross genug).")
    end
    # perform state changes
    gamestate.current_player.carrots -= required_carrots
    gamestate.current_player.index += distance
  end

  def type
    :advance
  end

  def ==(other)
    other.type == type && other.distance == distance
  end
end

# Play a card.
class Card < Action
  attr_reader :order

  # only for type TAKE_OR_DROP_CARROTS
  attr_reader :value

  attr_reader :card_type

  def initialize(card_type, order = 0, value = nil)
    @card_type = card_type
    @order = order
    @value = value
  end

  # (see Advance#perform!)
  def perform!(gamestate)
  end

  def type
    :card
  end

  def ==(other)
    other.card_type == card_type &&
      (card_type != CardType::TAKE_OR_DROP_CARROTS || (other.value == value)) &&
      other.order == order
  end
end

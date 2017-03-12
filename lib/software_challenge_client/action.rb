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

  def perform!(_gamestate, _current_player)
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

# Accelerate by {#acceleration}. To decelerate, use a negative value.
class Acceleration < Action
  attr_reader :acceleration

  def initialize(acceleration)
    @acceleration = acceleration
  end

  # Perform the action.
  #
  # @param gamestate [GameState] The game state on which the action will be performed. Performing may change the game state.
  # @param current_player [Player] The player for which the action will be performed.
  def perform!(gamestate, current_player)
    new_velocity = current_player.velocity + acceleration
    if new_velocity < 1
      invalid 'Geschwindigkeit darf nicht unter 1 verringert werden.'
    end
    if new_velocity > 6
      invalid 'Geschwindigkeit darf nicht über 6 erhöht werden.'
    end
    acceleration.abs.times do
      if gamestate.free_acceleration?
        gamestate.free_acceleration = false
      elsif current_player.coal.zero?
        invalid 'Nicht genug Kohle zum Beschleunigen.'
      else
        current_player.coal -= 1
      end
    end
    if gamestate.board.field(current_player.x, current_player.y).type == FieldType::SANDBANK
      invalid 'Auf einer Sandbank kann nicht beschleunigt werden.'
    end
    current_player.velocity = new_velocity
    # This works only when acceleration is the first action in a move. The move
    # class has to check that.
    current_player.movement = new_velocity
  end

  def type
    :acceleration
  end

  def ==(other)
    other.type == type && other.acceleration == acceleration
  end
end

# Turn by {#turn_steps}.
class Turn < Action
  # Number of steps to turn. Negative values for turning clockwise, positive for
  # counterclockwise.
  attr_reader :turn_steps

  def initialize(turn_steps)
    @turn_steps = turn_steps
  end

  # (see Acceleration#perform!)
  def perform!(gamestate, current_player)
    invalid 'Drehung um 0 ist ungültig' if turn_steps.zero?
    if gamestate
       .board
       .field(current_player.x, current_player.y)
       .type == FieldType::SANDBANK
      invalid 'Drehung auf Sandbank nicht erlaubt'
    end
    needed_coal = direction.abs
    needed_coal -= 1 if gamestate.free_turn?
    if needed_coal > 0 && gamestate.additional_free_turn_after_push?
      needed_coal -= 1
      gamestate.additional_free_turn_after_push = false
    end
    if needed_coal > current_player.coal
      invalid "Nicht genug Kohle für Drehung um #{turn_steps}. "\
              "Habe #{current_player.coal}, brauche #{needed_coal}."
    end

    current_player.direction =
      Direction.get_turn_direction(current_player.direction, turn_steps)
    current_player.coal -= [0, needed_coal].max
    gamestate.free_turn = false
  end

  def type
    :turn
  end

  def ==(other)
    other.type == type && other.turn_steps == turn_steps
  end
end

# Go forward in the current direction by {#distance}. When on a sandbank, a
# value of -1 to go backwards is also legal.
class Advance < Action
  attr_reader :distance

  def initialize(distance)
    @distance = distance
  end

  # (see Acceleration#perform!)
  def perform!(gamestate, current_player)
    invalid 'Bewegung um 0 ist unzulässig.' if distance.zero?
    if distance < 0 && gamestate.board.field(current_player.x, current_player.y).type != FieldType::SANDBANK
      invalid 'Negative Bewegung ist nur auf Sandbank erlaubt.'
    end
    begin
      fields = gamestate.board.get_all_in_direction(
        current_player.x, current_player.y, current_player.direction, distance
      )
    rescue FieldUnavailableException => e
      invalid "Feld (#{e.x}, #{e.y}) ist nicht vorhanden"
    end
    # test if all fields are passable
    if fields.any?(&:blocked?)
      invalid 'Der Weg ist blockiert.'
    end
    # Test if movement is enough.
    req_movement = required_movement(gamestate, current_player)
    if req_movement > current_player.movement
      invalid 'Nicht genug Bewegungspunkte.'
    end
    # test if opponent is not on fields over which is moved
    if fields[0...-1].any? { |f| gamestate.occupied_by_other_player? f }
      invalid 'Man darf nicht über den Gegner fahren.'
    end
    # test if moving over sandbank
    if fields[0...-1].any? { |f| f.type == FieldType::SANDBANK }
      invalid 'Die Bewegung darf nur auf einer Sandbank enden, '\
              'nicht über sie hinaus gehen.'
    end
    target_field = fields.last
    current_player.x = target_field.x
    current_player.y = target_field.y

    if target_field.type == FieldType::SANDBANK
      current_player.movement = 0
      current_player.velocity = 1
    else
      current_player.movement -= req_movement
    end

    # test for passenger
    if current_player.velocity == 1
      required_field_for_direction = {
        Direction::RIGHT.key=> FieldType::PASSENGER3.key,
        Direction::UP_RIGHT.key=> FieldType::PASSENGER4.key,
        Direction::UP_LEFT.key=> FieldType::PASSENGER5.key,
        Direction::LEFT.key=> FieldType::PASSENGER0.key,
        Direction::DOWN_LEFT.key=> FieldType::PASSENGER2.key,
        Direction::DOWN_RIGHT.key=> FieldType::PASSENGER1.key
      }
      Direction.each do |direction|
        begin
          neighbor = gamestate.board.get_in_direction(current_player.x, current_player.y, direction)
          if neighbor.type.key == required_field_for_direction[direction.key]
            if current_player.passengers < 2
              current_player.passengers += 1
              neighbor.type = FieldType::BLOCKED
            end
          end
        rescue FieldUnavailableException
          # neighbor did not exist, that is okay
        end
      end
    end

  end

  # returns the required movement points to perform this action
  def required_movement(gamestate, current_player)
    gamestate.board.get_all_in_direction(current_player.x, current_player.y, current_player.direction, distance).map do |field|
      # pushing costs one more movement
      on_opponent = field.x == gamestate.other_player.x && field.y == gamestate.other_player.y
      case field.type
      when FieldType::WATER, FieldType::GOAL, FieldType::SANDBANK
        on_opponent ? 2 : 1
      when FieldType::LOG
        on_opponent ? 3 : 2
      end
    end.reduce(:+)
  end

  def type
    :advance
  end

  def ==(other)
    other.type == type && other.distance == distance
  end
end

# Push the opponent in {#direction}
class Push < Action
  # @return [Direction] the direction where to push.
  attr_reader :direction

  # @param direction [Direction]
  def initialize(direction)
    @direction = direction
  end

  # (see Acceleration#perform!)
  def perform!(gamestate, current_player)
    if gamestate.other_player.x != current_player.x ||
       gamestate.other_player.y != current_player.y
      invalid 'Abdrängen ist nur auf dem Feld des Gegners möglich.'
    end
    other_player_field =
      gamestate.board.field(gamestate.other_player.x, gamestate.other_player.y)
    if other_player_field.type == FieldType::SANDBANK
      invalid 'Abdrängen von einer Sandbank ist nicht erlaubt.'
    end
    if direction == Direction.get_turn_direction(current_player.direction, 3)
      invalid 'Man darf nicht hinter sich abdrängen.'
    end

    target_x, target_y =
      gamestate.board.get_neighbor(
        gamestate.other_player.x,
        gamestate.other_player.y,
        direction
      )

    required_movement = 1
    if gamestate.board.field(target_x, target_y).type == FieldType::LOG
      required_movement += 1
    end
    if required_movement > current_player.movement
      invalid 'Nicht genug Bewegungspunkte zum abdrängen '\
              "(brauche #{required_movement})"
    end

    current_player.movement -= required_movement

    gamestate.other_player.x = target_x
    gamestate.other_player.y = target_y
  end

  def type
    :push
  end

  def ==(other)
    other.type == type && other.direction == direction
  end
end

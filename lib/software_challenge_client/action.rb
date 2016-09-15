# encoding: utf-8

# An action is a part of a move.
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

  def invalid(message)
    raise InvalidMoveException.new(message, self)
  end
end

class Acceleration < Action
  attr_reader :acceleration

  def initialize(acceleration)
    @acceleration = acceleration
  end

  def perform!(gamestate, current_player)
    new_velocity = current_player.velocity + acceleration
    if new_velocity < 1
      invalid 'Geschwindigkeit darf nicht unter 1 verringert werden'
    end
    if new_velocity > 6
      invalid 'Geschwindigkeit darf nicht über 6 erhöht werden.'
    end
    acceleration.times do
      if gamestate.free_acceleration?
        gamestate.free_acceleration = false
      elsif current_player.coal.zero?
        invalid 'Nicht genug Kohle zum Beschleunigen.'
      else
        current_player.coal -= 1
      end
    end
    current_player.velocity = new_velocity
  end

  def type
    :acceleration
  end

  def ==(other)
    other.type == type && other.acceleration == acceleration
  end
end

class Turn < Action
  attr_reader :direction

  def initialize(direction)
    @direction = direction
  end

  def perform!(gamestate, current_player)
    invalid 'Drehung um 0 ist ungültig' if direction.zero?
    if gamestate
       .board
       .fields[current_player.x][current_player.y]
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
      invalid "Nicht genug Kohle für Drehung um #{direction}. "
              "Habe #{current_player.coal}, brauche #{needed_coal}."
    end

    # order of directions is equal to counterclockwise turning
    new_direction = Direction.find_by_ord(
      (current_player.direction.ord + direction) % 6
    )

    current_player.direction = new_direction
    current_player.coal -= [0, needed_coal].max
    gamestate.free_turn = false
  end

  def type
    :turn
  end

  def ==(other)
    other.type == type && other.direction == direction
  end
end

class Advance < Action
  attr_reader :distance

  def initialize(distance)
    @distance = distance
  end

  def perform!(gamestate, current_player)
    invalid 'Bewegung um 0 ist unzulässig.' if distance.zero?
    if distance < 0 && gamestate.board.fields[current_player.x][current_player.y].type != FieldType::SANDBANK
      invalid 'Negative Bewegung ist nur auf Sandbank erlaubt.'
    end
    fields = gamestate.board.get_all_in_direction(
      current_player.x, current_player.y, current_player.direction, distance
    )
    # test if all fields are passable
    if fields.any?(&:blocked?)
      invalid 'Der Weg ist blockiert.'
    end
    # Test if movement is enough. Note that this does not mean that the player
    # has enough movement points for the *whole* move.
    if required_movement(gamestate, current_player) > current_player.velocity
      invalid 'Nicht genug Bewegungspunkte.'
    end
    # test if opponent is not on fields over which is moved
    if fields[0...-1].any? { |f| gamestate.occupied_by_other_player? f }
      invalid 'Man darf nicht über den Gegner fahren.'
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
      when FieldType::LOGS
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

class Push < Action
  attr_reader :direction

  def initialize(direction)
    @direction = direction
  end

  def type
    :push
  end

  def ==(other)
    other.type == type && other.direction == direction
  end
end
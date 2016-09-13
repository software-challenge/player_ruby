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
    if distance.zero?
      raise InvalidMoveException, 'Bewegung um 0 ist unzulässig.'
    end
    if distance < 0 && current_player.field.type == FieldType::SANDBANK
      raise InvalidMoveException, 'Negative Bewegung ist nur auf Sandbank erlaubt.'
    end
    fields = (1..distance).to_a.map do |i|
      gamestate.board.get_in_direction(
        current_player.x,
        current_player.y,
        current_player.direction,
        i
      )
    end
    # test if all fields are passable
    if fields.any?(&:blocked?)
      raise InvalidMoveException.new('Der Weg ist blockiert.', self)
    end
    movement = current_player.velocity
    fields.each do |field|
      case field.type
      when FieldType::WATER, FieldType::GOAL
        movement -= 1
      when FieldType::SANDBANK
        movement = 0
      when FieldType::LOGS
        movement -= 2
      end
      if field.x == gamestate.other_player.x && field.y == gamestate.other_player.y
        # pushing costs one more movement
        movement -= 1
      end
    end
    # test if movement is enough
    # test if opponent is not on fields over which is moved
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

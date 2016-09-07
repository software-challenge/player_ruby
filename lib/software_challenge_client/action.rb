# encoding: UTF-8

# An action is a part of a move.
class Action
  # @return [ActionType] Type of the action.
  def type
    raise 'must be overridden'
  end

  def ==(_other)
    raise 'must be overridden'
  end
end

class Acceleration < Action
  attr_reader :acceleration

  def initialize(acceleration)
    @acceleration = acceleration
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

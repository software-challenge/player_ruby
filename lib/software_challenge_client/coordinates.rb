# frozen_string_literal: true

class Coordinates
  attr_reader :x
  attr_reader :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

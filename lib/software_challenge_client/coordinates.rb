# coding: utf-8
# frozen_string_literal: true

# Ein Koordinatenpaar für ein zweidimensionales Koordinatensystem.
class Coordinates

  # X-Koordinate
  attr_reader :x
  # Y-Koordinate
  attr_reader :y

  # Erstellt ein neues Koordinatenpaar aus X- und Y-Koordinate.
  def initialize(x, y)
    @x = x
    @y = y
  end
end

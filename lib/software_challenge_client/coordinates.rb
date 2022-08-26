# frozen_string_literal: true

# Einfache kartesische Koordinaten
class Coordinates
  include Comparable
  attr_reader :x, :y
  attr_reader :d_x, :d_y

  # Erstellt neue leere Koordinaten.
  def initialize(x, y)
    @x = x
    @y = y

    c = Coordinates.oddr_to_doubled(x, y)
    @d_x = c.x
    @d_y = c.y
  end

  def ==(other)
    x == other.x && y == other.y
  end

  # Gibt die Ursprungs-Koordinaten (0, 0) zurück.
  def self.origin
    Coordinates.new(0, 0)
  end

  # Konvertiert c in das doubled Koordinatensystem.
  # @param c [Coordinates] Koordinaten aus dem odd-r System
  def self.oddr_to_doubled(c)
    Coordinates.new(c.x * 2 + (c.y % 2 == 1 ? 1 : 0), c.y)
  end

  # Konvertiert c in das odd-r Koordinatensystem.
  # @param c [Coordinates] Koordinaten aus dem doubled System
  def self.doubled_to_oddr(c)
    Coordinates.new(c.x / 2 - (c.y % 2 == 1 ? 1 : 0), c.y)
  end

  def <=>(other)
    xComp = x <=> other.x
    yComp = y <=> other.y
    if xComp == 0
      yComp
    else
      xComp
    end
  end

  def +(other)
    Coordinates.new(x + other.x, y + other.y)
  end

  # Gibt eine textuelle Repräsentation der Koordinaten aus.
  def to_s
    "(#{x}, #{y})"
  end

  def inspect
    to_s
  end
end

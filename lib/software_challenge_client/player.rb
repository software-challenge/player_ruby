# encoding: UTF-8
# frozen_string_literal: true

# Ein Spieler
class Player
  # @!attribute [r] name
  # @return [String] der Name des Spielers, hat keine Auswirkungen auf das Spiel
  attr_reader :name

  # @!attribute [r] color
  # @return [PlayerColor] die Farbe des Spielers, Rot, Blau, Gelb, Grün
  attr_reader :color

  # Konstruktor
  # @param color [PlayerColor] Farbe
  # @param name [String] Name
  def initialize(color, name)
    @color = color
    @name = name
  end

  def ==(other)
    color == other.color
  end
end

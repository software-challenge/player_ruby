# encoding: UTF-8
# frozen_string_literal: true

# Ein Spieler
class Player
  # @!attribute [r] name
  # @return [String] der Name des Spielers, hat keine Auswirkungen auf das Spiel
  attr_reader :name

  # @!attribute [r] color
  # @return [Color] erster (Color::RED) oder zweiter (Color::BLUE) Spieler
  attr_reader :color

  # @!attribute [r] amber
  # @return [Integer] Anzahl Bernsteine die dieser Spieler gesammelt hat
  attr_reader :amber

  # Konstruktor
  # @param type [Color] Rot oder blau
  # @param name [String] Name
  def initialize(type, name)
    @type = type
    @name = name
    @amber = 0
  end

  def ==(other)
    color == other.color
  end
end

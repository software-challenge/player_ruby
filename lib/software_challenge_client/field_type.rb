# encoding: utf-8

require 'typesafe_enum'
# Zahl- und Flaggenfelder Die veränderten Spielregeln sehen nur noch die
# Felder 1,2 vor. Die Positionsfelder 3 und 4 wurden in Möhrenfelder
# umgewandelt, und (1,5,6) sind jetzt Position-1-Felder.
class FieldType < TypesafeEnum::Base
  new :POSITION_1, '1'
  new :POSITION_2, '2'
  # Igelfeld
  new :HEDGEHOG, 'I'
  # Salatfeld
  new :SALAD, 'S'
  # Karottenfeld
  new :CARROT, 'C'
  # Hasenfeld
  new :HARE, 'H'
  # außerhalb des Spielfeldes
  new :INVALID, 'X'
  # Zielfeld
  new :GOAL, 'G'
  # Startfeld
  new :START, '0'
end

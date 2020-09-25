# encoding: utf-8
# frozen_string_literal: true

require 'typesafe_enum'
# Der Typ eines Spielsteins. Es gibt folgende Typen:
# - BEE
# - BEETLE
# - GRASSHOPPER
# - SPIDER
# - ANT
#
# Zugriff z.B. mit PieceType::BEE
class PieceType < TypesafeEnum::Base
  new :BEE, 'Q'
  new :BEETLE, 'B'
  new :GRASSHOPPER, 'G'
  new :SPIDER, 'S'
  new :ANT, 'A'
end

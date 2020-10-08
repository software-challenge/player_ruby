# frozen_string_literal: true

require 'typesafe_enum'

# Erster oder zweiter Spieler
class PlayerType < TypesafeEnum::Base
  new :ONE
  new :TWO
end

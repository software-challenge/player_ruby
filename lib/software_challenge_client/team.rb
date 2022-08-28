# frozen_string_literal: true

require 'typesafe_enum'

# Erster oder zweiter Spieler:
#
#   ONE
#   TWO
#
# Zugriff z.B. mit Team::ONE
class Team < TypesafeEnum::Base
  new :ONE, 'ONE'
  new :TWO, 'TWO'
end

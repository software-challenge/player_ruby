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

  # @return [Team] Das Team, was nicht t ist.
  def other_team(t)
    if t == :ONE
      :TWO
    else
      :ONE
    end
  end
end

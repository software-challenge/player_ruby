# encoding: utf-8

require 'typesafe_enum'
class CardType < TypesafeEnum::Base
	# Nehme Karotten auf, oder leg sie ab
  new :TAKE_OR_DROP_CARROTS
	# Iß sofort einen Salat
  new :EAT_SALAD
	# Falle eine Position zurück
  new :FALL_BACK
	# Rücke eine Position vor
  new :HURRY_AHEAD
end

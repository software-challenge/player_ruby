# encoding: utf-8
# frozen_string_literal: true

require 'typesafe_enum'
# Ausrichtung einer Linie auf dem Spielbrett. Mögliche Werte sind:
# - HORIZONTAL
# - VERTICAL
# - RISING_DIAGONAL
# - FALLING_DIAGONAL

class LineDirection < TypesafeEnum::Base
  new :HORIZONTAL
  new :VERTICAL
  new :RISING_DIAGONAL
  new :FALLING_DIAGONAL
end

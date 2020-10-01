# encoding: utf-8
# frozen_string_literal: true
# piece color constants
require 'typesafe_enum'

# Die Spielsteinfarben. BLUE, YELLOW, RED und GREEN
class Color < TypesafeEnum::Base
  new :BLUE, 'B'
  new :YELLOW, 'Y'
  new :RED, 'R'
  new :GREEN, 'G'
end

# encoding: utf-8

require 'typesafe_enum'
class LineDirection < TypesafeEnum::Base
  new :HORIZONTAL
  new :VERTICAL
  new :RISING_DIAGONAL
  new :FALLING_DIAGONAL
end

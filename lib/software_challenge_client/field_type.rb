# encoding: utf-8

require 'typesafe_enum'
class FieldType < TypesafeEnum::Base
  new :EMPTY, '_'
  new :RED, 'R'
  new :BLUE, 'B'
  new :OBSTRUCTED, 'O'
end

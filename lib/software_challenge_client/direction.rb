# encoding: utf-8

require 'typesafe_enum'
class Direction < TypesafeEnum::Base
  new :UP
  new :UP_RIGHT
  new :RIGHT
  new :DOWN_RIGHT
  new :DOWN
  new :DOWN_LEFT
  new :LEFT
  new :UP_LEFT
end

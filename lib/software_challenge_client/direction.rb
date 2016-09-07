# encoding: UTF-8

require 'typesafe_enum'
class Direction < TypesafeEnum::Base
  new :RIGHT
  new :UP_RIGHT
  new :UP_LEFT
  new :LEFT
  new :DOWN_LEFT
  new :DOWN_RIGHT
end

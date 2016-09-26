# encoding: UTF-8

require 'typesafe_enum'
class FieldType < TypesafeEnum::Base
  new :WATER
  new :BLOCKED
  new :PASSENGER0
  new :PASSENGER1
  new :PASSENGER2
  new :PASSENGER3
  new :PASSENGER4
  new :PASSENGER5
  new :SANDBANK
  new :LOG
  new :GOAL
end

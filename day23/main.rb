require '../advent.rb'
require 'set'

@input = Input.new(20)

clockwise = "32415".split.map(&:to_i)
current_cup = clockwise[0]

def move
  clockwise.slice(1..3)
  destination = clockwise[clockwise.index(current_cup) - 1]
  

end
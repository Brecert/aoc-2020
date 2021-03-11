require '../advent.rb'

@input = Input.new(01).ints.sort

p @input.combination(3).count
require '../advent.rb'

@input = Input.new(01).ints.sort

puts "Part 1: #{@input.combination(2).find{|c| c.sum === 2020}.reduce :*}"
puts "Part 2: #{@input.combination(3).find{|c| c.sum === 2020}.reduce :*}"
require '../advent.rb'

@input = Input.new(05).lines.map{|l| l.tr('FBLR', '0101').to_i 2 }.sort

puts "Part 1: #{@input.max}"
puts "Part 2: #{@input.each_cons(2).find{|a, b| b - a != 1 }[0] + 1}"
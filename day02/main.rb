require '../advent.rb'

@input = Input.new(02).lines.map {|l| a,b,c,d = l.scan /\w+/; [a.to_i, b.to_i, c, d] }

puts "Part 1: #{@input.count{|a, b, c, d| (a..b).include? d.count c}}"
puts "Part 2: #{@input.count{|a, b, c, d| (d[a-1] == c) != (d[b-1] == c)}}"
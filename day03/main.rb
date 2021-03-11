require '../advent.rb'

@input = Input.new(03).lines
@width = @input[0].size

def slope slope_x, slope_y
  (0...@input.size).step(slope_y).count do |y|
    @input[y][y * slope_x % @width] === '#'
  end
end

puts "Part 1: #{slope 3, 1}"
puts "Part 2: #{[[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]].map{|e| slope *e}.reduce :*}"
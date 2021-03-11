require '../advent.rb'
require 'set'

def edges pos
  [-1, 0, 1]
    .repeated_permutation(pos.size).uniq
    .filter{|a| !a.all? 0 }
    .map{|a| a.zip(pos).map(&:sum) }
end

def existing_edges possible, points
  possible.filter{|x| points.include? x}
end

def simulator points
  points = Set.new points
  Enumerator.new do |y|
    loop {
      y << points = points.reduce(Set[]) do |active_points, point|
        e = edges point
        l = e.filter{|x| points.include? x}.size
        active_points << point if l == 2 or l == 3
        active_points += e.filter{|edge| edges(edge).filter{|x| points.include? x}.size == 3}
      end
    }
  end
end


@input = Input.new(17).lines
points3 = @input.flat_map.with_index{|row, y| row.chars.each_with_index.filter{|v,_| v == '#'}.map{|block, x| [x, y, 0]}}
points4 = points3.dup.map{|a| a.dup << 0}

p simulator(points3).lazy.drop(5).next.size
p simulator(points4).lazy.drop(5).next.size
require '../advent.rb'
require 'matrix'

@input = Input.new(12).lines.map{|l| m = l.match /(\w)(\d+)/; [m[1], m[2].to_i]}

@cur = 1
@dirs = %w[N E S W]
@pos1 = [0, 0, 0, 0]
@pos2 = [0, 0]
@point = [1, 10, 0, 0]

def rotate n
  @cur = (@cur + (n / 90)) % 4
  @point = @point.rotate -((n / 90) % 4)
end

def distance arr
  n, e, s, w = arr
  [(n - s), (e - w)]
end

def match action, n
  case action
  when "N", "E", "S", "W"
    @pos1[@dirs.find_index action] += n
    @point[@dirs.find_index action] += n
  when "L"
    rotate -n
  when "R"
    rotate n
  when "F"
    @pos1[@cur] += n
    slope = distance @point
    @pos2 = [@pos2[0] + (slope[0] * n), @pos2[1] + (slope[1] * n)] 
  end
end

@input.map{|a,b| match a, b}
p distance(@pos1).map(&:abs).sum
p @pos2.map(&:abs).sum
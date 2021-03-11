require '../advent.rb'
require 'matrix'
require 'set'

module Direction
  def self.directions
    [:above, :right, :below, :left]
  end
end

module MatrixActions
  refine Matrix do
    def flip axis
      case axis
      when :x
        Matrix[*self.row_vectors.map{|v| v.to_a.reverse}]
      when :y
        Matrix[*self.column_vectors.reverse]
      else
        raise "Invalid flip axis: #{axis}"
      end
    end

    # rotate by count of 90
    def rotate count = 1
      (count % 4).times.reduce(self) do |last| 
        Matrix[*last.transpose.flip(:x)]
      end
    end
  end
end

using MatrixActions

class Tile
  attr_accessor :id, :body

  def initialize id, body
    @id = id
    @body = body
  end

  def edge_above; @body.row(0); end
  def edge_right; @body.column(@body.column_count - 1); end
  def edge_below; @body.row(@body.row_size - 1); end
  def edge_left; @body.column(0); end

  def trim_edges
    @body.minor(1...@body.row_count, 1...@body.column_count)
  end
  
  def edges
    Enumerator.new do |y|
      y << self.edge_above
      y << self.edge_right
      y << self.edge_below
      y << self.edge_left
    end
  end

  def flip axis = :y
    Tile.new @id, @body.flip(axis)
  end

  def rotate count
    Tile.new @id, @body.rotate(count)
  end

  def states
    Enumerator.new do |y|
      (0..3).each {|i| y << self.rotate(i) } 
      (0..3).each {|i| y << self.flip.rotate(i) } 
      (0..3).each {|i| y << self.rotate(i).flip } 
    end
  end

  def get_edge dir
    self.method("edge_#{dir}").call
  end

  def has_match? tile, dir
    self.edges.count do |from_edge|
      from_edge == tile.get_edge(dir) || from_edge.to_a == tile.get_edge(dir).to_a.reverse
    end > 0
  end

  def matches? tile
    Direction.directions.count {|dir| self.has_match? tile, dir } > 0
  end

  def matches_tile? tile, dir
    case dir
    when :above then self.get_edge("above") == tile.get_edge("below")
    when :below then self.get_edge("below") == tile.get_edge("above")
    when :right then self.get_edge("right") == tile.get_edge("left")
    when :left then self.get_edge("left") == tile.get_edge("right")
    else raise "Err"
    end
  end

  def find_match neighbors
    self.states.find{|state|
      neighbors
        .filter{|dir,tile| !tile.nil?}
        .any?{|dir, tile| !self.matches_tile? tile, dir}
    }
  end
end

@input = Input.new(20).text.split("\n\n")
@tiles = @input.map do |section|
  chunks = section.lines(chomp: true)
  id, = chunks[0].scan(/\d+/)
  blocks = Matrix[*chunks[1..].map{|strip| strip.chars}]
  Tile.new id.to_i, blocks
end

corners = @tiles.filter{|tile| 
  @tiles
    .filter{|t| t.id != tile.id }
    .count{|t| tile.matches? t } == 2
}

raise "More than 4 corners!" if corners.count > 4

puts "Part 1: #{corners.map(&:id).map(&:to_i).reduce(&:*)}"

@tile_map = @tiles.map{|tile| [tile.id, tile]}.to_h

positions = {}

start = @tile_map.delete(corners[0].id)
width = @tiles[0].get_edge(:above).size

def find_match tile, dir
  @tile_map.each_value{|t| t.edges.include? tile.get_edge dir }
end

start = start.states.find{|state| find_match(state, :right) && find_match(state, :below) }



# positions[[0, 0]] = start

# width.times do |x|
#   width.times do |y|
#     next if positions.has_key? [x, y]
#     neighbors = {
#       above: positions[[x, y - 1]],
#       below: positions[[x, y + 1]],
#       right: positions[[x + 1, y]],
#       left: positions[[x - 1, y]]
#     }
#     @tile_map.filter{|id, tile|
#       if state = tile.find_match(neighbors)
#         pp "[#{x}, #{y}] State: #{state}"
#         @tile_map.delete tile.id
#         positions[[x, y]] = state
#       end
#     }
#   end
# end

# pp positions
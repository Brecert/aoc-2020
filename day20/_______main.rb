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
        Matrix[*self.row_vectors.reverse]
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

    def print
      puts self.row_vectors.to_a.join("\n")
      puts
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

  def edge_above; @body.row(0).to_a; end
  def edge_right; @body.column(@body.column_count - 1).to_a; end
  def edge_below; @body.row(@body.row_size - 1).to_a; end
  def edge_left; @body.column(0).to_a; end

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

  def variants
    Enumerator.new do |y|
      (0..3).each {|i| y << self.rotate(i) } 
      (0..3).each {|i| y << self.flip.rotate(i) } 
      (0..3).each {|i| y << self.rotate(i).flip } 
    end
  end

  def get_edge dir
    self.method("edge_#{dir}").call
  end

  def match_tile? tile, direction
    case direction
    when :above then self.get_edge(:above) == tile.get_edge(:below)
    when :below then self.get_edge(:below) == tile.get_edge(:above)
    when :right then self.get_edge(:right) == tile.get_edge(:left)
    when :left  then self.get_edge(:left)  == tile.get_edge(:right)
    end
  end

  def print
    @body.print
  end

  def has_match? tile_map, dir
    tile_map.values.any? {|tile|
      tile.edges.map(&:to_a).include?(self.get_edge(dir).to_a) || 
      tile.edges.map(&:to_a).include?(self.get_edge(dir).to_a.reverse)
    }
  end

  def right_and_bottom_match? tile_map
    self.has_match?(tile_map, :right) && self.has_match?(tile_map, :below)
  end

  def find_initial_alignment tile_map
    state = self
    loop {
      state = state.rotate 1
      if state.right_and_bottom_match? tile_map
        return state
      end
    }
  end

  def match? neighbors
    self.states.find do |state|
      neighbors
        .filter{|k,v| !v.nil? }
        .all?{|dir,tile| self.match_tile? tile, dir }
    end
  end


  def matches? tile
    self.edges.any? {|from_edge|
      tile.edges.any? {|to_edge| 
        from_edge == to_edge || flipped = from_edge.to_a == to_edge.to_a.reverse
      }
    }
  end

  def find_match neighbors
    self.variants.find do |variant|
      neighbors.filter{|k,v| not v.nil?}.all? do |direction, neighbor|
        self.match_tile? neighbor, direction
      end
    end
  end
end

INPUT = Input.new(20).text.split("\n\n")
TILES = INPUT.map do |section|
  chunks = section.lines(chomp: true)
  id, = chunks[0].scan(/\d+/)
  blocks = Matrix[*chunks[1..].map{|strip| strip.chars}]
  Tile.new id.to_i, blocks
end
SIZE = Math.sqrt(TILES.count).to_i

corners = TILES.filter{|tile| TILES.filter{|t| t.id != tile.id }.count{|t| tile.matches? t } == 2 }

raise "More than 4 corners!" if corners.count > 4
puts "Part 1: #{corners.map(&:id).reduce(&:*)}"

@tile_map = TILES.map{|tile| [tile.id, tile]}.to_h
@position = {}

@position[[0, 0]] = @tile_map.delete(corners[0].id)
@position[[0, 0]] = @position[[0, 0]].find_initial_alignment @tile_map

p @position[[0, 0]].get_edge :above
p @position[[0, 0]].get_edge :right
p @position[[0, 0]].get_edge :below
p @position[[0, 0]].get_edge :left

SIZE.times do |y|
  SIZE.times do |x|
    next if @position.has_key? [x, y]

    neighbors = {
      above: @position[[x, y - 1]],
      below: @position[[x, y + 1]],
      right: @position[[x + 1, y]],
       left: @position[[x - 1, y]],
    }

    @tile_map.each do |id, tile|
      puts "[#{x} #{y}] #{id}"

      if variant = tile.find_match(neighbors)
        p "FIRST: #{id}"

        @tile_map.delete id
        @position[[x, y]] = variant
      end
    end
  end
end

p @position
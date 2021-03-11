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
  end

  def view
    puts matrix.row_vectors.to_a.join("\n")
    puts
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

  def match? tile, dir
    case dir
    when :above then self.get_edge(:above) == tile.get_edge(:below)
    when :below then self.get_edge(:below) == tile.get_edge(:above)
    when :right then self.get_edge(:right) == tile.get_edge(:left)
    when :left then self.get_edge(:left) == tile.get_edge(:right)
    end
  end

  def matche tile
    self.edges.flat_map.with_index {|from_edge, from_dir|
      tile.edges.filter_map.with_index {|to_edge, to_dir|
        if from_edge == to_edge || flipped = from_edge.to_a == to_edge.to_a.reverse
          { from_dir: from_dir, to_dir: to_dir, flipped: !flipped.nil? }
        end
      }
    }
  end

  def matches neighbors
    self.states.find do |state|
      neighbors.filter{|dir,tile| !tile.nil? }.all? {|dir, tile| self.match?(tile, dir) }
    end
  end
end

@input = Input.new(20).text.split("\n\n")
@tiles = @input.map do |section|
  chunks = section.lines(chomp: true)
  id, = chunks[0].scan(/\d+/)
  blocks = Matrix[*chunks[1..].map{|strip| strip.chars}]
  Tile.new id.to_i, blocks
end

@corners = @tiles.filter{|tile| 
  @tiles
    .filter{|t| t.id != tile.id }
    .count{|t| tile.matche(t).size > 0 } == 2
}

raise "More than 4 corners!" if @corners.count > 4

puts "Part 1: #{@corners.map(&:id).map(&:to_i).reduce(&:*)}"

@candidates = @tiles.map{|tile| [tile.id, tile] }.to_h
@positions = {}
@width = Math.sqrt(@candidates.size).to_i
@positions[[0, 0]] = @candidates.delete @corners[0].id

@width.times{|x|
  @width.times{|y|
    next if @positions.has_key? [x, y]

    neighbors = {
      above: @positions[[x, y - 1]],
      below: @positions[[x, y + 1]],
      right: @positions[[x + 1, y]],
      left: @positions[[x - 1, y]],
    }

    @candidates.each{|id, tile|
      if state = tile.matches(neighbors)
        pp "State: #{state}"
        @candidates.delete id
        @positions[[x, y]] = state
      end
    }
  }
}

pp @positions
require '../advent.rb'
require 'matrix'
require 'set'

module MatrixRotation
  refine Matrix do
    # rotate by count of 90
    def rotate count = 1
      last = self
      (count % 4).times {
        last = Matrix[*last.transpose.row_vectors.map{|v| v.to_a.reverse}]
      }
      last
    end
  end
end

using MatrixRotation

class Side
  @sides = [:north, :east, :south, :west]
  
  class << self
    attr_accessor :sides
    
    Side.sides.each do |dir|
      define_method(dir) {
        self.new dir
      }
    end
  end
  
  attr_accessor :sides

  def initialize side
    @sides = Array.new Side.sides.size, false
    if side.is_a? Symbol
      pos = Side.sides.index side
      @sides[pos] = true
    else
      @sides[side] = true
    end
  end

  def side
    Side.sides[@sides.index(true)]
  end

  def - side
    Side.new( (@sides.index(true) - side.sides.index(true)) % Side.sides.size )
  end

  def -@
    Side.new @sides.rotate(2).index(true)
  end
end

class Link
  attr_accessor :from, :to, :from_side, :to_side, :flipped

  def initialize from, from_side, to, to_side, flipped
    @from = from
    @from_side = from_side
    @to = to
    @to_side = to_side
    @flipped = flipped
  end
end

class Tile
  attr_accessor :id, :blocks, :links
    
  def initialize id, blocks
    @id = id
    @blocks = blocks
    @links = {
      north: nil,
      east: nil,
      south: nil,
      west: nil
    }
  end

  def north_edge; @blocks.row(0); end
  def east_edge; @blocks.column(@blocks.column_count - 1); end
  def south_edge; @blocks.row(@blocks.row_size - 1); end
  def west_edge; @blocks.column(0); end
  
  def edges
    Enumerator.new do |y|
      y << [self.north_edge, Side.north]
      y << [self.east_edge, Side.east]
      y << [self.south_edge, Side.south]
      y << [self.west_edge, Side.west]
    end
  end

  def link tile
    self.edges.flat_map{|own_edge, own_side|
      tile.edges.filter_map {|tile_edge, tile_side|
        if own_edge == tile_edge || reversed = own_edge.to_a == tile_edge.to_a.reverse
          Link.new self, own_side, tile, tile_side, !reversed.nil?
        end
      }
    }
  end

  def matches? tile
    self.link(tile).size > 0
  end
end

@input = Input.new(20).text.split("\n\n")
tiles = @input.map do |section|
  chunks = section.lines(chomp: true)
  id, = chunks[0].scan(/\d+/)
  blocks = Matrix[*chunks[1..].map{|strip| strip.chars}]
  Tile.new id, blocks
end

corners = tiles.filter{|tile| tiles.filter{|t| t.id != tile.id}.count{|t| tile.matches? t} == 2}
raise "More than 4 corners!" if corners.count > 4
puts "Part 1: #{corners.map(&:id).map(&:to_i).reduce(&:*)}"
# puts corners.map{|c| "#{c.id}: #{c.links}"}

start = corners[0]

while start 

# p top_left.blocks

# @seen = Set.new
# def link_chain tile, direction
#   Enumerator.new do |y|
#     until tile.nil? || @seen === tile
#       @seen.add tile
#       y << tile
#       p "[#{direction}] #{tile.id}: #{tile.links[direction][:to].id}"
#       tile = tile.links[direction][:to]
#     end
#   end
# end

# top = link_chain(top_left, :right).to_a
# pp "[right] #{top_left.id} -> #{top.last.id}"
# p top.last.links
# right = link_chain(top.last, :bottom).to_a
# p right.last
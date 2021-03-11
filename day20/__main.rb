require '../advent.rb'
require 'matrix'
require 'set'

module MatrixRotation
  refine Matrix do
    # rotate by count of 90
    def rotate count = 1
      (count % 4).times.reduce(self) do |last| 
        Matrix[*last.transpose.row_vectors.map{|v| v.to_a.reverse}]
      end
    end
  end
end

using MatrixRotation

class Direction
  attr_accessor :side, :side_list
  
  @side_list = [:above, :right, :below, :left]

  
  class << self
    attr_accessor :side_list
    
    Direction.side_list.each do |dir|
      define_method(dir) {
        self.new Direction.side_list.index dir
      }
    end
  end
  
  def initialize side
    @side = side % Direction.side_list.size
  end

  def direction
    Direction.side_list[@side]
  end
end

Link = Struct.new(:from, :from_side, :to, :to_side, :flipped)

class Links
  include Enumerable
  
  attr_accessor :links
  
  def initialize above: nil, right: nil, below: nil, left: nil
    @links = [above, right, below, left]
  end

  def each
    Direction.side_list.zip(@links).each do |val|
      yield val
    end
  end

  Direction.side_list.each.with_index do |dir, i|
    define_method(dir) {
      @links[i]
    }
  end

  def [] dir
    @links[Direction.side_list.index dir]
  end

  def []= dir, val
    @links[Direction.side_list.index dir] = val
  end

  def rotate count
    Links.new *@links.rotate(count)
  end
  
  def rotate! count
    @links.rotate! count
  end
end


class Tile
  attr_accessor :id, :blocks, :link
    
  def initialize id, blocks
    @id = id
    @blocks = blocks
    @link = Links.new
  end

  def rotate! count = 1
    @link.rotate! count
    @blocks = @blocks.rotate count
    # self.relink
  end

  def edge_above; @blocks.row(0); end
  def edge_right; @blocks.column(@blocks.column_count - 1); end
  def edge_below; @blocks.row(@blocks.row_size - 1); end
  def edge_left; @blocks.column(0); end

  def trim_edges
    @blocks.minor(1...@blocks.row_count, 1...@blocks.column_count)
  end
  
  def edges
    Enumerator.new do |y|
      y << [self.edge_above, Direction.above]
      y << [self.edge_right, Direction.right]
      y << [self.edge_below, Direction.below]
      y << [self.edge_left, Direction.left]
    end
  end

  def relink
    @link.links.filter{|link| !link.nil? }.each{|link| self.links_to link.to}
  end

  

  def links_to tile
    self.edges.flat_map do |from_edge, from_dir|
      tile.edges.filter_map do |to_edge, to_dir|
        if from_edge == to_edge || flipped = from_edge.to_a == to_edge.to_a.reverse
          @link[from_dir.direction] = Link.new self, from_dir, tile, to_dir, !flipped.nil?
        end
      end
    end
  end

  def matches? tile
    self.links_to(tile).size > 0
  end

  def inspect
    @blocks.to_a.map{|a| a.join}.join("\n") + "\n"
  end
end

@input = Input.new(20).text.split("\n\n")
@tiles = @input.map do |section|
  chunks = section.lines(chomp: true)
  id, = chunks[0].scan(/\d+/)
  blocks = Matrix[*chunks[1..].map{|strip| strip.chars}]
  Tile.new id.to_i, blocks
end

corners = @tiles.filter{|tile| @tiles.filter{|t| t.id != tile.id}.count{|t| tile.matches? t} == 2}

raise "More than 4 corners!" if corners.count > 4

puts "Part 1: #{corners.map(&:id).map(&:to_i).reduce(&:*)}"

@seen = Set.new
start = corners[0]

pp start.link

until !start.link.below.nil? and !start.link.right.nil?
  start.rotate!
  pp start
end

# def follow_links tile, dir
#   Enumerator.new do |y|
#     until tile.nil? || @seen === tile
#       @seen.add tile
#       y << tile
#       p "[#{dir}] #{tile.id}: #{tile.link[dir]&.to&.id}"
#       tile = tile.link[dir]&.to
#     end
#   end
# end

# def links_chain start
#   Enumerator.new do |y|
#     last = start
    
#     while @seen.size < @tiles.size
#       Direction.side_list.each do |dir|
#         y << last = follow_links(last, dir).to_a
#         last = last.last
#         p last&.id
#       end
#     end
#   end
# end

# follow_links(start, :right).to_a
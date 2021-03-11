require '../advent.rb'
require 'forwardable'
require 'matrix'
require 'set'

class Array
  def rotation count
    count = count % 4
    count.times.reduce(self) {|last| last.transpose.flip :x }
  end

  def flip axis
    case axis
      when :x then self.reverse
      when :y then self.map(&:reverse)
      else self
    end
  end
  
  def variant_parts
    Enumerator.new do |y|
      4.times do |rotation|
        [:none, :y].each do |axis|
          y << [rotation, axis]
        end
      end
    end
  end

  def variants
    Enumerator.new do |y|
      self.variant_parts.each {|rotation, axis| y << self.flip(axis).rotation(rotation) }
    end
  end

  def variants_with_side
    Enumerator.new do |y|
      [:top, :left, :right, :bottom].each do |side|
        self.variants.each do |variant|
          y << [variant, side]
        end
      end
    end
  end
end

module Side
  def self.opposite side
    case side
    when :top then :bottom
    when :bottom then :top
    when :right then :left
    when :left then :right
    end
  end
end

class Tile
  extend Forwardable
  include Enumerable
  
  attr_accessor :id
  attr_accessor :sides
  attr_accessor :blocks

  def self.parse data
    id = data[0].scan(/\d+/)[0].to_i
    data = data[1..].map(&:chars)
    new data, id
  end

  def initialize blocks, id = nil
    @id = id
    @sides = 0
    @blocks = blocks
  end

  def content
    @blocks[1...-1].map { |row| row[1...-1] }
  end

  def get_side side
    case side
      when :top then @blocks[0]
      when :left then @blocks.flat_map{|a| a[0]}
      when :right then @blocks.flat_map{|a| a[-1]}
      when :bottom then @blocks[-1]
    end.join
  end

  def match? tile, side
    self.get_side(side) == tile.get_side(Side.opposite(side))
  end

  def flip axis
    new_tile case axis
      when :x then @blocks.reverse
      when :y then @blocks.map(&:reverse)
      else self
    end
  end

  def rotation count
    count = count % 4
    count.times.reduce(self) {|last| last.transpose.flip :x }
  end

  def variant_parts
    Enumerator.new do |y|
      4.times do |rotation|
        [:none, :y].each do |axis|
          y << [rotation, axis]
        end
      end
    end
  end

  def variants
    Enumerator.new do |y|
      self.variant_parts.each {|rotation, axis| y << self.flip(axis).rotation(rotation) }
    end
  end

  def variants_with_side
    Enumerator.new do |y|
      [:top, :left, :right, :bottom].each do |side|
        self.variants.each do |variant|
          y << [variant, side]
        end
      end
    end
  end

  # REUSE
  def_delegators :@blocks, :[]

  def each
    @blocks.each{|b| yield b }
  end

  def transpose
    new_tile @blocks.transpose
  end

  def reverse
    new_tile @blocks.reverse
  end

  private def new_tile array = @blocks
    cloned = self.class.send(:new, array, @id)
    cloned.id = @id
    cloned
  end
end

INPUT = Input.new(20).text.split("\n\n")
TILES = INPUT.map {|section| Tile.parse section.split("\n") }
SIZE = Math.sqrt TILES.size

TILE_MAP = TILES.to_h {|tile| [tile.id, tile] }
TILE_MAP.default = 0

def find_matches tile_a
  TILES.each do |tile_b|
    next if tile_a.id == tile_b.id

    tile_b.variants_with_side.each do |variant, side|
      if tile_a.match? variant, side
        tile_a.sides += 1
      end
    end
  end
end

TILES.each {|tile| find_matches tile }
CORNERS = TILES.filter_map{|tile| tile.id if tile.sides == 2}
START = TILES.find{|t| t.id == CORNERS[0]}

puts "Part 1: #{CORNERS.reduce(&:*) }"

def find_right meta_list
  last_tile = meta_list.size % SIZE != 0
  tile = last_tile ? meta_list[-1] : meta_list[-SIZE]
  
  TILES.each {|unused_tile|
    next if meta_list.any? {|t| unused_tile.id == t.id }

    unused_tile.variant_parts.each {|rotation, axis|
      variant = unused_tile.flip(axis).rotation(rotation)
      if last_tile ? tile.match?(variant, :right) : tile.match?(variant, :top)
        return variant
      end 
    }
  }

  nil
end

def find meta_list
  find_right(meta_list).nil? ? meta_list : find(meta_list << find_right(meta_list))
end

grid = find([START]).each_slice(SIZE)
puts grid.map{|e| e.map(&:id).join(" ") }.join("\n")

puts "E"

# 1 2 3
# 4 5 6
# 7 8 9

# 1 4 7, 2 5 8, 3 6 9

puts grid.map {|tiles|
  contents = tiles.map(&:content).map(&:reverse)
  contents[0].zip(*contents[1..]).map { |row| row.map(&:join).join "" }.join "\n"
}.join "\n"

MAP = grid.map {|tiles|
  contents = tiles.map(&:content).map(&:reverse)
  contents[0].zip(*contents[1..]).map { |row| row.reduce :+ }.flatten
}

# MAP = Tile.new(grid.flat_map {|tiles|
#   contents = tiles.map(&:content)
#   contents[0].zip(*contents[1..]).map { |row| row.reduce :+ }
# })

# puts contents.map{|tile_row| tile_row.map(&:join).join "\n" }.join "\n"

DRAGON = <<-DRAGON.split("\n").map(&:chars)
  ..................#.
  #....##....##....###
  .#..#..#..#..#..#...
DRAGON

def get_mask slice
  slice.map(&:join).join.tr(".#", "01").to_i(2)
end

def count_pixel_mask grid, mask
  width = mask[0].size
  height = mask.size

  grid.each_cons(height).sum do |rows|
    slices = rows.map { |row| row.each_cons(width) }
    slices[0].zip(*slices[1..]).count {|slice| (get_mask(slice) & get_mask(mask)) == get_mask(mask) }
  end
end

# puts MAP.map{|e| e.join("")}.join

# monsters = MonsterScanner.new(DRAGON).count_for(MAP)
# p monsters
# roughness = MAP.flatten.count("#") - DRAGON.flatten.count("#") * monsters
# pp roughness
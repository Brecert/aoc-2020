require '../advent.rb'
require "delegate"

class Image < SimpleDelegator
  def variants
    base = __getobj__

    [
      base,
      base.map(&:reverse),
      base.reverse,
      base.reverse.map(&:reverse),
      base.transpose,
      base.transpose.map(&:reverse),
      base.transpose.reverse,
      base.transpose.reverse.map(&:reverse),
    ].uniq.map { |grid| Image.new(grid) }
  end
end

class Tile
  attr_reader :id, :image

  def initialize(image, id: nil)
    @image = image
    @id = id
  end

  def content
    image[1...-1].map { |row| row[1...-1] }
  end

  def rotate
    Tile.new @image.transpose.map(&:reverse), id: @id
  end

  def matches?(tile, direction)
    return true unless tile

    case direction
    when :below then image[-1] == tile.image[0]
    when :above then image[0] == tile.image[-1]
    when :right then image.each_index.all? { |y| image[y][-1] == tile.image[y][0] }
    when :left then image.each_index.all? { |y| image[y][0] == tile.image[y][-1] }
    end
  end

  def variants
    @variants ||= image.variants.map { |variant| Tile.new(variant, id: id) }
  end

  def match_neighbors? neighbors
    self.variants.find do |variant|
      neighbors.filter{|k,v| not v.nil?}.all? do |direction, neighbor|
        self.matches? neighbor, direction
      end
    end
  end
end

TILE_MATCHER = /Tile (\d+):\n([.#\n]+)/.freeze
TILES = Input.new(20).text.scan(TILE_MATCHER).map do |id, grid|
  grid = Image.new(grid.split("\n").map(&:chars))
  Tile.new(grid, id: id.to_i)
end.freeze

SIZE = Math.sqrt(TILES.count).to_i
@tile_map = TILES.map{|t| [t.id, t]}.to_h
@c = 0

def arrangement_for(tiles, x, y, layout = Array.new(SIZE) { Array.new(SIZE) })
  return layout if x >= SIZE || y >= SIZE
  p [@c+=1, x, y]

  tiles.each do |tile|
    next if layout.any? { |row| row.compact.any? { |t| t.id == tile.id } }

    tile.variants.each do |variant|
      next unless
        (x == 0 || layout[y][x - 1].matches?(variant, :right)) &&
        (y == 0 || layout[y - 1][x].matches?(variant, :below))

      updated = layout.dup.tap { |l| l[y][x] = variant }
      i = (x + 1) % SIZE
      j = i == 0 ? y + 1 : y

      arrangement = arrangement_for(tiles, i, j, updated)
      return arrangement if arrangement
    end
  end

  nil
end

arrangement_for TILES, 0, 0
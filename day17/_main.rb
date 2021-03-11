require '../advent.rb'
require 'matrix'

class Matrix3D
  def initialize matrix = {}, default = 0
    @layers = {}

    @default = default
    @layers[0] = matrix
  end

  def [](x, y, z)
    @layers[z][y][x]
  end

  def []=(x, y, z, v)
    @layers[z] = @layers.fetch(z, {})
    @layers[z][y] = @layers[z].fetch(y, {})
    @layers[z][y][x] = v
  end
  
  def fetch(x, y, z, default = @default)
    @layers.fetch(z, {}).fetch(y, {}).fetch(x, default)
  end

  def edges(px, py, pz)
    Enumerator.new do |yie|
      (-1..1).each{|x|
        (-1..1).each{|y|
          (-1..1).each{|z|
            next if x == px and y == py and z == pz
            yie << [px + x, py + y, pz + z]
          }
        }
      }
    end
  end

  def positions
    Enumerator.new do |yie|
      @layers.keys.each{|z|
        @layers[z].keys.each{|y|
          @layers[z][y].keys.each{|x|
            yie << [x, y, z]
          }
        }
      }
    end
  end

  def display
    str = ""
    @layers.each{|k, layer|
      str << "\nz=#{k}\n"
      layer.sort.each{|k, rows|
      str << "#{k.to_s.rjust(3)}: "
      str << rows.sort.map{|k, f|
        case f
        when true then "#"
        when false then "."
        else 
          f
        end
      }.join
      str << "\n"
    }
      str << "\n"
    }
    str
  end

  private def initialize_copy(v)
    super
    @layers = @layers.dup unless frozen?
  end
end

@input = Input.new(17).lines.map{|l| l.chars.map{|c| c == '.' ? false : true}}
@input = @input.each_with_index.to_h{|cols, y| [y, cols.each_with_index.to_h{|val, x| [x, val]}] }
matrix = Matrix3D.new(@input, false)

new_matrix = Matrix3D.new({}, false)

matrix.positions.each{|pos|
  active = matrix.fetch(*pos)
  active_edges = matrix.edges(*pos)
    .map{|pos| [matrix.fetch(*pos), pos]}
    .count{|val,pos|
      val
    }

  if active && (active_edges == 2 || active_edges == 3)
    p [pos, active]
    new_matrix[*pos] = false
  elsif !active && active_edges == 3
    # p [pos, active, active_edges]
    new_matrix[*pos] = true
  else
    new_matrix[*pos] = active
  end
}

puts matrix.display
puts new_matrix.display

# def simulate active_points = []
#   active_points
#     .flat_map{|pos|
#       points = []
#       active_edges = edges(pos)
#         .map{|pos| pos}
#         .filter{|pos| active_points.include? pos}.uniq
#       points << pos if (2..3) === active_edges.size
#       points.concat active_edges.filter_map{|pos|
#         active_edges = edges(pos)
#           .map{|pos| pos}
#           .filter{|pos| active_points.include? pos}.uniq
#           pos if active_edges.size === 3
#         }
#       }.uniq
# end

# for _ in (1..6)
#   active_points = simulate active_points
# end
# p active_points
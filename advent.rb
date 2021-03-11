require 'http'
require 'uri'

# def slope matrix px, py, dy, dx
#   rx = (0..matrix.column_count())
#   ry = (0..matrix.row_count())
# end

class Input
  @text = ""

  def initialize(day, year = 2020)
    input_path = "input.txt"
    @text = if File.file?(input_path)
      File.open(input_path, 'r').read
    else
      cookie = File.read("../cookie")
      res = HTTP.headers(:cookie => cookie)
        .get("https://adventofcode.com/#{year}/day/#{day}/input").to_s
      File.write(input_path, res)
      res
    end
  end

  def text
    @text
  end
  
  def lines
    @text.lines(chomp: true)
  end

  def ints
    self.lines.map(&:to_i)
  end
end
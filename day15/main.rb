require '../advent.rb'

@input = Input.new(15).text.split(',').map(&:to_i)

class VenEch
  include Enumerable
  
  def initialize(*start)
    @i = 0;
    @val = 0;
    @seen = {};
    @start = start
  end

  def self.[](*values)
    self.new *values
  end

  def add_num num
    @val = @i - @seen.fetch(num, @i)
    @seen[num] = @i
    @i += 1
  end

  def each(&block)
    @start.each{|i| block.call(i); add_num i }
    loop { block.call(@val); add_num @val }
  end
end

p VenEch[*@input].lazy.drop(2020 - 1).first
p VenEch[*@input].lazy.drop(30000000 - 1).first
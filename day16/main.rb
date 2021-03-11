require '../advent.rb'
require 'set'
require "benchmark"

beginning_time = Time.now
@input = Input.new(16).text.split("\n\n").map{|l| l.lines(chomp: true)}

@params = @input[0].map {|l| [l.match(/^(.+):/)[1], l.scan(/(\d+)-(\d+)/).map{|a,b| a.to_i..b.to_i}]}.to_h
@mine = @input[1][1].split(',').map(&:to_i)
@near = @input[2][1..].map{|l| l.split(',').map(&:to_i)}

end_time = Time.now
puts "Parsing: #{(end_time - beginning_time)*1000}ms"

beginning_time = Time.now
dumb = @near.flat_map{|a| 
  a.filter{|n| 
    @params.values.none? {|a|
      a.any? {|r| r.include? n} 
    }
  }
}
end_time = Time.now
puts "Part 1: #{dumb.reduce :+}"
puts "Part 1: #{(end_time - beginning_time)*1000}ms"

beginning_time = Time.now

@near = @near.filter do |t|
  t.none? do |num|
    @params.values.none? do |arr|
      arr.any? {|r| r.include? num}
    end
  end
end

sets = {}
@near.each do |tk|
  tk.each_with_index do |v,i|
    sets[i] = sets.fetch(i, Set[]) << v
  end
end

fields =  Enumerator.new do |y|
  params = @params.clone

  while params.size > 0
    sets.map{|i,set|
      param = params.filter {|n,v| set < v.flat_map(&:to_a).to_set}
      if param.size == 1
        params.delete param.keys[0]
        sets.delete i
        y << [i, param.keys[0]]
      end
    }
  end
end

corrected = fields.map{|i,n| [n, @mine[i]] }.to_h
final = corrected.filter{|k,v| k.start_with? 'departure'}.values.reduce :*
end_time = Time.now
puts "Part 2: #{final}"
puts "Part 2: #{(end_time - beginning_time)*1000}ms"

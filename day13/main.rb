require '../advent.rb'
require 'matrix'

@input = Input.new(13).lines
@time = @input[0].to_i
@buses = @input[1].split(',').map(&:to_i)
@max = @buses.max
@idx = @buses.find_index @max
@busos = @buses.each_with_index.filter{|x| x[0] != 0}

# part 1
# time, bus = @buses.map{|b| b - (@time % b)}.each_with_index.min{|e,b| e[0] <=> b[0]}
# p @buses[bus] * time

def is_sequence_at n
  @busos.all?{ ((n + (i - @idx)) % b) == 0 }
end

step = 1
# guranteed to be at least this size
last = @time
@busos.each_with_index do |b,i|
  p "(#{step}) #{last}: #{num}"
  # find next valid number
  
end

# while
#   num = last * @max
#   p "#{last}: #{num}"
#   if  @busos.all?{|b,i| ((num + (i - @idx)) % b) == 0 }
#     p @idx
#     p "Fin: #{num - @idx}"
#     break
#   end 
#   last += step
# end



# get max
# check every max step if seq valid
# if not next
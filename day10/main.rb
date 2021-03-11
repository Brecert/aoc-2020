# read file
adaps = File.readlines("input/10").map(&:to_i).sort

# add max (MAX) adaptor
adaps.push(adaps[-1] + 3)

# get diffs of adap
diffs = adaps.each_cons(2).map { |x, y| y - x }
puts "Part 1: #{diffs.count(1) * diffs.count(3)}"

# add space for the final result
psuedograph = Array.new(adaps[-1] + 1, 0)

# initial value for fake graph
psuedograph[0] = 1

list = []

# each adapter
adaps.each { |jolt|
  # add previous 3, will remain zero if nothing was initially there
  # similar to the graph, but with "implicit" checks rather then "explicit" conditionals and checks
  # so it'll take the last (if possible) three values, and combine it with the current adapter, combining them
  #
  # similar to:
  #   arr[val] = arr[val+1] + arr[val+2] + arr[val+3]

  validJolts = (jolt-3).clamp(0..)...jolt
  psuedograph[jolt] = psuedograph[validJolts].reduce(:+)
}

puts "Part 2: #{psuedograph[-1]}"
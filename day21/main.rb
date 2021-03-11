require '../advent.rb'
require 'set'

@input = Input.new(20).lines.map{|line| food,allergen = line.split("(contains "); [food.split(" "), allergen.tr(")", "").split(", ")] }.to_h
@allergens = Hash.new

@input.each{|food, allergens|
  allergens.each{|a|
    if !@allergens.has_key? a
      @allergens[a] = Set.new food
    else
      @allergens[a] &= food
    end
  }
}

p @allergens
safe = Set.new(@input.keys.flatten) ^ Set.new(@allergens.values.flat_map(&:to_a))
p @input.keys.flatten.count{|f| safe.include? f }

unsafe = @allergens.sort_by { |key, val| key }.to_h
str = unsafe.values.flat_map(&:to_a).uniq.join(',')
p `node -e console.log("'#{str}'.split(',').sort().join(','))`
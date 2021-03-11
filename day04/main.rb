require '../advent.rb'

@input = Input.new(04).text.split("\n\n").map{|p| p.split(/\s+/).map{|f| f.split(':') }.to_h}

def range min, max 
  -> year { year =~ /\d{4}/ && (min..max) === year.to_i }
end

valid = {
  'byr' => range(1920, 2002),
  'iyr' => range(2010, 2020),
  'eyr' => range(2020, 2030),
  'hgt' => -> hgt {
    hgt.match(/(\d+)(cm|in)/) {|m|
      case m[2]
      when "cm"
        (150..193) === m[1].to_i
      when "in"
        (59..76) === m[1].to_i
      end
    }
  },
  'hcl' => -> hcl { hcl.match(/#\h{6}/) },
  'ecl' => -> ecl { %w[amb blu brn gry grn hzl oth].include? ecl },
  'pid' => -> pid { pid.match(/^\d{9}$/) }
}

puts "Part 1: #{@input.count{|pass| valid.all?{|k,v| pass[k]}}}"
puts "Part 2: #{@input.count{|pass| valid.all?{|k,v| pass[k] && v[pass[k]]}}}"
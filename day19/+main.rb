require '../advent.rb'
require 'set'

class Object
  def is_number?
    to_f.to_s == to_s || to_i.to_s == to_s
  end
end

@input = Input.new(19).text.split("\n\n")
@rules = @input[0].lines.map{|l| 
  k,v = l.split(':')
  v = v.split("|")
  v = v.map{|e| e.split(' ').map{|c| c.is_number? ? c.to_i : c.tr('"', '')  }}
  [k.to_i, v]
}.to_h
@messages = @input[1].split("\n")

def rules_str n
  @rules[n].map{|ors| ors.map{|v| v.is_number? ? "(?:#{rules_str(v).join("|")})" : [v] }.join }
end

@rules[8] = [[42], [42, 8]]
@rules[11] = [[42, 31], [42, 11, 31]]

zero_pat = Regexp.new("^#{rules_str(0).join("|")}$")
p zero_pat
p @messages.count {|m| zero_pat === m}
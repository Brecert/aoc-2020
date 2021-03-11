require '../advent.rb'

def create_regex rules

  define_method "build" do |str, r = 0|
    # just give up
    return "" if r > 25
    case rules[str]
    when '"a"' then "a"
    when '"b"' then "b"
    else 
      rules[str]
        .split(" ")
        .map{|key| if key == "|" then "|" else build key, r + 1 end}
        .join
        .then{|val| "(?:#{val})"}
    end
  end

  Regexp.new "^#{build "0"}$"
end

@input = Input.new(19).text.split("\n\n")

messages = @input[1].lines(chomp: true)
rules = @input[0].lines(chomp: true)
  .map{|line| line.split ': '}
  .to_h


regex = create_regex rules
p messages.count{|m| regex === m}
p regex

rules["8"] = "42 | 42 8"
rules["11"] = "42 31 | 42 11 31"

regex = create_regex rules
p messages.count{|m| regex === m}
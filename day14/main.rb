require '../advent.rb'

@input = Input.new(14).lines.map{|l| l.scan /\w+/}
@mask = ""
@mem1 = {}
@mem2 = {}

@input.each do |inst|
  case inst
  in ["mask", mask]
    @mask = mask
  in ["mem", addr, val]
    dec = val.to_i.to_s(2).rjust(@mask.size, '0')
    masked = @mask.each_char.each_with_index.map{|ch,i| ch == 'X' ? dec[i] : ch }.join.to_i(2)
    @mem1[addr.to_i] = masked

    addr = addr.to_i.to_s(2).rjust(36, '0')
    addr = @mask.each_char.each_with_index.map{|ch,i| ch == '0' ? addr[i] : ch }.join
    count = addr.count 'X'
    addresses = ([0, 1] * count).combination(count).uniq

    addresses.each do |bits|
      final_addr = addr.gsub('X') {|r| bits.pop}.to_i(2)
      @mem2[final_addr] = dec.to_i(2)
    end
  end
end

p @mem1.values.reduce :+
p @mem2.values.reduce :+
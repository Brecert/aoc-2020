require '../advent.rb'
require 'matrix'

@input = Input.new(06).text.chomp.split('\n\n').map{|g| g.lines(chomp:true).map(&:chars)}

@input.map{|i| i.count {}}


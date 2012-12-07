#encoding: utf-8

require "pp"
class CloneSet
  Range = Struct.new(:line, :row, :token)
  attr_reader :start_range
  def initialize line
    clone_set_regexp = /(\d+\.\d+)\t(\d+),(\d+),(\d+)\t(\d+),(\d+),(\d+)\t(\d+)/
    throw "invalid clone set" unless line =~ clone_set_regexp
    @id = $1.to_f
    @start_range = Range.new($2.to_i, $3.to_i, $4.to_i)
  end
end

if $0 == __FILE__
  cs = CloneSet.new("0.0\t6,8,4\t14,38,43\t39")
  pp cs.start_range
end

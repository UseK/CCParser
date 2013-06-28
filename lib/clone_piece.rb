#encoding: utf-8

require "pp"
class ClonePiece
  Range = Struct.new(:line, :row, :token)
  attr_reader :id
  attr_reader :start_range
  attr_reader :not_repeat
  def initialize line
    clone_set_regexp = /(\d+\.\d+)\t(\d+),(\d+),(\d+)\t(\d+),(\d+),(\d+)\t(\d+)/
    throw "invalid clone set" unless line =~ clone_set_regexp
    @id = $1
    @start_range = Range.new($2.to_i, $3.to_i, $4.to_i)
    @end_range = Range.new($5.to_i, $6.to_i, $7.to_i)
    @not_repeat = $8.to_i
  end

  def package
    @id.split(".")[0]
  end

  def range
    @start_range.token..@end_range.token
  end
end

if $0 == __FILE__
  cp = ClonePiece.new("0.0\t6,8,4\t14,38,43\t39")
  pp cp
  pp cp.package
end

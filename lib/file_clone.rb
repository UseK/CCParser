#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "clone_set"

class FileClone
  attr_reader :fd_unit
  FILE_CLONE = Struct.new(:clone_set, :range)
  def initialize fd_unit
    @fd_unit = fd_unit
    @file_clone_set = []
    @nct = nil
    @nct_pkg = {}
  end

  def add_clone_set clone_set, range
    @file_clone_set << FILE_CLONE.new(clone_set, range)
  end

  def content_rate
    n_clone_token.quo @fd_unit.n_token
  end

  def content_rate_package package
    n_clone_token_package(package).quo @fd_unit.n_token
  end

  def n_clone_token
    @nct || (@nct = culc_clone_token @file_clone_set)
  end

  def n_clone_token_package package
    @nct_pkg[package.to_s] || @nct_pkg[package.to_s] = culc_clone_token(@file_clone_set.select {|file_clone| file_clone.clone_set.include_package? package})
  end

  private
  def culc_clone_token fc_set
    return 0 if fc_set == []
    range_arr = []
    fc_set.each do |file_clone|
      range_arr << file_clone.range
    end
    combine_range_arr(range_arr).inject(0) {|sum, i| sum += i.count}
  end

  def combine_range_arr param_arr
    arr = param_arr.sort_by {|i| i.begin }
    i = 0
    while (i < arr.length - 1)
      if arr[i].end >= arr[i+1].begin
        arr[i..i+1] = arr[i].begin..[arr[i].end, arr[i+1].end].max
      else
        i += 1
      end
    end
    arr
  end

end

if $0 == __FILE__
  require "file_description_unit"
  require "clone_piece"
  fd_unit = FileDescriptionUnit.new("8.17\t157\t566\tC:\\Users\\UseK\\file.java")
  fc = FileClone.new(fd_unit)

  cs = CloneSet.new
  cs << ClonePiece.new("0.0\t6,8,4\t14,38,43\t39")
  cs << ClonePiece.new("0.1\t6,8,4\t14,38,43\t39")
  fc.add_clone_set cs, 1..100

  cs2 = CloneSet.new
  cs2 << ClonePiece.new("0.0\t6,8,4\t14,38,43\t39")
  cs2 << ClonePiece.new("1.1\t6,8,4\t14,38,43\t39")
  fc.add_clone_set cs2, 50..150

  p fc.n_clone_token_package "0" #>150
  p fc.n_clone_token_package "1" #>101
  puts

  p fc.combine_range_arr([40..50, 20..30, 10..20]).inject(0) {|sum, i| sum += i.count }
end

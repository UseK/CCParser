#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "pp"
require "clone_set"

class FileClone
  attr_reader :fd_unit, :included_clone_set_list
  INCLUDED_CLONE_SET = Struct.new(:clone_set, :range)
  def initialize fd_unit
    @fd_unit = fd_unit
    @included_clone_set_list = []
    @nct = nil
  end

  def add_clone_set clone_set, range
    @included_clone_set_list << INCLUDED_CLONE_SET.new(clone_set, range)
  end

  def content_rate
    n_clone_token.quo @fd_unit.n_token
  end

  def content_rate_package package
    n_clone_token_package(package).quo @fd_unit.n_token
  end

  def n_clone_token
    @nct || (@nct = calc_clone_token @included_clone_set_list)
  end

  def n_clone_token_package package
    calc_clone_token(@included_clone_set_list.select do |included_clone_set|
      included_clone_set.clone_set.include_package? package
    end)
  end

  # 他ファイルクローンのリストに対して自身のクローンが含まれるもののトークン数を返す
  def n_clone_token_general clone_set_list_dst
    calc_clone_token(@included_clone_set_list.select do |included_clone_set|
      clone_set_list_dst.include? included_clone_set.clone_set
    end)
  end

  private
  def calc_clone_token fc_set
    return 0 if fc_set == []
    range_arr = []
    fc_set.each do |included_clone_set|
      range_arr << included_clone_set.range
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
  require "pp"
  fd_unit = FileDescriptionUnit.new("8.17\t157\t566\tC:\\Users\\UseK\\file.java")

  cs = CloneSet.new
  cs << ClonePiece.new("0.0\t6,8,4\t14,38,43\t39")
  cs << ClonePiece.new("0.1\t6,8,4\t14,38,43\t39")

  cs2 = CloneSet.new
  cs2 << ClonePiece.new("50.0\t6,8,4\t14,38,43\t39")
  cs2 << ClonePiece.new("50.1\t6,8,4\t14,38,43\t39")

  cs3 = CloneSet.new
  cs3 << ClonePiece.new("99.1\t6,8,4\t14,38,43\t39")
  cs3 << ClonePiece.new("99.2\t6,8,4\t14,38,43\t39")

  puts
  fc = FileClone.new(fd_unit)
  fc.add_clone_set cs, 1..100
  fc.add_clone_set cs2, 51..150

  fc2 = FileClone.new(fd_unit)
  fc2.add_clone_set cs2, 21..170
  fc2.add_clone_set cs3, 11..170

  pp fc.n_clone_token_general [fc2]
  puts
  p fc.n_clone_token_package "0" #>150
  p fc.n_clone_token_package "1" #>101
  #pp fc.included_clone_set_list.select {|included_clone_set| [cs, cs2].include? included_clone_set.clone_set}

  #p fc.combine_range_arr([40..50, 20..30, 10..20]).inject(0) {|sum, i| sum += i.count }
end

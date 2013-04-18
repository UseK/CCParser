$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "pp"
require "pathname"
require "parser"
require "tempfile"
module PackageParser
 
  # changerを元にidを書き換えたファイルを出力する
  # ==== Args
  # file_path :: 入力するファイルのパス
  # changer :: 変更するidをまとめたハッシュの配列
  # キーが変更前、値が変更後のid
  def self.output_cc_file input_file_path, changer
    output_file = Tempfile.new("top")
    section = []
    File.foreach(input_file_path) do |line|
      case line
      when /^#begin{(.+)}/
        section.push $1
        output_file.print line
        next
      when /^#end{(.+)}/
        section.pop
        output_file.print line
        next
      end

      case section
      when ["file description"]
        output_file.print sub_id line, changer
      when ["clone", "set"]
        output_file.print sub_id line, changer
      else
        output_file.print line
      end
    end
    output_file.rewind
    output_file
  end

  def self.sub_id line, changer
    id = line[/^(\d+\.\d+)/, 1]
    line.gsub(/^\d+\.\d+/, changer[id])
  end

  def self.gen_changer input_file
    file_description, clone = Parser.parse input_file
    top_arr = []
    root_regexp = /#{file_description.root_directory}/
      file_description.each do |unit|
      dir = unit.path.gsub(root_regexp, "")[/^(\w+)\//, 1]
      top_arr << dir
      end
    top_arr.uniq!
    PackageParser.make_changer file_description, root_regexp, top_arr
  end

  def self.make_changer file_description, root_regexp, top_arr
    changer = {}
    i = 0
    new_pakcage = ""
    file_description.each do |unit|
      dir = unit.path.gsub(root_regexp, "")[/^(\w+)\//, 1]
      if new_pakcage != top_arr.index(dir).to_s
        i = 0
        new_pakcage = top_arr.index(dir).to_s
      else
      end
      changer[unit.id] = new_pakcage + "." + i.to_s
      i += 1
    end
    changer
  end
end

if $0 == __FILE__
  input_file_path = ARGV[0] || "./sample_data/ff"
  changer = PackageParser.gen_changer input_file_path
  output_file = PackageParser.output_cc_file input_file_path, changer
  File.open("#{input_file_path}_top", "w").print output_file.read
#  output_file.each do |line|
#    puts line
#  end
end

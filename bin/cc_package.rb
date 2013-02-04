$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "pp"
require "pathname"
require "parser"

module PackageParser
  def self.parse file_path, changer, root_regexp
    section = []
    out_file = File.open(file_path + "_top", "w")
    File.foreach(file_path) do |line|
      out_file.print @alt_line
      case line
      when /^#begin{(.+)}/
        section.push $1
        @alt_line = line
        next
      when /^#end{(.+)}/
        section.pop
        @alt_line = line
        next
      end

      case section
      when ["file description"]
        @alt_line = sub_id line, changer
      when ["clone", "set"]
        @alt_line = sub_id line, changer
      else
        @alt_line = line
      end
    end
    out_file.print @alt_line
  end

  def sub_id line, changer
    id = line[/^(\d+\.\d+)/, 1]
    line.gsub(/^\d+\.\d+/, changer[id])
  end
end

if $0 == __FILE__
  input_file = ARGV[0] || "./sample_data/ff"
  include Parser
  file_description, clone = Parser.parse input_file
  include PackageParser
  top_arr = []
  root_regexp = /#{file_description.root_directory}/
  file_description.each do |unit|
    dir = unit.path.gsub(root_regexp, "")[/^(\w+)\//, 1]
    top_arr << dir
  end
  top_arr.uniq!

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
  pp changer
  PackageParser.parse input_file, changer, root_regexp
end

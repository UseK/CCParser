#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "pp"
require "./lib/file_clone"
require "./lib/clone_set"

class CCParser

  attr_reader :package_clone
  def initialize
    @section = []
    @package_clone = Hash.new {|h, k| h[k] = []}
  end

  def parse file_path
    File.foreach(file_path) do |line|
      case line
      when /^#begin{(.+)}/
        @section.push $1
        next
      when /^#end{(.+)}/
        @section.pop
        next
      end

      case @section
      when ["file description"]
        parse_file_description(line)
      when ["clone", "set"]
        parse_clone_set(line)
      end
    end
  end

  private
  def parse_file_description line
    fc = FileClone.new(line)
    @package_clone[fc.package] << fc
  end

  def parse_clone_set line
    cs = CloneSet.new(line)
  end
end

if $0 == __FILE__
  CCParser.new.parse("./sample_data/crawler")
end

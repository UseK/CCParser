#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "pp"
require "./lib/file_clone"
require "./lib/clone_set"

class CCParser

  attr_reader :package_clone_list
  attr_reader :file_clone_list
  def initialize
    @section = []
    @package_clone_list = Hash.new {|h, k| h[k] = []}
    @file_clone_list = {}
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
    @package_clone_list[fc.package] << fc
    @file_clone_list[fc.id] = fc
  end

  def parse_clone_set line
    cs = CloneSet.new(line)
    @file_clone_list[cs.id].fill(cs)
  end
end

if $0 == __FILE__
  ccp = CCParser.new
  ccp.parse("./sample_data/crawler")
  pp ccp.file_clone_list
end

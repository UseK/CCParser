#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "pp"
require "./lib/file_description_unit"
require "./lib/file_clone"
require "./lib/clone_piece"

class CCParser

  attr_reader :file_description
  attr_reader :clone
  attr_reader :file_clone_list
  def initialize
    @section = []
    @file_description = {}
    @clone = []
    @set = []
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
        if $1 == "set"
          @clone << @set.dup
          @set = []
        end
        next
      end

      case @section
      when ["file description"]
        parse_file_description_unit(line)
      when ["clone", "set"]
        parse_clone_piece(line)
     end
    end
  end

  def build_file_clone_list
    @file_description.each do |id, fd_unit|
      @file_clone_list[id] = FileClone.new(fd_unit)
    end
    @clone.each do |set|
      ind = @clone.index(set)
      set.each do |clone_piece|
        @file_clone_list[clone_piece.id].add_fill_token(ind, clone_piece.range)
      end
    end
  end

  def each_content_rate
    @file_clone_list.each do |id, fc|
      yield id, fc.n_clone_token, fc.n_all_token, fc.content_rate
    end
  end

  private
  def parse_file_description_unit line
    fc = FileDescriptionUnit.new(line)
    @file_description[fc.id] = fc
  end

  def parse_clone_piece line
    cp = ClonePiece.new(line)
    @set << cp
  end
end

if $0 == __FILE__
  ccp = CCParser.new
  ccp.parse("./sample_data/crawler")
  ccp.build_file_clone_list
  ccp.each_content_rate do |id, n_clone_token, n_all_token, rate|
    p id
    p n_clone_token
    p n_all_token
    p rate
    puts
  end
end

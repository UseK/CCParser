$LOAD_PATH  << File.dirname(__FILE__)
require "clone_set"
require "clone_piece"
require "file_description"
require "file_clone"

module Parser
  def self.parse file_path
    section = []
    clone_set = CloneSet.new
    file_description = FileDescription.new
    clone = []
    File.foreach(file_path) do |line|
      case line
      when /^#begin{(.+)}/
        section.push $1
        next
      when /^#end{(.+)}/
        section.pop
        if $1 == "set"
          clone << clone_set.dup
          clone_set = CloneSet.new
        end
        next
      end

      case section
      when ["file description"]
        file_description << FileDescriptionUnit.new(line)
      when ["clone", "set"]
        clone_set << ClonePiece.new(line)
      end
    end
    [file_description, clone]
  end

  def self.build_file_clone_list file_description, clone
    file_clone_list = {}
    file_description.each do |fd_unit|
      file_clone_list[fd_unit.id] = FileClone.new(fd_unit)
    end
    clone.each_with_index do |clone_set, index|
      clone_set.each do |clone_piece|
        file_clone_list[clone_piece.id].add_clone_set(clone_set, clone_piece.range)
      end
      puts "executed clone set #{index} of #{clone.length}" if index % 1000 == 0
    end
    file_clone_list
  end
end

if $0 == __FILE__
  include Parser
  file_description, clone = Parser.parse "./sample_data/crawler"
  file_clone_list = Parser.build_file_clone_list file_description, clone
end

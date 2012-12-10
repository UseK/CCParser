#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "clone_set"

class FileClone
  attr_reader :fd_unit
  def initialize fd_unit
    @fd_unit = fd_unit
    @token_list = Array.new(fd_unit.n_token) {Array.new(CloneSet.new)}
    @n_token = fd_unit.n_token
  end

  def add_fill_token(clone_set, range)
    for i in range
      throw "#{range} is out #{@token_list.length}" if @token_list.length < i - 1
      @token_list[i-1] << clone_set
      throw "lentgh is changed from #{@n_token} to #{@token_list.length}" if @n_token != @token_list.length
    end
  end

  def fill_true range
    @token_list.fill(true, range)
  end

  def content_rate
    n_clone_token.quo n_all_token
  end

  def content_rate_package package
    n_clone_token_package(package).quo n_all_token
  end

  def n_clone_token
    @token_list.select {|i| i != []}.length
  end

  def n_clone_token_package package
    @token_list.select { |arr|
      arr.select { |clone_set|
        clone_set.include_package? package
      }.length > 0
    }.length
  end

  def n_all_token
    @token_list.length
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

  fc.add_fill_token cs, 1..565
  p fc.n_clone_token_package "0"
  p fc.content_rate_package "0"
end

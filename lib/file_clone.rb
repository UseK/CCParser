#encoding: utf-8
class FileClone
  attr_reader :id
  def initialize line
    throw "ivalid file descripiton format" unless line =~ /(\d+\.\d+)\t(\d+)\t(\d+)\t(.+)/
    @id = $1.to_f
    @n_line = $2.to_i
    @n_token = $3.to_i
    @path = $4
    @token_list = Array.new(@n_token)
  end

  def package
    @id.floor
  end
end

if $0 == __FILE__
  fc = FileClone.new("8.17\t157\t566\tC:\\Users\\UseK\\file.java")
end

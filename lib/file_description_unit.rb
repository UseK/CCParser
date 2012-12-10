#encoding: utf-8
class FileDescriptionUnit
  attr_reader :id
  attr_reader :n_token
  attr_reader :path
  def initialize line
    throw "ivalid file descripiton format" unless line =~ /(\d+\.\d+)\t(\d+)\t(\d+)\t(.+)/
    @id = $1
    @n_line = $2.to_i
    @n_token = $3.to_i
    @path = $4
  end

  def package
    @id[/(\d+).\d+/, 1]
  end

  def file_id
    @id[/\d+.(\d+)/, 1]
  end
end

if $0 == __FILE__
  fd_unit = FileDescriptionUnit.new("8.17\t157\t566\tC:\\Users\\UseK\\file.java")
  p fd_unit.package
  p fd_unit.file_id
end

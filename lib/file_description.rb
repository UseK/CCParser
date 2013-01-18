$LOAD_PATH << File.dirname(__FILE__)
require "file_description_unit"
class FileDescription < Array
  def package_list
    list = {}
    self.each do |fd_unit|
      list[fd_unit.package] = File.dirname(fd_unit.path.gsub(/\\/, "\/"))
    end
    list
  end
end

if $0 == __FILE__
  fd = FileDescription.new
  example1 = "8.17\t157\t566\tC:\\Users\\UseK\\src\\file.java"
  example2 = "9.99\t157\t566\tC:\\Users\\UseK\\lib\\file.java"
  fd << FileDescriptionUnit.new(example1)
  fd << FileDescriptionUnit.new(example2)
  p fd.package_list
  p fd[0].path.gsub(/C:\\Users/, "")

end

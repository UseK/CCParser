$LOAD_PATH << File.dirname(__FILE__)
require "file_description_unit"
class FileDescription < Array
  def package_list
    list = {}
    self.each do |fd_unit|
      list[fd_unit.package] = File.dirname(fd_unit.path).gsub(/#{root_directory}/, "")
    end
    list
  end

  def root_directory
    @r ||= gen_root_directory
  end

  private
  def gen_root_directory
    r_dir = self[0].path
    self.each do |fd_unit|
      r_dir = common_str r_dir, fd_unit.path
    end
    p r_dir
    File.dirname(r_dir + "dummyyyyy") + "\/"
  end

  def common_str a, b
    idx = a.split(//).zip(b.split(//)).map {|e| e.uniq.size == 1}.index(false)
    return a if idx.nil?
    return a[0..idx].chop
  end
end

if $0 == __FILE__
  fd = FileDescription.new
  example1 = "8.17\t157\t566\tC:\\Users\\UseK\\src\\file.java"
  example2 = "9.99\t157\t566\tC:\\Users\\UseK\\lib\\file.java"
  example3 = "9.9\t157\t566\tC:\\Users\\UseK\\lib\\file.java"
  example4 = "10.9\t157\t566\tC:\\Users\\UseK\\lib\\file.java"
  fd << FileDescriptionUnit.new(example1)
  fd << FileDescriptionUnit.new(example2)
  fd << FileDescriptionUnit.new(example3)
  fd << FileDescriptionUnit.new(example4)
  p fd.package_list
  p fd[0].path.gsub(/^C:\/Users\/UseK/, "")
  puts
  p fd.root_directory
end

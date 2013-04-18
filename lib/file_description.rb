$LOAD_PATH << File.dirname(__FILE__)
require "file_description_unit"
class FileDescription < Hash
  def package_list
    @l ||= gen_package_list
  end

  def top_list
    @tl ||= gen_top_list
  end

  def root_directory
    @r ||= gen_root_directory
  end

  private
  def gen_package_list
    list = {}
    self.each_value do |fd_unit|
#      list[fd_unit.package] = File.dirname(fd_unit.path).gsub(/#{root_directory}/, "")
      list[fd_unit.package] = File.dirname(fd_unit.path).gsub(/#{root_directory}/, "").gsub(/(\/.+)+$/, "")

    end
    list
  end

  def gen_top_list
    list = {}
    package_list.each_value do |package_path|
      list = package_path.gsub(/(\.\w+){1, }$/, "")
    end
  end

  def gen_root_directory
    r_dir = self[self.keys[0]].path
    self.each_value do |fd_unit|
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
  example3 = "9.9\t157\t566\tC:\\Users\\UeK\\lib\\file.java"
  example4 = "10.9\t157\t566\tC:\\Users\\UseK\\lib\\file.java"

  fd_unit1 = FileDescriptionUnit.new(example1)
  fd_unit2 = FileDescriptionUnit.new(example2)
  fd_unit3 = FileDescriptionUnit.new(example3)
  fd_unit4 = FileDescriptionUnit.new(example4)

  fd[fd_unit1.id] = fd_unit1
  fd[fd_unit2.id] = fd_unit2
  fd[fd_unit3.id] = fd_unit3
  fd[fd_unit4.id] = fd_unit4

  p fd.package_list
  p fd[fd.keys[0]].path.gsub(/^C:\/Users\/UseK/, "")
  puts
  p fd.root_directory
  p fd.top_list
end

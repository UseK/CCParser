class FileDescription < Hash
  def package_list
    list = {}
    each_value do |fd_unit|
      list[fd_unit.package] = fd_unit.path[/(.+\\.+)\\.+/, 1]
    end
    list
  end

end

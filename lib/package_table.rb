module PackageTable
  def add_header table
    l = table.length - 1
    for i in 0..l
      table[i].unshift(i)
    end
  end
end

if $0 == __FILE__
  table = [[0, 1], [2, 3]]
  include PackageTable
  add_header table
  p table
end

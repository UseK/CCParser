class TableCell
  attr_reader :n_clone, :n_all
  def initialize n_clone, n_all
    @n_clone = n_clone
    @n_all = n_all
  end

  def rate
    @rate ||= (@n_clone.quo @n_all).to_f.round(4)
  end

  def bgcolor
    return "#000000" if rate == 0.0
    x16 = format("%02x", [255, rate * 255 * 4].min).to_s
    "#" + x16 +"bbbb"
  end

  def data
    "#{rate}(#{n_clone}/#{n_all})"
  end
end

if $0 == __FILE__
  cell = TableCell.new(1111, 22222)
  p cell.bgcolor
end

$LOAD_PATH << File.dirname(__FILE__)
require "heatmap_utility"
class TableCell
  attr_reader :n_clone, :n_all
  def initialize n_clone, n_all
    @n_clone = n_clone
    @n_all = n_all
  end

  def rate
    @rate ||= (@n_clone.quo @n_all).to_f.round(4)
  end

  def ammount
    @n_clone
  end

  def bgcolor_rate
    HeatmapUtility.get_color(rate * 255)
  end

  def bgcolor_ammount max
    HeatmapUtility.get_color(@n_clone, max: max)
  end

  def font_color_rate
    HeatmapUtility.get_color(rate * 255, complementary: true)
  end

  def font_color_ammount max
    HeatmapUtility.get_color(@n_clone, complementary: true, max: max)
  end

  def rate_persent
    "#{(rate * 100).round(5)}%"
  end

  def data_detail
    "#{rate}(#{n_clone}/#{n_all})"
  end

end

if $0 == __FILE__
  cell = TableCell.new(1111, 22222)
  p cell.rate
  p cell.data
  p cell.bgcolor_rate
  p cell.font_color_rate
  p cell.bgcolor_ammount 100000
  p cell.font_color_ammount 100000
end

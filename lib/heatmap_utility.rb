module HeatmapUtility
  def self.get_color(value, options={})
    options = { complementary: false, min: 0, max: 255 }.merge(options)
    @one_scale = (options[:max] - options[:min] + 1) / 5.0
    selector = (value / @one_scale).floor
    mag = (value / @one_scale) - selector
    add = mag * 255
    sub = 255 - add

    case selector
    when 0 # black-blue
      @red = 0
      @green = 0
      @blue = add
    when 1 # blue-lightblue
      @red = 0
      @green = add
      @blue = 255
    when 2 # lightblue-green
      @red = 0
      @green = 255
      @blue = sub
    when 3 # green-yellow
      @red = add
      @green = 255
      @blue = 0
    when 4 # yellow-red
      @red = 255
      @green = sub
      @blue = 0
#    when 5 # red-white
#      @red = 255
#      @green = add
#      @blue = add
    else
      puts "Warning: invalid value in HeatmapUtility"
      p options
      puts "value == #{value}"
      puts "selector == #{selector}"
      puts "mag == #{mag}"
      puts
      @red = 255
      @green = 0
      @blue = 0
    end
    if options[:complementary]
      return color_code_complementary
    else
      color_code
    end
  end

  private
  def self.color_code
    "#" + format_02x(@red) + format_02x(@green) + format_02x(@blue)
  end

  def self.color_code_complementary
    "#" + format_02x(255 - @red) + format_02x(255 - @green) + format_02x(255 - @blue)
  end

  def self.format_02x value
    result = format("%02x", value).to_s
    raise "invalid value \"#{value}\" and result \"#{result}\"" unless result.length == 2
    result
  end
end

if $0 == __FILE__
  p HeatmapUtility.get_color(200)
  p HeatmapUtility.get_color(2000, max: 1000000)
end

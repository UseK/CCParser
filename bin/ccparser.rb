#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "pp"
require "pathname"
require "parser"
require "heatmap_output"
require "histgram_output"

class CCParser
  include Parser
  def initialize input_file
    @input_file = input_file
    @file_description, @clone = Parser.parse @input_file
    @file_clone_list = Parser.build_file_clone_list @file_description, @clone
  end

  def output_histgram_and_heatmap
    HistgramOutput.output @input_file + "_histgram.txt", @file_clone_list
    puts "heatmap output..."
    output_dirname = Pathname.new(@input_file + "_heatmap")
    output_dirname.mkpath
    heatmap_output = HeatmapOutput.new(@file_clone_list, @file_description)
    heatmap_output.output(output_dirname + "index.html")
    heatmap_output.output(output_dirname + "index_ammount.html", template: "ammount")
    heatmap_output.output(output_dirname + "rate.csv", format: "csv")
  end

end

if $0 == __FILE__
  input_file = ARGV[0] || "./sample_data/ff"
  ccp = CCParser.new input_file
  ccp.output_histgram_and_heatmap
end


#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require "pp"
require "parser"
require "file_description"
require "file_description_unit"
require "file_clone"
require "clone_set"
require "clone_piece"
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
    HeatmapOutput.new(@file_clone_list, @file_description.package_list).output (@input_file + "_heatmap.html")
  end

end

if $0 == __FILE__
  input_file = "./sample_data/crawler"
  ccp = CCParser.new input_file
  ccp.output_histgram_and_heatmap
end


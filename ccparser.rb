#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "pp"
require "./lib/file_description"
require "./lib/file_description_unit"
require "./lib/file_clone"
require "./lib/clone_set"
require "./lib/clone_piece"
require "./lib/heatmap_output"

class CCParser

  attr_reader :file_description
  attr_reader :clone
  attr_reader :file_clone_list
  CloneData = Struct.new("CloneData", :n_clone, :n_all, :rate)
  def initialize
    @file_description = FileDescription.new
    @clone = []
    @file_clone_list = {}
  end

  def output_histgram_and_heatmap input_file
    parse(input_file)
    build_file_clone_list
    File.open(input_file + "_histgram.txt", "w") do |output_file|
      @file_clone_list.each do |id, fc|
        arr = ["\"#{id}\"", fc.n_clone_token, fc.n_all_token, fc.content_rate.to_f.round(4)]
        puts arr.join(',')
        output_file.puts arr.join(',')
      end
    end

    pkg = Hash.new {|h, k| h[k] = []}
    @file_clone_list.each do |id, fc|
      pkg[fc.fd_unit.package] << fc
    end
    table = Array.new(pkg.length + 1) {Array.new(pkg.length)}
    pkg.each do |pkg_id_src, fc_list|
      #pkg_sum = 0
      n_all =  fc_list.inject(0) {|sum, fc| sum += fc.n_all_token}
      pkg.each_key do |pkg_id_dst|

        #pkg_sum += fc_list.inject(0) {|sum, fc| sum += fc.n_clone_token}

        n_clone = fc_list.inject(0) {|sum, fc| sum += fc.n_clone_token_package(pkg_id_dst)}
        rate = (n_clone.quo n_all).to_f.round(4)
        puts "[#{pkg_id_src.to_i}][#{pkg_id_dst}] = #{rate}"
        table[pkg_id_src.to_i][pkg_id_dst.to_i] = CloneData.new(n_clone, n_all, rate)
      end
      #table[pkg_id_src.to_i][pkg.length] = (pkg_sum.quo n_all).to_f.round(4)
    end
    table[pkg.length] = table[0..(pkg.length-1)].transpose.map do |colum|
      sum_clone = colum.inject(0) {|sum, i| sum += i.n_clone if !i.nil?}
      sum_all = colum.inject(0) {|sum, i| sum += i.n_all if !i.nil?}
      rate = (sum_clone.quo sum_all).to_f.round(4)
      CloneData.new(sum_clone, sum_all, rate)
    end

    HeatmapOutput.new(table, @file_description.package_list).output (input_file + "_heatmap.html")
 end

  private
  def parse file_path
    section = []
    clone_set = CloneSet.new
    File.foreach(file_path) do |line|
      case line
      when /^#begin{(.+)}/
        section.push $1
        next
      when /^#end{(.+)}/
        section.pop
        if $1 == "set"
          @clone << clone_set.dup
          clone_set = CloneSet.new
        end
        next
      end

      case section
      when ["file description"]
        fd_unit = FileDescriptionUnit.new(line)
        @file_description[fd_unit.id] = fd_unit
      when ["clone", "set"]
        clone_set << ClonePiece.new(line)
     end
    end
  end


  def build_file_clone_list
    @file_description.each do |id, fd_unit|
      @file_clone_list[id] = FileClone.new(fd_unit)
    end
    @clone.each do |clone_set|
      index = @clone.index(clone_set)
      clone_set.each do |clone_piece|
        @file_clone_list[clone_piece.id].add_fill_token(clone_set, clone_piece.range)
      end
      puts "executed clone set #{index} of #{@clone.length}" if index % 1000 == 0
    end
  end
end

if $0 == __FILE__
  ccp = CCParser.new
  input_file = "./sample_data/crawler"
  ccp.output_histgram_and_heatmap(input_file)
end


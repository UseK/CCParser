$LOAD_PATH << File.dirname(__FILE__)
require 'erb'
require "file_clone"

class HeatmapOutput
  CloneData = Struct.new("CloneData", :n_clone, :n_all, :rate)
	def initialize file_clone_list, file_description
		@table = gen_table file_clone_list
		@package_list = file_description.package_list
	end

  def gen_table file_clone_list
    pkg = Hash.new {|h, k| h[k] = []}
    file_clone_list.each do |id, fc|
      pkg[fc.fd_unit.package] << fc
    end
    table = Array.new(pkg.length + 1) {Array.new(pkg.length)}
    pkg.each do |pkg_id_src, fc_list|
      n_all =  fc_list.inject(0) {|sum, fc| sum += fc.fd_unit.n_token}
      pkg.each_key do |pkg_id_dst|
        n_clone = fc_list.inject(0) {|sum, fc| sum += fc.n_clone_token_package(pkg_id_dst)}
        rate = (n_clone.quo n_all).to_f.round(4)
        puts "[#{pkg_id_src.to_i}][#{pkg_id_dst}] = #{rate}" if rate != 0.0
        table[pkg_id_src.to_i][pkg_id_dst.to_i] = CloneData.new(n_clone, n_all, rate)
      end
    end
    table[pkg.length] = table[0..(pkg.length-1)].transpose.map do |colum|
      sum_clone = colum.inject(0) {|sum, i| sum += i.n_clone if !i.nil?}
      sum_all = colum.inject(0) {|sum, i| sum += i.n_all if !i.nil?}
      rate = (sum_clone.quo sum_all).to_f.round(4)
      CloneData.new(sum_clone, sum_all, rate)
    end
    table
  end

	def output file_name
		template = ERB.new(File.open("./template/template.html.erb", "r").read)
		File.open(file_name, "w"){|f| f.write(template.result(binding))}
	end
end


$LOAD_PATH << File.dirname(__FILE__)
require 'erb'
require "file_clone"
require "table_cell"

class HeatmapOutput
  TEMPTLATE_RATE_PATH = File.dirname(__FILE__) + "/../template/template_rate.html.erb"
  TEMPTLATE_AMMOUNT_PATH = File.dirname(__FILE__) + "/../template/template_ammount.html.erb"
	def initialize file_clone_list, file_description
    @max_n_clone = 0
		@table = gen_table file_clone_list
		@file_description = file_description
    puts "max_n_clone == #{@max_n_clone}"
	end

	def output output_pathname, options={}
    options = {template: "rate"}.merge(options)
    case options[:template]
    when "rate"
      template_path = TEMPTLATE_RATE_PATH
    when "ammount"
      template_path = TEMPTLATE_AMMOUNT_PATH
    else
      template_path = TEMPTLATE_RATE_PATH
    end
		template = ERB.new(File.open(template_path, "r").read)
		output_pathname.open("w"){|f| f.write(template.result(binding))}
	end

  private

  private
  def gen_table file_clone_list
    pkg = gen_pkg file_clone_list
    table = gen_table_body pkg
    table << gen_table_footer(table)
  end

  def gen_pkg file_clone_list
    pkg = Hash.new {|h, k| h[k] = []}
    file_clone_list.each do |id, fc|
      pkg[fc.fd_unit.package] << fc
    end
    pkg
  end

  def gen_table_body pkg
    table = Array.new(pkg.length) {Array.new(pkg.length)}
    pkg.each do |pkg_id_src, fc_list|
      n_all =  fc_list.inject(0) {|sum, fc| sum += fc.fd_unit.n_token}
      pkg.each_key do |pkg_id_dst|
        cell = TableCell.new(calc_n_clone(fc_list, pkg_id_dst), n_all)
        puts "cell.rate[#{pkg_id_src}][#{pkg_id_dst}] = #{cell.rate}" if cell.rate != 0.0 && $DEBUG
        table[pkg_id_src.to_i][pkg_id_dst.to_i] = cell
      end
    end
    table
  end

  def calc_n_clone fc_list, pkg_id_dst
    n_clone = fc_list.inject(0) {|sum, fc| sum += fc.n_clone_token_package(pkg_id_dst)}
    @max_n_clone = [@max_n_clone, n_clone].max
    n_clone
  end

  def gen_table_footer table
    table.transpose.map do |colum|
      sum_clone = colum.inject(0) {|sum, i| sum += i.n_clone if !i.nil?}
      sum_all = colum.inject(0) {|sum, i| sum += i.n_all if !i.nil?}
      TableCell.new(sum_clone, sum_all)
    end
  end
end


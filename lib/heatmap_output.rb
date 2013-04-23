$LOAD_PATH << File.dirname(__FILE__)
require 'erb'
require "file_clone"
require "table_cell"
require "csv"
require "pp"

class HeatmapOutput
  TEMPTLATE_RATE_PATH = File.dirname(__FILE__) + "/../template/template_rate.html.erb"
  TEMPTLATE_AMMOUNT_PATH = File.dirname(__FILE__) + "/../template/template_ammount.html.erb"
	def initialize file_clone_list, file_description
    @max_n_clone = 0
		gen_table file_clone_list
		@file_description = file_description
    puts "max_n_clone == #{@max_n_clone}"
	end

	def output output_pathname, options={}
    options = {template: "rate", format: "html"}.merge(options)
    case options[:format]
    when "html"
      output_html output_pathname, options
    when "csv"
      output_csv output_pathname, options
    else
      raise "invalid format: #{options[:format]}"
    end
	end

  def output_html output_pathname, options
    case options[:template]
    when "rate"
      template_path = TEMPTLATE_RATE_PATH
    when "ammount"
      template_path = TEMPTLATE_AMMOUNT_PATH
    else
      raise "invalid template: #{optionts[:template]}"
    end
		template = ERB.new(File.open(template_path, "r").read)
		output_pathname.open("w"){|f| f.write(template.result(binding))}
  end

  def output_csv output_pathname, options
    CSV.open(output_pathname, "w") do |csv|
      header = @table.keys.map { |id| @file_description.package_list[id] }
      csv << (header.unshift nil)
      case options[:template]
      when "rate"
        @table.each do |id_row, row|
          csv << (row.map { |key, cell| cell.rate }.unshift @file_description.package_list[id_row])
        end
      when "ammount"
        @table.each do |id_row, row|
          csv << (row.map { |key, cell| cell.ammount }.unshift @file_description.package_list[id_row])
        end
      else
        raise "invalid template: #{optionts[:template]}"
      end
    end
  end

  private
  def gen_table file_clone_list
    #pkg = file_clone_list.group_by do |id, fc| puts fc.fd_unit.id; fc.fd_unit.package end
    pkg = gen_pkg file_clone_list
    @table, @table_arr = gen_table_body pkg
    @table_footer = gen_table_footer
  end

  def gen_pkg file_clone_list
    pkg = Hash.new {|h, k| h[k] = []}
    file_clone_list.each do |id, fc|
      pkg[fc.fd_unit.package] << fc
    end
    pkg
  end

  def gen_table_body pkg
    table_arr = Array.new(pkg.length) {Array.new(pkg.length)}
    table = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc)}
    pkg.each do |pkg_id_src, fc_list|
      n_all =  fc_list.inject(0) {|sum, fc| sum += fc.fd_unit.n_token}
      pkg.each_key do |pkg_id_dst|
        cell = TableCell.new(calc_n_clone(fc_list, pkg_id_dst), n_all)
        puts "cell.rate[#{pkg_id_src}][#{pkg_id_dst}] = #{cell.rate}" if cell.rate != 0.0 && $DEBUG
        table[pkg_id_src][pkg_id_dst] = cell
        table_arr[pkg_id_src.to_i][pkg_id_dst.to_i] = cell
      end
    end
    [table, table_arr]
  end

  def calc_n_clone fc_list, pkg_id_dst
    n_clone = fc_list.inject(0) {|sum, fc| sum += fc.n_clone_token_package(pkg_id_dst)}
    @max_n_clone = [@max_n_clone, n_clone].max
    n_clone
  end

#  def gen_table_body pkg
#    table = Array.new(pkg.length) {Array.new(pkg.length)}
#    pkg.each do |pkg_id_dst, fc_list_dst|
#      clone_set_list_dst = fc_list_dst.inject([]) {|sum, fc_dst| sum |= fc_dst.included_clone_set_list.map {|item| item.clone_set}}
#      pkg.each do |pkg_id_src, fc_list_src|
#        n_all =  fc_list_src.inject(0) {|sum, fc| sum += fc.fd_unit.n_token}
#        n_clone = fc_list_src.inject(0) {|sum, fc_src| sum += fc_src.n_clone_token_general(clone_set_list_dst)}
#        cell = TableCell.new(n_clone, n_all)
#        puts "cell.rate[#{pkg_id_src}][#{pkg_id_dst}] = #{cell.rate}" if cell.rate != 0.0 && $DEBUG
#        table[pkg_id_src.to_i][pkg_id_dst.to_i] = cell
#        @max_n_clone = [@max_n_clone, n_clone].max
#      end
#    end
#    table
#  end
#
#  def calc_n_clone fc_list_src, clone_set_list_dst
#    n_clone = fc_list_src.inject(0) {|sum, fc_src| sum += fc_src.n_clone_token_general(clone_set_list_dst)}
#    @max_n_clone = [@max_n_clone, n_clone].max
#    n_clone
#  end

  def gen_table_footer
    @table_arr.transpose.map do |colum|
      sum_clone = colum.inject(0) {|sum, i| sum += i.n_clone if !i.nil?}
      sum_all = colum.inject(0) {|sum, i| sum += i.n_all if !i.nil?}
      TableCell.new(sum_clone, sum_all)
    end
  end
end


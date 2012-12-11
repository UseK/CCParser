require 'erb'
class HeatmapOutput
	def initialize table, package_list
		@table = table
		@package_list = package_list
	end

	def output file_name
		template = ERB.new(File.open("./template/template.html.erb", "r").read)
		File.open(file_name, "w"){|f| f.write(template.result(binding))}
	end
end


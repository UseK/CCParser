class HistgramOutput
  def self.output output_file, file_clone_list
    File.open(output_file, "w") do |output_file|
      file_clone_list.each do |id, fc|
        arr = ["\"#{id}\"", fc.n_clone_token, fc.n_all_token, fc.content_rate.to_f.round(4)]
        puts arr.join(',')
        output_file.puts arr.join(',')
      end
    end
  end
end

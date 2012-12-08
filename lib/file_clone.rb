#encoding: utf-8

class FileClone

  attr_reader :token_list
  def initialize file_description_unit
    @file_description_unit = file_description_unit
    @token_list = Array.new(file_description_unit.n_token) {[]}
    @n_token = file_description_unit.n_token
  end

  def add_fill_token(ind, range)
    for i in range
      throw "#{range} is out #{@token_list.length}" if @token_list.length < i - 1
      @token_list[i-1] << ind
      throw "lentgh is cahged from #{@n_token} to #{@token_list.length}" if @n_token != @token_list.length
    end
  end

  def content_rate
    n_clone_token.quo n_all_token
  end

  def n_clone_token
    @token_list.select {|i| i != []}.length
  end

  def n_all_token
    @token_list.length
  end

  def id
    @file_description_unit.id
  end
end

if $0 == __FILE__
end

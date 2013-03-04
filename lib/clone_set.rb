#encoding: utf-8
$LOAD_PATH << File.dirname(__FILE__)
require "clone_piece"
class CloneSet < Array
  def include_package? package
    @pkg_list ||= update_pkg_list
    @pkg_list.include? package.to_s
  end

  def update_pkg_list
    pkg_list = []
    self.each do |cp|
      pkg_list << cp.package
    end
    pkg_list.uniq
  end
end

if $0 == __FILE__
  cs = CloneSet.new
  cs << ClonePiece.new("0.0\t6,8,4\t14,38,43\t39")
  cs << ClonePiece.new("0.1\t6,8,4\t14,38,43\t39")
  p cs.include_package? 0
  p cs.include_package? "0"
  p cs.include_package? 1
end

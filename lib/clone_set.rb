#encoding: utf-8
class CloneSet < Array
  def include_package? package
    each do |cp|
      if cp.package == package.to_s
        return true
      end
    end
    false
  end
end

if $0 == __FILE__
  $LOAD_PATH << File.dirname(__FILE__)
  require "clone_piece"
  cs = CloneSet.new
  cs << ClonePiece.new("0.0\t6,8,4\t14,38,43\t39")
  cs << ClonePiece.new("0.1\t6,8,4\t14,38,43\t39")
  p cs.include_package? 0
  p cs.include_package? "0"
  p cs.include_package? 1
end

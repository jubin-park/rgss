=begin
  title  Device module
 
  author jubin-park
  date   2016.12.05
  syntax ruby 1.8.7
  pltfrm android (neko player)
=end
#===============================================================================
if $NEKO_RUBY == 187 and RGSS.is_mobile?
#-------------------------------------------------------------------------------
module Device
  module_function
  def width() Graphics.entity.w end
  def height() Graphics.entity.h end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
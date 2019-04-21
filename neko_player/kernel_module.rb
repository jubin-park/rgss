=begin
  title  Kernel module (redefined)
 
  author jubin-park
  date   2016.12.05
  syntax ruby 1.8.7
  pltfrm android (neko player)
=end
#===============================================================================
if $NEKO_RUBY == 187 and RGSS.is_mobile?
#-------------------------------------------------------------------------------
module Kernel
  def print(*args)
    return if args.inspect.to_s =~ /(bgm_play|bgs_play|se_play|me_play) (.*)\\n/
    msgbox(*args)
  end
      
  def p(*args)
    str = String.new
    args.each{ |s| str << (s.inspect.to_s) + "\n" }
    SDL.showAlert(str)
  end
end
  
undef msgbox
def msgbox(*args)
  str = String.new
  args.each{ |s| str << (s.nil? ? "nil" : s.to_s) + "\n" }
  SDL.showAlert(str)
end
#-------------------------------------------------------------------------------
end
#===============================================================================
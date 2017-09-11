=begin
  title  Afreecatv banning

  author jubin-park
  date   2016.02.09
  syntax Ruby
  pltfrm PC
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
class << Input
  @@bitmap_notify_afreecatv = RPG::Cache.title("afreeca.png")
  @@sprite = Sprite.new
  @@sprite.bitmap = @@bitmap_notify_afreecatv
  @@sprite.opacity = 0
  @@sprite.z = 16777216
  FindWindow = Win32API.new('user32', 'FindWindow', 'pp', 'l')
  alias :update2 :update if !$@
  def update
    @afreeca_hwnd = FindWindow.call('Afreeca LiveCam Window', '')
    if @afreeca_hwnd != 0
      @@sprite.opacity += 10
      @@sprite.opacity = 255 if @@sprite.opacity > 255
    else
      update2
      @@sprite.opacity -= 10
      @@sprite.opacity = 0 if @@sprite.opacity < 0
    end
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
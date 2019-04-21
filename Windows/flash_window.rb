=begin
  title  FlashWindow
 
  author jubin-park
  date   2017.02.17
  syntax ruby
  pltfrm PC
=end

#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
class Win32API
  GetActiveWindow = new('user32', 'GetActiveWindow', 'v', 'l')
  FlashWindow     = new('user32', 'FlashWindow', 'll', 'l')
  FlashWindowEx   = new('user32', 'FlashWindowEx', 'p', 'l')
  
  FLASHW_STOP      = 0
  FLASHW_CAPTION   = 1
  FLASHW_TRAY      = 2
  FLASHW_ALL       = 3
  FLASHW_TIMER     = 4
  FLASHW_TIMERNOFG = 12
  
  HWND = GetActiveWindow.call
  FLASHWINFO = Struct.new(:cbSize, :hwnd, :dwFlags, :uCount, :dwTimeout)
  
  def Win32API.FlashWindow(dwFlags=FLASHW_TRAY, uCount=0, dwTimeout=0)
    hwnd = HWND
    if dwFlags < 0
      FlashWindow.call(hwnd, 0)
    else
      strct_flashwinfo = FLASHWINFO.new(20, hwnd, dwFlags, uCount, dwTimeout)
      strct_flashwinfo = strct_flashwinfo.to_a.pack("L*")
      FlashWindowEx.call(strct_flashwinfo)
    end
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
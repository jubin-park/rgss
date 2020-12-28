=begin
  title  Changing BackgroundImage

  author jubin-park
  refer  MSDN
  date   2020.12.29
  syntax Ruby (XP/VX/VXA)
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
module BackgroundImage
  SystemParametersInfo = Win32API.new('user32.dll', 'SystemParametersInfoW', 'llpl', 'l')

  SPI_SETDESKWALLPAPER = 0x14
  RGSS_VERSION = (RUBY_VERSION == "1.9.2" ? 3 : defined?(Hangup) ? 1 : 2) # by KK20
  
  module_function
  
  def change(path)
    if path.is_a?(String)
      SystemParametersInfo.call(SPI_SETDESKWALLPAPER, 0, (RUBY_VERSION == 1 ? path.to_m : path.to_unicode), 0)
    else
      raise "Invalid path type"
    end
  end
end

class String
  
  MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'llplpl', 'l')
  WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'llplplpp', 'l')
  
  CP_UTF8 = 65001

  def to_unicode
    len = MultiByteToWideChar.call(CP_UTF8, 0, self, -1, 0, 0) << 1
    buf = "\0" * len
    MultiByteToWideChar.call(CP_UTF8, 0, self, -1, buf, len)
    return buf
  end
  
  def to_m
    len = MultiByteToWideChar.call(CP_UTF8, 0, self, -1, nil, 0)
    buf = "\0" * (len * 2)
    MultiByteToWideChar.call(CP_UTF8, 0, self, -1, buf, buf.size / 2)
    len = WideCharToMultiByte.call(0, 0, buf, -1, nil, 0, nil, nil)
    ret = "\0" * len
    WideCharToMultiByte.call(0, 0, buf, -1, ret, ret.size, nil, nil)
    return ret
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================

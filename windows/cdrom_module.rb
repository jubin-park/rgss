=begin
  title  CDROM Door Open/Close
 
  author jubin-park
  date   2017.02.18
         2017.04.24
  syntax ruby
  pltfrm PC
=end

#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
module CDROM
  module_function
  
  DRIVE_COROM = 5
  FILE_ATTRIBUTE_DIRECTORY = 0x10
  
  MciSendString = Win32API.new('winmm', 'mciSendString', 'ppll', 'l')
  GetDriveType = Win32API.new('kernel32', 'GetDriveType', 'p', 'l')
  GetFileAttributes = Win32API.new('kernel32', 'GetFileAttributesA', 'p', 'l')
  GetLogicalDriveStrings = Win32API.new('kernel32', 'GetLogicalDriveStringsA', 'lp', 'l')

  def open
    begin
      r = MciSendString.call('set cdaudio door open', nil, 0, 0); r
    rescue Hangup; r
    end
  end
  
  def close
    begin
      r = MciSendString.call('set cdaudio door closed', nil, 0, 0); r
    rescue Hangup; r
    end
  end
  
  def hasCD?
    buf = '\0' * 256
    s = GetLogicalDriveStrings.call(buf.size, buf)
    drvs = buf[0,s].split("\000")
    for drv in drvs
      type = GetDriveType.call(drv)
      if type == DRIVE_COROM
        case GetFileAttributes.call(drv)
        when FILE_ATTRIBUTE_DIRECTORY
          return true
        when -1
          return false
        end
      end
    end
    return false
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
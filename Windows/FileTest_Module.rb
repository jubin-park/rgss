=begin
  title  FileTest module (Unicode)
 
  author jubin-park
  date   2014.12.29
         2016.12.23
  syntax ruby
  pltfrm PC
=end

#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
module FileTest
  
  PathFileExists  = Win32API.new('Shlwapi', 'PathFileExistsW', 'p', 'l')
  PathIsDirectory = Win32API.new('Shlwapi', 'PathIsDirectoryW', 'p', 'l')
  CreateFile      = Win32API.new('kernel32', 'CreateFileW', 'pllllll', 'l')
  GetFileSize     = Win32API.new('kernel32', 'GetFileSize', 'll', 'l')
  CloseHandle     = Win32API.new('kernel32', 'CloseHandle', 'l', 'l')
  
  module_function
  
  def exist?(filename)
    PathFileExists.call(filename.to_unicode) == 0x1
  end
  
  def directory?(filename)
    PathIsDirectory.call(filename.to_unicode) == 0x10
  end

  def file?(filename)
    PathIsDirectory.call(filename.to_unicode) == 0
  end

  def size(filename)
    h = CreateFile.call(filename.to_unicode, 0x80000000, 0, 0, 3, 0, 0)
    size = GetFileSize.call(h, 0)
    CloseHandle.call(h)
    if size < 0
      begin
        raise Errno::ENOENT, filename, caller
      end
    end
    return size
  end
end

class String
  
  MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'llplpl', 'l')
  
  def to_unicode
    len = MultiByteToWideChar.call(65001, 0, self, -1, 0, 0)
    buf = '\0' * len
    MultiByteToWideChar.call(65001, 0, self, -1, buf, len)
    return buf
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
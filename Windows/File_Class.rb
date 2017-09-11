=begin
  title  File (Unicode)
 
  author jubin-park
  date   2014.12.29
         2016.12.23
  syntax ruby
  pltfrm PC
=end

#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
class File
  
  S_OK = 0x0
  E_OUTOFMEMORY = 0x8007000E
  INET_E_DOWNLOAD_FAILURE = 0x800C0008
  
  URLDownloadToFile   = Win32API.new('urlmon', 'URLDownloadToFileW', 'lppll', 'l')
  DeleteUrlCacheEntry = Win32API.new('wininet', 'DeleteUrlCacheEntryW', 'p', 'l')
  CopyFile            = Win32API.new('kernel32', 'CopyFileW', 'ppl', 'l')
  ShellExecute        = Win32API.new('shell32', 'ShellExecuteW', 'lppppl','l')
  
  # 파일 다운로드
  def self.download(url, filename=nil)
    filename = url.split("/").last if filename.nil?
    value = URLDownloadToFile.call(0, url.to_unicode, filename.to_unicode, 0, 0)
    case value
    when S_OK
      # 이전 캐시 삭제
      DeleteUrlCacheEntry.call(url.to_unicode)
      return true
    when E_OUTOFMEMORY
      print 'Error: E_OUTOFMEMORY'
    when INET_E_DOWNLOAD_FAILURE
      print 'Error: INET_E_DOWNLOAD_FAILURE'
    end
    return false
  end
  
  # 파일 복사
  def self.copy(filename_from, filename_to, overwriting = true)
    # 동일 파일 존재시 // overwriting = true : 덮어쓰기, false : 복사 취소
    CopyFile.call(filename_from.to_unicode, filename_to.to_unicode, overwriting == true ? 0 : (1 if overwriting == false))
  end
  
  # 파일 실행
  def self.execute(filename, operation = 'open')
    filename = filename.to_a
    ShellExecute.call(0, operation.to_unicode, filename[0].to_unicode, filename[1].nil? ? 0 : filename[1].to_unicode, 0, 1)
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
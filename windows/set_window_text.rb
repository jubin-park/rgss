=begin
  title  SetWindowText
 
  author jubin-park
  date   2017.08.25
  syntax ruby
  pltfrm PC
=end

#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------

module WindowText
  
  OpenProcess             = Win32API.new('kernel32', 'OpenProcess', 'lll', 'l')
  GetCurrentProcessId     = Win32API.new('kernel32', 'GetCurrentProcessId', 'V', 'L')
  GetModuleHandle         = Win32API.new('kernel32', 'GetModuleHandleA', 'p', 'l')
  VirtualProtectEx        = Win32API.new('kernel32', 'VirtualProtectEx', 'lpppp', 'l')
  ReadProcessMemory       = Win32API.new('kernel32', 'ReadProcessMemory', 'lppll', 'l')
  WriteProcessMemory      = Win32API.new('kernel32', 'WriteProcessMemory', 'lppll', 'l')
  CloseHandle             = Win32API.new('kernel32', 'CloseHandle', 'l', 'l')
  GetModuleHandle         = Win32API.new('kernel32', 'GetModuleHandleA', 'p', 'l')
  GetPrivateProfileString = Win32API.new('kernel32', 'GetPrivateProfileString', 'pppplp', 'l')
  
  PROCESS_ALL_ACCESS      = 0x1F0FFF
  PAGE_EXECUTE_READWRITE  = 0x40
  
  RGSS_VERSION = (RUBY_VERSION == "1.9.2" ? 3 : defined?(Hangup) ? 1 : 2) # by KK20
  
  ENV_DATA = {
    "path"     => ["", "./RGSS10*.dll", "./RGSS20*.dll", "./System/RGSS30*.dll"],
    "off_base" => [0, 0x0016A7AC, 0x0016EFE4, 0x0025EB00],
  }

  @found = false
  
  def self.init
    # RGSS 라이브러리 검색
    buffer = "\0" * 256
    GetPrivateProfileString.call('Game', 'Library', '', buffer, buffer.size, './Game.ini')
    ENV_DATA["path"][RGSS_VERSION] = "./" << buffer
    ENV_DATA["path"][RGSS_VERSION].delete!("\0").gsub!("\\", "/")
    dir = Dir.glob(ENV_DATA["path"][RGSS_VERSION])[0]
    @found = !(dir == [])
    return if !@found
    # DLL
    const_set("RGSS_DLL", GetModuleHandle.call(File.basename(dir)))
    # 고정 주소값
    const_set("OFFSET_BASE", RGSS_DLL + ENV_DATA["off_base"][RGSS_VERSION])
    # 타이틀 텍스트 오프셋
    const_set("OFFSET_WindowText", _ReadProcessMemory(OFFSET_BASE, 8)[0] + 0xC)
    # 기본 타이틀 텍스트
    buffer = "\0" * 1024
    GetPrivateProfileString.call('Game', 'Title', '', buffer, buffer.size, './Game.ini')
    const_set("ORIGN_NAME", buffer)
  end
  
  def self._WriteProcessMemory(offset, value)
    return if !@found
    nsize = value.size
    hprocess = OpenProcess.call(PROCESS_ALL_ACCESS, 0, GetCurrentProcessId.call)
    VirtualProtectEx.call(hprocess, offset, 4, PAGE_EXECUTE_READWRITE, oldprotect='\0'*4)
    oldprotect = oldprotect.unpack('l*')[1].to_i
    WriteProcessMemory.call(hprocess, offset, value, nsize, 0)
    CloseHandle.call(hprocess)
  end
    
  def self._ReadProcessMemory(offset, nsize)
    return if !@found
    hprocess = OpenProcess.call(PROCESS_ALL_ACCESS, 0, GetCurrentProcessId.call)
    lpBuffer = "\0" * nsize
    ReadProcessMemory.call(hprocess, offset, lpBuffer, nsize, 0)
    return lpBuffer.unpack('l*')
    CloseHandle.call(hprocess)
  end
  
  def self.set(text)
    return if !@found
    text = ORIGN_NAME if (text.nil? || text == :default)
    _WriteProcessMemory(OFFSET_WindowText, ( RGSS_VERSION == 1 ? text.to_m : text.to_unicode ))
  end
  init()
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
    buf = "\0" * (len*2)
    MultiByteToWideChar.call(CP_UTF8, 0, self, -1, buf, buf.size/2)
    len = WideCharToMultiByte.call(0, 0, buf, -1, nil, 0, nil, nil)
    ret = "\0" * len
    WideCharToMultiByte.call(0, 0, buf, -1, ret, ret.size, nil, nil)
    return ret
  end
end

#-------------------------------------------------------------------------------
end
#===============================================================================
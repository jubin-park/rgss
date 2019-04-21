=begin
  title  RGSS Font Setup
 
  author jubin-park
  refer  MSDN
  date   2015.12.31
  syntax Ruby (XP)
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
FindWindow                = Win32API.new('user32', 'FindWindow', 'pp', 'l')
ShellExecute              = Win32API.new('shell32', 'ShellExecute', 'lppppl','l')
MultiByteToWideChar       = Win32API.new('kernel32', 'MultiByteToWideChar', 'llplpl', 'l')
WideCharToMultiByte       = Win32API.new('kernel32', 'WideCharToMultiByte', 'llplplpp', 'l')
GetWindowTextLength       = Win32API.new('user32', 'GetWindowTextLength', 'l', 'l')
SendMessage               = Win32API.new('user32', 'SendMessageA', 'llll', 'l')
CloseHandle               = Win32API.new('kernel32', 'CloseHandle', 'l', 'l')
GetWindowText             = Win32API.new('user32', 'GetWindowText', 'lpl', 'l')
AddFontResource           = Win32API.new('gdi32', 'AddFontResource', 'p', 'l')
AddFontResourceEx         = Win32API.new('gdi32', 'AddFontResourceEx', 'PLL', 'L')
RemoveFontResource        = Win32API.new('gdi32', 'RemoveFontResource', 'p', 'l')
RemoveFontResourceEx      = Win32API.new('gdi32', 'RemoveFontResourceEx', 'pll', 'l')
SendNotifyMessage         = Win32API.new('user32', 'SendNotifyMessage', 'llll', 'l')

class String
  CP_UTF8 = 65001
  
  def to_u
    len = MultiByteToWideChar.call(0, 0, self, -1, nil, 0)
    buf = '\0' * (len*2)
    MultiByteToWideChar.call(0, 0, self, -1, buf, buf.size/2)
    len = WideCharToMultiByte.call(65001, 0, buf, -1, nil, 0, nil, nil)
    ret = '\0' * len
    WideCharToMultiByte.call(65001, 0, buf, -1, ret, ret.size, nil, nil)
    return ret
  end
  
  def to_m
    len = MultiByteToWideChar.call(CP_UTF8, 0, self, -1, nil, 0)
    buf = 0.chr * (len*2)
    MultiByteToWideChar.call(CP_UTF8, 0, self, -1, buf, buf.size/2)
    len = WideCharToMultiByte.call(0, 0, buf, -1, nil, 0, nil, nil)
    ret = 0.chr * len
    WideCharToMultiByte.call(0, 0, buf, -1, ret, ret.size, nil, nil)
    return ret
  end
end

class File
  def File.execute(filename, sw = 1, operation = 'open')
    filename = filename.to_a
    ShellExecute.call(0, operation.to_m, filename[0].to_m, filename[1].nil? ? 0 : filename[1].to_m, 0, sw)
  end
end
  
class Font
  
  HKEY_LOCAL_MACHINE = 0x80000002
  REG_SZ = 1
  FONT_DIR = "./Fonts/"
  
  Dir.mkdir(FONT_DIR) if !(FileTest.exist?(FONT_DIR) and FileTest.directory?(FONT_DIR))
  
  def self.FontView(filename)
    while (hwnd = FindWindow.call('FontViewWClass', 0)) != 0
      break if hwnd == 0
      SendMessage.call(hwnd, 2, 0, 0) # WM_DESTROY
      SendMessage.call(hwnd, 16, 0, 0) # WM_CLOSE
      SendMessage.call(hwnd, 18, 0, 0) # WM_QUIT
      SendMessage.call(hwnd, 130, 0, 0) # WM_NCDESTROY
      CloseHandle.call(hwnd)
    end
    File.execute(["Fontview.exe", filename], 0); sleep 0.2
    hwnd = FindWindow.call('FontViewWClass', 0)
    length = GetWindowTextLength.call(hwnd)
    str = '\0' * (length + 1)
    GetWindowText.call(hwnd, str, length)
    return str.to_u.delete("\u0000").delete('\\0').delete('\\')
  end
  
  def self.to_name(filename)
    FontView(filename).gsub(/(.*)\(트루타입\)|(.*) \(OpenType\)/) do
      if $1 and $1 != ""
        return $1
      elsif $2 and $2 != ""
        return $2
      end
    end
  end
  
  def self.to_type(filename)
    return "TrueType" if (FontView(filename) =~ /\(트루타입\)/)
    return "OpenType" if (FontView(filename) =~ / \(OpenType\)/)
  end
  
  def self.setup(filename)
    # 문자 변환
    fontname = to_name(filename)
    # 폰트 존재시, 설치 중단
    return false if Font.exist?(fontname)
    # 폰트 추가
    AddFontResource.call(filename.to_m)
    AddFontResourceEx.call(filename.to_m, 16, 0)
    # 메세지 전송
    SendMessage.call(0xffff, 0x1D, 0, 0)
    SendNotifyMessage.call(0xffff, 0x1D, 0, 0)
    # 재시작
    if not Font.exist?(fontname)
      print "'#{fontname}' 폰트 설치를 위해 게임을 재시작 합니다."
      File.execute([File.expand_path(".") + "/Game.exe"])
      exit
    end
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
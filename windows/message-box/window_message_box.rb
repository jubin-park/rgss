=begin
  title  Window MessageBox
 
  author jubin-park
  date   2014.12.27
         2016.12.22
         2017.04.24
  syntax ruby
  pltfrm PC
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------

MessageBox              = Win32API.new('user32', 'MessageBoxW', 'lppl', 'l')
GetActiveWindow         = Win32API.new('user32', 'GetActiveWindow', 'v', 'l')
MultiByteToWideChar     = Win32API.new('kernel32', 'MultiByteToWideChar', 'llplpl', 'l')
WideCharToMultiByte     = Win32API.new('kernel32', 'WideCharToMultiByte', 'llplplpp', 'l')
GetWindowTextW          = Win32API.new('user32', 'GetWindowTextW', 'lpl', 'l')
GetWindowTextLengthW    = Win32API.new('user32', 'GetWindowTextLengthW', 'l', 'l')
GetPrivateProfileString = Win32API.new('kernel32', 'GetPrivateProfileStringA', 'pppplp', 'l')
FindWindow              = Win32API.new('user32', 'FindWindow', 'pp', 'l')

class String
  CP_UTF8 = 65001
  def to_unicode
    len = MultiByteToWideChar.call(CP_UTF8, 0, self, -1, 0, 0) << 1
    buf = 0.chr * len
    MultiByteToWideChar.call(CP_UTF8, 0, self, -1, buf, len)
    return buf
  end
  def to_UTF8
    len = WideCharToMultiByte.call(CP_UTF8, 0, self, -1, 0, 0, 0, 0)
    buf = 0.chr * len
    WideCharToMultiByte.call(CP_UTF8, 0, self, -1, buf, len, 0, 0)
    return buf
  end
end

module MB
  
  module_function
  
  def hwnd
    buf = '\0' * 256
    GetPrivateProfileString.call('Game', 'Title', '', buf, buf.size, './Game.ini')
    handle = FindWindow.call('RGSS Player', buf)
    return (handle == 0 ? GetActiveWindow.call : handle)
  end

  def caption
    length = GetWindowTextLengthW.call(HWND) << 1 # 2바이트
    str = 0.chr * length
    GetWindowTextW.call(HWND, str, str.size)
    return str.to_UTF8[0..-2] # NULL 제거
  end
  
  HWND = hwnd()
  
  OK                = 0
  OKCANCEL          = 1
  ABORTRETRYIGNORE  = 2
  YESNOCANCEL       = 3
  YESNO             = 4
  RETRYCANCEL       = 5
  CANCELTRYCONTINUE = 6
  HELP              = 0x00004000
  
  ICONSTOP          = 16
  ICONQUESTION      = 32
  ICONEXCLAMATION   = 48
  ICONINFORMATION   = 64
  DEFBUTTON1        = 0x00000000
  DEFBUTTON2        = 0x00000100
  DEFBUTTON3        = 0x00000200
  DEFBUTTON4        = 0x00000300
  RIGHT             = 0x00080000
  RTLREADING        = 0x00100000
  TOPMOST           = 0x00040000
  
  IDOK              = 1
  IDCANCEL          = 2
  IDABORT           = 3
  IDRETRY           = 4
  IDIGNORE          = 5
  IDYES             = 6
  IDNO              = 7
  IDTRYAGAIN        = 10
  IDCONTINUE        = 11
end

module Kernel
  def msgbox(*args, &block)
    wType = 0
    lpCaption = MB.caption.to_unicode
    if !block.nil?
      b = block.call
      case b.class.to_s
      when "Array" # [type, title]
        if b.size == 1
          if b[0].is_a?(String)
            lpCaption = b[0].to_unicode
          elsif b[0].is_a?(Numeric)
            wType = b[0]
          end
        elsif b.size == 2
          wType = b[0]
          lpCaption = b[1].to_unicode
        end
      when "Fixnum" # type
        wType = b
      when "String" # title
        lpCaption = b.to_unicode
      end
    end
    lpText = ""
    args.each{ |arg| lpText << (arg.nil? ? "nil" : arg.to_s) + "\n" }
    lpText = lpText.to_unicode
    begin
      r = MessageBox.call(MB::HWND, lpText, lpCaption, wType); r
    rescue Hangup; r
    end
  end
  
  def msgbox_p(*args, &block)
    wType = 0
    lpCaption = MB.caption.to_unicode
    if !block.nil?
      b = block.call
      case b.class.to_s
      when "Array" # [type, title]
        if b.size == 1
          if b[0].is_a?(String)
            lpCaption = b[0].to_unicode
          elsif b[0].is_a?(Numeric)
            wType = b[0]
          end
        elsif b.size == 2
          wType = b[0]
          lpCaption = b[1].to_unicode
        end
      when "Numeric" # type
        wType = b
      when "String" # title
        lpCaption = b.to_unicode
      end
    end
    lpText = ""
    args.each{ |arg| lpText << (arg.inspect) + "\n" }
    lpText = lpText.to_unicode
    begin
      r = MessageBox.call(MB::HWND, lpText, lpCaption, wType); r
    rescue Hangup; r
    end  
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
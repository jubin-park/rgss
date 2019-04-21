=begin
  title  Shell_NotifyIcon
 
  author jubin-park
  date   2017.03.28
  syntax ruby
  pltfrm PC
=end
 
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
class String
  
  MultiByteToWideChar     = Win32API.new('kernel32', 'MultiByteToWideChar', 'llplpl', 'l')
  WideCharToMultiByte     = Win32API.new('kernel32', 'WideCharToMultiByte', 'llplplpp', 'l')
  
  def to_unicode
    len = MultiByteToWideChar.call(65001, 0, self, -1, 0, 0)
    buf = '\0' * len
    MultiByteToWideChar.call(65001, 0, self, -1, buf, len)
    return buf
  end
  
  def to_UTF8
    len = WideCharToMultiByte.call(65001, 0, self, -1, 0, 0, 0, 0)
    buf = 0.chr * len
    WideCharToMultiByte.call(65001, 0, self, -1, buf, len, 0, 0)
    return buf
  end
end

class Win32API
  
  GetWindowTextW          = Win32API.new('user32', 'GetWindowTextW', 'lpl', 'l')
  GetWindowTextLengthW    = Win32API.new('user32', 'GetWindowTextLengthW', 'l', 'l')
  GetPrivateProfileString = Win32API.new('kernel32', 'GetPrivateProfileStringA', 'pppplp', 'l')
  FindWindow              = Win32API.new('user32', 'FindWindow', 'pp', 'l')
  Shell_NotifyIconW       = Win32API.new('shell32', 'Shell_NotifyIconW', 'ip', 'i')
  GetActiveWindow         = Win32API.new('user32', 'GetActiveWindow', 'v', 'i')
  ExtractIcon             = Win32API.new('shell32','ExtractIconW','ipl','l')
  
  NIM_ADD         = 0x00000000
  NIM_MODIFY      = 0x00000001
  NIM_DELETE      = 0x00000002
  NIM_SETFOCUS    = 0x00000003
  NIM_SETVERSION  = 0x00000004

  NIF_MESSAGE     = 0x00000001
  NIF_ICON        = 0x00000002
  NIF_TIP         = 0x00000004
  NIF_STATE       = 0x00000008
  NIF_INFO        = 0x00000010
  NIF_GUID        = 0x00000020
  NIF_REALTIME    = 0x00000040
  NIF_SHOWTIP     = 0x00000080

  NIIF_NONE       = 0x00000000
  NIIF_INFO       = 0x00000001
  NIIF_WARNING    = 0x00000002
  NIIF_ERROR      = 0x00000003
  NIIF_USER       = 0x00000004
  NIIF_NOSOUND    = 0x00000010
  NIIF_LARGE_ICON = 0x00000020
  NIIF_ICON_MASK  = 0x0000000F

  NOTIFYICONDATA_W = Struct.new(
    :cbSize,
    :hWnd,
    :uID,
    :uFlags,
    :uCallbackMessage,
    :hIcon,
    :szTip,
    :dwState,
    :dwStateMask,
    :szInfo,
    :uTimeoutOrVersion,
    :szInfoTitle,
    :dwInfoFlags,
    :guidItem,
    :hBalloonIcon
  )
  
  protected
  
  def self.getHwnd
    buf = '\0' * 256
    GetPrivateProfileString.call('Game', 'Title', '', buf, buf.size, File.join(Dir.pwd, 'Game.ini'))
    handle = FindWindow.call('RGSS Player', buf)
    return (handle == 0 ? GetActiveWindow.call : handle)
  end

  def self.getCaption
    length = GetWindowTextLengthW.call(getHwnd()) << 1
    str = 0.chr * length
    GetWindowTextW.call(getHwnd(), str, str.size)
    return str.to_UTF8[0..-2]
  end
  
  private
  
  def self.NotifyIcon(_szInfoTitle, _szInfo, _icon=0, _szTip=getCaption())
    hwnd = getHwnd()
    lpdata = NOTIFYICONDATA_W.new
    # 0
    lpdata.cbSize = 936
    # 1
    lpdata.hWnd = hwnd
    # 2
    lpdata.uID = hwnd
    # 3
    lpdata.uFlags = NIF_INFO | NIF_TIP | NIF_REALTIME | NIF_STATE | NIF_ICON
    # 4
    lpdata.uCallbackMessage = 0
    # 5
    lpdata.hIcon = ExtractIcon.call(0, File.join(Dir.pwd, "Game.exe").to_unicode, 0)
    # 6
    lpdata.szTip = _szTip.to_unicode
    # 7
    lpdata.dwState = 0
    # 8
    lpdata.dwStateMask = 0
    # 9
    lpdata.szInfo = _szInfo.to_unicode
    # 10
    lpdata.uTimeoutOrVersion = 10000
    # 11
    lpdata.szInfoTitle = _szInfoTitle.to_unicode
    # 12
    lpdata.dwInfoFlags = _icon
    # 13
    lpdata.guidItem = 0
    lpdata_arr = lpdata.to_a
    lpdata_packed = lpdata_arr.pack("l6a256l2a512la128l2")
    Shell_NotifyIconW.call(@uID.nil? ? NIM_ADD : NIM_MODIFY, lpdata_packed)
    @uID ||= lpdata.uID
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
=begin
  title  RGSS1 Resolution
  
  author jubin-park
  reused
  scripts
  
  * FullScreen (ChangeDisplaySettings)
  发表于
  : http://bbs.66rpg.com/forum.php?mod=viewthread&tid=156438
  
  * XP Ace Tilemap
  KK20 - Author of this script and DLL
  Zexion - Tester and morale support
  ForeverZer0 - Reusing code from his Custom Resolution script, found here:
  http://forum.chaos-project.com/index.php/topic,7814.0.html
  LiTTleDRAgo - Reusing code from his edits to Custom Resolution
  : http://forum.chaos-project.com/index.php?PHPSESSID=ac6a229b4877a627bdd72a4ef877eefe&topic=14638.0

  date   2015.12.28
  syntax Ruby 1.8.1 (RMXP)
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
# 윈도우 너비, 높이
$WINDOW_WIDTH, $WINDOW_HEIGHT = 800, 600

# 시작 시 풀스크린
$WINDOW_FULLSCREEN = true

# 인게임 Alt + Enter 허용
$WINDOW_ALTENTER = true

module Game
  # Win32API 함수
  FindWindow              = Win32API.new('user32', 'FindWindow', 'pp', 'l')
  GetActiveWindow         = Win32API.new('user32', 'GetActiveWindow', 'v', 'l')
  GetPrivateProfileString = Win32API.new('kernel32', 'GetPrivateProfileString', 'pppplp', 'l')
  # 윈도우 핸들
  def self.hWnd()
    buffer = 0.chr * 256
    GetPrivateProfileString.call('Game', 'Title', '', buffer, buffer.size, './Game.ini')
    hwnd = FindWindow.call('RGSS Player', buffer.delete!(0.chr))
    hwnd = GetActiveWindow.call if hwnd == false
    return hwnd
  end
end

module Graphics
  module_function
  
  # Win32API 함수
  FindWindow              = Win32API.new('user32', 'FindWindow', 'pp', 'l')
  GetWindowRect           = Win32API.new('user32', 'GetWindowRect', 'lp', 'l')
  GetSystemMetrics        = Win32API.new('user32', 'GetSystemMetrics', 'l', 'l')
  GetAsyncKeyState        = Win32API.new('user32', 'GetAsyncKeyState', 'l', 'l')
  AdjustWindowRect        = Win32API.new('user32', 'AdjustWindowRect', 'pll', 'l')
  GetClientRect           = Win32API.new('user32', 'GetClientRect', 'lp','i')
  ChangeDisplaySettings   = Win32API.new('user32', 'ChangeDisplaySettingsW', 'pl', 'l')
  SetWindowLong           = Win32API.new('user32', 'SetWindowLongA', 'pll', 'l')
  GetWindowLong           = Win32API.new('user32', 'GetWindowLongA', 'll', 'l')
  SetWindowPos            = Win32API.new('user32', 'SetWindowPos', 'lllllll', 'l')
  RegisterHotKey          = Win32API.new('user32', 'RegisterHotKey', 'llll', 'l')
  GetDesktopWindow        = Win32API.new('user32', 'GetDesktopWindow', 'v', 'l')
  GetForegroundWindow     = Win32API.new('user32', 'GetForegroundWindow', 'v', 'l')
  GetAncestor             = Win32API.new('user32', 'GetAncestor', 'll', 'l')
  GetClassName            = Win32API.new('user32', 'GetClassName', 'lpl', 'l')
  
  # 상수
  GWL_STYLE      = -16
  WS_BORDER      = 0x800000
  SWP_SHOWWINDOW = 0x40
  PELSHEIGHT     = 0x100000
  PEDTH          = 0x80000
  BITSPERPEL     = 0x00040000
  PELSWIDTH      = 0x00080000
  PELSHEIGHT     = 0x00100000
  CDS_FULLSCREEN = 0x00000004
  CDS_RESET = 0x40000000
  HWND_TOP = 0
  HWND_TOPMOST = -1
  MOD_ALT = 0x0001
  VK_RETURN = 0x0D
  KEY_LALT = 0xA4
  KEY_RETURN = 0x0D
  GA_ROOT = 2
  
  # 윈도우 핸들
  HWND = Game.hWnd()
  
  # 윈도우 스타일
  WIN_STYLE = GetWindowLong.call(HWND, GWL_STYLE)
  
  # 윈도우 크기
  WIN_RECT = [GetSystemMetrics.call(0), GetSystemMetrics.call(1)]
  
  # 작업표시줄 크기
  def getTraySize
    buf = 0.chr * 16
    GetWindowRect.call(FindWindow.call('Shell_TrayWnd', 0), buf)
    buf = buf.unpack('l4')
    tw = (buf[2]-buf[0]).abs
    th = (buf[3]-buf[1]).abs
    return (tw >= WIN_RECT[0] ? 0 : tw), (th >= WIN_RECT[1] ? 0 : th)
  end
  TRAY_RECT = getTraySize()
  
  # 외부 Alt + Enter 키 금지
  RegisterHotKey.call(HWND, 0, MOD_ALT, VK_RETURN)
  
  # DEVMODE 구조체
  def self.getDEVMODE(width, height)
    devmode =
    [
      0,0,0,0,0,0,0,0,                # Q8
      0,                              # L
      220,                            # S
      0,                              # S
      BITSPERPEL|PELSWIDTH|PELSHEIGHT,# L
      0,0,                            # Q2
      0,0,0,0,0,                      # S5
      0,0,0,0,0,0,0,0,                # Q8
      # dmLogPixels
      0,                              # S
      # dmBitsPerPel
      32,                             # L
      # dmPelsWidth
      width,                          # L
      # dmPelsHeight
      height,                         # L
      # dmDitherType
      0,                              # Q
      0,0,0,0                         # Q4
    ].pack('Q8 L S2 L Q2 S5 Q8 S L3 Q5') 
    return devmode
  end

  # 윈도우 크기 취득
  def rect
    pos = ([0]*4).pack('l4')
    GetClientRect.call(HWND, pos)
    return pos.unpack('l4')
  end
  
  # 너비
  def width; @width=rect[2] end
  
  # 높이
  def height; @height=rect[3] end
  
  # 풀스크린 여부
  def is_fullscreen?
    activeWnd = GetForegroundWindow.call
    return false if activeWnd == 0
    activeWnd = GetAncestor.call(activeWnd, GA_ROOT)
    return false if activeWnd == 0
    buf = ' ' * 256
    return false if GetClassName.call(HWND, buf, buf.size) == 0
    buf[/\000.*/] = ''
    classname = buf
    return false if (desktopWnd = GetDesktopWindow.call) == 0
    desktop = ([0]*4).pack('l4')
    return false if GetWindowRect.call(desktopWnd, desktop) == 0
    desktop = desktop.unpack('l4')
    client = ([0]*4).pack('l4')
    return false if GetClientRect.call(activeWnd, client) == 0
    client = client.unpack('l4')
    clientSize = [ client[2] - client[0], client[3] - client[1] ]
    desktopSize = [ desktop[2] - desktop[0], desktop[3] - desktop[1] ]
    return false if (clientSize[0] < desktopSize[0] || clientSize[1] < desktopSize[1])
    return activeWnd == HWND
  end

  # 해상도 변경
  def resize_screen(width, height, fullscreen=false)
    if fullscreen
      SetWindowLong.call(HWND, GWL_STYLE, 0)
      SetWindowPos.call(HWND, HWND_TOPMOST, 0, 0, width, height, SWP_SHOWWINDOW)
      r = ChangeDisplaySettings.call(getDEVMODE(width, height), CDS_FULLSCREEN)
      if r == -2
        print "현재 설정된 해상도는 풀스크린 모드를 사용할 수 없습니다.\n창모드로 진행합니다."
        resize_screen(width, height)
      end
    else
      SetWindowLong.call(HWND, GWL_STYLE, WIN_STYLE)
      ChangeDisplaySettings.call(0, CDS_RESET) if Graphics.is_fullscreen?
      AdjustWindowRect.call(rect=[0,0,width,height].pack('i4'), WIN_STYLE, 0)
      rect = rect.unpack('i4')
      size = [rect[2] - rect[0], rect[3] - rect[1]]
      x = WIN_RECT[0] - TRAY_RECT[0] - size[0]
      y = WIN_RECT[1] - TRAY_RECT[1] - size[1]
      SetWindowPos.call(HWND, HWND_TOP, (x/2.0).round, (y/2.0).round, size[0], size[1], SWP_SHOWWINDOW)
    end
  end
  
  # 인게임 Alt + Enter 키 누를 시 처리
  def self.alt_enter?
    if GetAsyncKeyState.call(KEY_LALT) & 0x8000 > 0
      if GetAsyncKeyState.call(KEY_RETURN) & 0x8000 > 0
        Graphics.resize_screen(Graphics.width, Graphics.height, !Graphics.is_fullscreen?)
      end
    end
  end
end

module Input
  class << self
    alias :resolution_update :update unless $@
    def update(*args)
      resolution_update(*args)
      Graphics.alt_enter? if $WINDOW_ALTENTER
    end
  end
end

Graphics.resize_screen($WINDOW_WIDTH, $WINDOW_HEIGHT, $WINDOW_FULLSCREEN)
#-------------------------------------------------------------------------------
end
#===============================================================================
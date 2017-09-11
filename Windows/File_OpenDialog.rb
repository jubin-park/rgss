=begin
  title  File.OpenDialog
 
  author jubin-park
  refer  MSDN
  date   2016.01.20
  syntax Ruby
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'llplpl', 'l')
WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'llplplpp', 'l')

def s2u(text)
  len = MultiByteToWideChar.call(0, 0, text, -1, nil, 0)
  buf = '\0' * (len*2)
  MultiByteToWideChar.call(0, 0, text, -1, buf, buf.size/2)
  len = WideCharToMultiByte.call(65001, 0, buf, -1, nil, 0, nil, nil)
  ret = '\0' * len
  WideCharToMultiByte.call(65001, 0, buf, -1, ret, ret.size, nil, nil)
  return ret
end

def u2s(text)
  len = MultiByteToWideChar.call(65001, 0, text, -1, nil, 0)
  buf = '\0' * (len*2)
  MultiByteToWideChar.call(65001, 0, text, -1, buf, buf.size/2)
  len = WideCharToMultiByte.call(0, 0, buf, -1, nil, 0, nil, nil)
  ret = '\0' * len
  WideCharToMultiByte.call(0, 0, buf, -1, ret, ret.size, nil, nil)
  return ret
end

class File
  GetActiveWindow = Win32API.new('user32', 'GetActiveWindow', 'v', 'l')
  GetOpenFileName = Win32API.new('comdlg32', 'GetOpenFileName', 'p', 'l')
  SetCurrentDirectory = Win32API.new('kernel32', 'SetCurrentDirectory', 'p', 'l')
  GetCurrentDirectory = Win32API.new('kernel32', 'GetCurrentDirectory', 'lp', 'l')

  HWND                         = GetActiveWindow.call
  OFN_READONLY                 = 0x00000001
  OFN_OVERWRITEPROMPT          = 0x00000002
  OFN_HIDEREADONLY             = 0x00000004
  OFN_NOCHANGEDIR              = 0x00000008
  OFN_SHOWHELP                 = 0x00000010
  OFN_ENABLEHOOK               = 0x00000020
  OFN_ENABLETEMPLATE           = 0x00000040
  OFN_ENABLETEMPLATEHANDLE     = 0x00000080
  OFN_NOVALIDATE               = 0x00000100
  OFN_ALLOWMULTISELECT         = 0x00000200
  OFN_EXTENSIONDIFFERENT       = 0x00000400
  OFN_PATHMUSTEXIST            = 0x00000800
  OFN_FILEMUSTEXIST            = 0x00001000
  OFN_CREATEPROMPT             = 0x00002000
  OFN_SHAREAWARE               = 0x00004000
  OFN_NOREADONLYRETURN         = 0x00008000
  OFN_NOTESTFILECREATE         = 0x00010000
  OFN_NONETWORKBUTTON          = 0x00020000
  OFN_NOLONGNAMES              = 0x00040000
  OFN_EXPLORER                 = 0x00080000
  OFN_NODEREFERENCELINKS       = 0x00100000
  OFN_LONGNAMES                = 0x00200000
  OFN_ENABLEINCLUDENOTIFY      = 0x00400000
  OFN_ENABLESIZING             = 0x00800000
  OFN_DONTADDTORECENT          = 0x02000000
  OFN_FORCESHOWHIDDEN          = 0x10000000
  OFN_EX_NOPLACESBAR           = 0x00000001
  
  def File.OpenDialog(filter, title)
    buf = "\0" * 1024
    flag = OFN_PATHMUSTEXIST|OFN_FILEMUSTEXIST|OFN_HIDEREADONLY|OFN_NOCHANGEDIR
    for i in 0...filter.size
      filter[i][0] = case RUBY_VERSION
      when "1.8.1"
        u2s(filter[i][0]).delete("\0000\\\\0")
      when "1.9.2"
        u2s(filter[i][0]).force_encoding("ASCII-8BIT").delete("\0000\\\\0")
      else
        u2s(filter[i][0]).force_encoding("ASCII-8BIT").delete("\0000\\\\0")
      end
    end
    filter.flatten!
    filter = filter.join("\0") + "\0"
    # OPENFILENAME 구조체
    # 스타일 : 88 / 76
    arg = [76, HWND, 0, filter, 0,
            0, 1, buf, buf.size, 0,
            0, 0, u2s(title), flag, 0,
            0, '', 0, 0, 0].pack("L3pL3pL4pISSpL3")
    return if GetOpenFileName.call(arg) == 0
    path = s2u(buf)
    path.gsub!("\\0", "")
    path.gsub!("\0000", "")
    path.gsub!("\000", "")
    SetCurrentDirectory.call(File.expand_path(''))
    return path
  end
end

filter = [["PNG 파일 (*.png)", "*.png"],
          ["JPG 파일 (*.jpg;*.jpeg)", "*.jpg;*.jpeg"],
          ["GIF 파일 (*.gif)", "*.gif"],
          ["모든 파일", "*.*"]]
filename = File.OpenDialog(filter, "사진 선택")

$sprite = Sprite.new
$sprite.bitmap = Bitmap.new(filename) if filename != nil
$sprite.z = 999999
$sprite.opacity /= 2
#-------------------------------------------------------------------------------
end
#===============================================================================
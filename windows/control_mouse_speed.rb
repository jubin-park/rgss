=begin
  title  Contorl_MouseSpeed
   
  author jubin-park
  refer  http://www.devpia.com/Maeul/Contents/Detail.aspx?BoardID=17&MaeulNo=8&no=114812&ref=114787
  date   2016.01.31
  syntax Ruby
  pltfrm PC
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
SystemParametersInfoA = Win32API.new('user32', 'SystemParametersInfoA', 'llpl' ,'l')
SystemParametersInfoW = Win32API.new('user32', 'SystemParametersInfoW', 'llpl' ,'l')
SPI_GETMOUSESPEED = 112
SPI_SETMOUSESPEED = 113

def setMouseSpeed(speed)
  tolerance_value = [1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20] # 디폴트 : 10
  if !tolerance_value.include?(speed) || SystemParametersInfoA.call(SPI_SETMOUSESPEED, 0, speed, 0) == 0
    print "마우스 속도 조절 실패"
  end
end

def getMouseSpeed()
  case RUBY_VERSION
  when "1.8.1" # XP
    SystemParametersInfoA.call(SPI_GETMOUSESPEED, 0, buf=[0].pack('l'), 0)
    return buf.unpack('l')[0]
  when "1.9.2" # VXA
    SystemParametersInfoW.call(SPI_GETMOUSESPEED, 0, buf=[0].pack('w'), 0)
    return buf.unpack('w')[0]
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
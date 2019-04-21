=begin
  title  RGSS Blocking Game Multi-Execution
 
  author jubin-park
  refer  MSDN
  date   2015.10.10
  syntax Ruby (XP/VX/VXA)
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
# 뮤텍스 이름
MutexName = "이곳에 식별 문자를 넣으세요."
 
def mutex
  mutex = Win32API.new(*%w{kernel32 CreateMutex llp l}).call(0, 0, MutexName)
  if Win32API.new(*%w{kernel32 WaitForSingleObject ll l}).call(mutex, 0) != 0
    exit unless $DEBUG || $BTEST || $TEST
  end
end;mutex;undef mutex
#-------------------------------------------------------------------------------
end
#===============================================================================
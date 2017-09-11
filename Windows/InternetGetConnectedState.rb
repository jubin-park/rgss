=begin
  title  InternetGetConnectedState
 
  author jubin-park
  refer  MSDN
  date   2016.05.26
  syntax ruby
  pltfrm PC
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
def inet_connected?
  Win32API.new('wininet', 'InternetGetConnectedState', 'ii', 'i').call(0, 0) == 1
end
#-------------------------------------------------------------------------------
end
#===============================================================================
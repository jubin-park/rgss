=begin
  title  InternetGetConnectedState
 
  author jubin-park
  refer  ruby-doc.org
  date   2016.11.06
  syntax ruby
  pltfrm neko player
=end
#===============================================================================
if [187, 192].include?($NEKO_RUBY) && RGSS.is_mobile?
#-------------------------------------------------------------------------------
def inet_connected?
  begin
    sc = TCPSocket.open("www.google.com", 80)
    sc.peeraddr.is_a?(Array)
  rescue SocketError
    false
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
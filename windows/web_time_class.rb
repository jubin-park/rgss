=begin
  title  WebTime class
  
  author jubin-park
  refer  EFE's WinHttp Request
  date   2015.12.12
  syntax Ruby (XP/VX/VXA)
=end
#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
class WebTime < Time
  def self.new;  now() end
  def self.year; now.year() end
  def self.mon;  now.mon() end
  def self.mday; now.mday() end
  def self.hour; now.hour() end
  def self.min;  now.min() end
  def self.sec;  now.sec() end
  def self.now
    n = 0; data = String.new
    t_p = Time.now
    req = s2u(EFE.request('www.webtour.com', '/GInfo/time.asp?Code=A', 999999))
    # 실패 시 로컬 시간 반환
    return Time.now if req == "\000"
    t_l = Time.now
    req.scan(/<td width="134">(.*)<\/td>/) do |w|
      n += 1
      if n == 20
        data << $1
        break
      end
    end
    req = nil
    data = data.scan /(\d+)\/(\d+)\/(\d+) 오(전|후) (\d+):(\d+):(\d+)/
    # 실패 시 로컬 시간 반환
    return Time.now if data == []
    data.flatten!
    data[3] = 0  if data[3] == '전' # 오전 +0
    data[3] = 12 if data[3] == '후' # 오후 +12
    data[4] = 0  if data[3] == 0 && data[4] == '12' # 오전 12시 = 오전 0시
    data[4] = 0  if data[3] == 12 && data[4] == '12' # 오후 12시 = 오후 0시
    for i in 0...data.size
      data[i] = data[i].to_i
    end
    data[0] += 2000
    data[4] += data[3] # AM/PM 적용 뒤
    data.delete_at(3) # 삭제
    data[1] = case data[1] # 달
    when 1; 'jan'
    when 2; 'feb'
    when 3; 'mar'
    when 4; 'apr'
    when 5; 'may'
    when 6; 'jun'
    when 7; 'jul'
    when 8; 'aug'
    when 9; 'sep'
    when 10; 'oct'
    when 11; 'nov'
    when 12; 'dec'
    end
    return Time.local(*data) + (t_l - t_p) # 오차값 가산
  end
end

=begin
===============================================================================
 EFE's Request Script
 Version: RGSS & RGSS2 & RGSS3
 Special thanks : Ryex, Gustavo Bicalho, Kubiwa Taicho
===============================================================================
 This script will allow to request to some servers WITHOUT posting. (Only GET)
--------------------------------------------------------------------------------
Used WINAPI functions:

WinHTTPOpen
WinnHTTLConnect
WinHTTPOpenRequest
WinHTTPSendRequest
WinHTTPReceiveResponse
WinHttpQueryDataAvailable
WinHttpReadData

Call:

EFE.request(host, path, post, port)

host : "www.rpgmakervxace.net" (without http:// prefix)
path : "/forum/login.php" ( the directory path of your php file )
post : "username=kfdsfdsl&password=24324234"
port : 80 is default.

=end

module EFE
  WinHttpOpen = Win32API.new('winhttp','WinHttpOpen',"PIPPI",'I')
  WinHttpConnect = Win32API.new('winhttp','WinHttpConnect',"PPII",'I')
  WinHttpOpenRequest = Win32API.new('winhttp','WinHttpOpenRequest',"PPPPPII",'I')
  WinHttpSendRequest = Win32API.new('winhttp','WinHttpSendRequest',"PIIIIII",'I')
  WinHttpReceiveResponse = Win32API.new('winhttp','WinHttpReceiveResponse',"PP",'I')
  WinHttpQueryDataAvailable = Win32API.new('winhttp', 'WinHttpQueryDataAvailable', "PI", "I")
  WinHttpReadData = Win32API.new('winhttp','WinHttpReadData',"PPIP",'I')
  
  # I took this method from Gustavo Bicalho's WebKit script. Special thanks him.
  def self.to_ws(str)
    str = str.to_s();
    wstr = "";
    for i in 0..str.size
      wstr += str[i,1]+"\0";
    end
    wstr += "\0";
    return wstr;
  end
  
  def self.request(host, path, buf, post="",port=80)
    p = path
    if(post != "")
      p = p + "?" + post
    end
    p = p.to_s
    pwszUserAgent = ''
    pwszProxyName = ''
    pwszProxyBypass = ''
    httpOpen = WinHttpOpen.call(pwszUserAgent, 0, pwszProxyName, pwszProxyBypass, 0)
    if httpOpen
      httpConnect = WinHttpConnect.call(httpOpen, to_ws(host), port, 0)
      if httpConnect
        httpOpenR = WinHttpOpenRequest.call(httpConnect, nil, to_ws(p), "", '',0,0)
        if httpOpenR
          httpSendR = WinHttpSendRequest.call(httpOpenR, 0, 0 , 0, 0,0,0)
          if httpSendR
            httpReceiveR = WinHttpReceiveResponse.call(httpOpenR, nil)
            if httpReceiveR
              received = 0
              httpAvailable = WinHttpQueryDataAvailable.call(httpOpenR, received)
              if httpAvailable
                ali = ' ' * buf
                n = 0
                httpRead = WinHttpReadData.call(httpOpenR, ali, buf, o=[n].pack('i!'))
                n=o.unpack('i!')[0]
                return ali[0, n]
              else
                p("Error about query data available")
              end
            else
              p("Error when receiving response")
            end
          else
            p("Error when sending request")
          end
        else
          p("Error when opening request")
        end
      else
        p("Error when connecting to the host")
      end
    else
      p("Error when opening connection")
    end
  end
end

## Encoding

MultiByteToWideChar = Win32API.new('kernel32', 'MultiByteToWideChar', 'llplpl', 'l')
WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'llplplpp', 'l')

def s2u(text)
  len = MultiByteToWideChar.call(0, 0, text, -1, nil, 0)
  buf = '\0' * (len*2)
  MultiByteToWideChar.call(0, 0, text, -1, buf, buf.size/2)
  len = WideCharToMultiByte.call(65001, 0, buf, -1, nil, 0, nil, nil)
  ret = '\0' * len
  WideCharToMultiByte.call(65001, 0, buf, -1, ret, ret.size, nil, nil)
  return ret.delete("\0")
end
#-------------------------------------------------------------------------------
end
#===============================================================================
=begin
  title  WASD Input
  
  author jubin-park
  date   2020.05.27
=end

#===============================================================================
if $NEKO_RUBY.nil?
#-------------------------------------------------------------------------------
module Input
  
  TYPE = :WASD
  #TYPE = :ARROW
  #TYPE = :BOTH
  
  KEY_A = 0x41
  KEY_D = 0x44
  KEY_S = 0x53
  KEY_W = 0x57
  
  GetAsyncKeyState = Win32API.new('user32', 'GetAsyncKeyState', 'i', 'i')
  
  class << self
    alias_method(:arrow_dir4, :dir4)
    
    def dir4
      if TYPE == :WASD
        return wasd_dir4
      elsif TYPE == :ARROW
        return arrow_dir4
      elsif TYPE == :BOTH
        arrow = arrow_dir4
        wasd = wasd_dir4
        return arrow if arrow > 0
        return wasd if wasd > 0
      end 
      return 0
    end
    
    private
    
    def wasd_dir4
      return 2 if GetAsyncKeyState.call(KEY_S) != 0
      return 4 if GetAsyncKeyState.call(KEY_A) != 0
      return 6 if GetAsyncKeyState.call(KEY_D) != 0
      return 8 if GetAsyncKeyState.call(KEY_W) != 0
      return 0
    end
  end
end
#-------------------------------------------------------------------------------
end
#===============================================================================
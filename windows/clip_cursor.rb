=begin
  title  ClipCursor
 
  author jubin-park
  date   2020.12.30
  syntax ruby (XP/VX/VXA)
  pltfrm PC
=end

module Cursor
  GetActiveWindow = Win32API.new('user32', 'GetActiveWindow', 'v', 'l')
  ClipCursor = Win32API.new('user32', 'ClipCursor', 'p', 'l')
  GetClientRect = Win32API.new('user32', 'GetClientRect', 'lp', 'l')
  ClientToScreen = Win32API.new('user32', 'ClientToScreen', 'lp', 'l')
  
  module_function
  
  def clip(*args)
    if args.nil? || args.length.zero?
      hwnd = GetActiveWindow.call
      rect = [0, 0, 0, 0].pack('l4')
      GetClientRect.call(hwnd, rect)
      
      rect = rect.unpack('l4') # [left, top, right, bottom]
      p1 = rect[0, 2].pack('l2')
      p2 = rect[2, 2].pack('l2')
      
      ClientToScreen.call(hwnd, p1)
      ClientToScreen.call(hwnd, p2)
      
      new_rect = p1.unpack('l2') + p2.unpack('l2')
      ClipCursor.call(new_rect.pack('l4'))
    
    elsif args.length == 2 && args.all? {|i| i.is_a?(Integer) }
      width, height = *args
      
      hwnd = GetActiveWindow.call
      rect = [0, 0, 0, 0].pack('l4')
      GetClientRect.call(hwnd, rect)
      
      rect = rect.unpack('l4') # [left, top, right, bottom]
      p1 = rect[0, 2].pack('l2')
      p2 = rect[2, 2].pack('l2')
      
      ClientToScreen.call(hwnd, p1)
      ClientToScreen.call(hwnd, p2)
      p1 = p1.unpack('l2')
      p2 = p2.unpack('l2')
      
      mid = [(p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2] * 2
      mid[0] = [p1[0], mid[0] - width / 2].max
      mid[1] = [p1[1], mid[1] - height / 2].max
      mid[2] = [p2[0], mid[2] + (width - width / 2)].min
      mid[3] = [p2[1], mid[3] + (height - height / 2)].min
      ClipCursor.call(mid.pack('l4'))
      
    elsif args.length == 4 && args.all? {|i| i.is_a?(Integer) }
      x, y, width, height = *args
      rect = [x, y, x + width, y + height]
      ClipCursor.call(rect.pack('l4'))
    
    elsif args.length == 1 && args[0].is_a?(Rect)
      r = args[0]
      rect = [r.x, r.y, r.x + r.width, r.y + r.height]
      ClipCursor.call(rect.pack('l4'))
      
    else
      raise 'Invalid Arguments'
    end
  end
  
  def release
    ClipCursor.call(0)
  end
end

=begin
  title  NekoConsole (output only)
 
  author jubin-park
  date   2019.04.18
  syntax ruby
  pltfrm android (neko player)
=end
#===============================================================================
if $NEKO_RUBY.is_a?(Numeric)
#-------------------------------------------------------------------------------
module NekoConsole
  module Config
    # General
    TICK_DELAY        = 2500
    MAX_DRAWING_LINE  = 50
    MAX_LOGGING_LINE  = 300
    LOG_DIR_NAME      = "ConsoleLog"
    # Window UI
    PADDING           = 32
    RECT_CONSOLE      = [PADDING, PADDING * 2, Graphics.width - PADDING * 2, Graphics.height - PADDING * 3]
    CONTENT_TEXT_SIZE = 16
    COLOR_BACKGROUND  = Color.new 41, 128, 185, 224
    COLOR_TAB         = Color.new 0, 0, 0, 128
    COLOR_CONTENT     = Color.new 255, 255, 255
    MAX_ORDER_Z       = 999999999
    TAB_WIDTH         = 24
    # TapBox UI
    COLOR_TAPBOX_0    = Color.new 41, 128, 185
    COLOR_TAPBOX_1    = Color.new 255, 255, 255
    TAP_TEXT_SIZE     = 17
  end

  module Finger
    DOWN = 0
    UP   = 1
    DRAG = 2
  end

  module_function

  def init
    @q_content = Array.new
    @q_log = Array.new
    @phase = 0
    @init_x = nil
    @init_y = nil
    @tab_showing_tick = -1
    @switch_tab_showing = false
    @switch_tab_hiding  = false
    @switch_bg_showing = false
    @switch_bg_hiding = false
    @switch_content_showing = false
    @switch_content_hiding = false

    @vpt_console = Viewport.new -1, 0, 1, Graphics.height
    @vpt_console.z = Config::MAX_ORDER_Z
    @vpt_content = Viewport.new Config::RECT_CONSOLE[0], Config::RECT_CONSOLE[1], 1, Config::RECT_CONSOLE[3]
    @vpt_content.z = Config::MAX_ORDER_Z

    @spr_tab = Sprite.new
    @spr_tab.bitmap = generate_bmp_tab
    @spr_tab.z = Config::MAX_ORDER_Z
    @spr_tab.x = (-@spr_tab.bitmap.width)
    @spr_console_bg = Sprite.new @vpt_console
    @spr_console_bg.bitmap = generate_bmp_console_bg
    @spr_content = Sprite.new @vpt_content
    @spr_content.x = 1
    @spr_content.bitmap = generate_bmp_content
    
    x, y = 24, 16
    @tapbox_save     = TapBox.new x, y, "Save", @vpt_console; x += @tapbox_save.width + 6
    @tapbox_clear    = TapBox.new x, y, "Clear", @vpt_console; x += @tapbox_clear.width + 20
    @tapbox_p        = TapBox.new x, y, " p ", @vpt_console; x += @tapbox_p.width + 6
    @tapbox_print    = TapBox.new x, y, "print", @vpt_console; x += @tapbox_print.width + 6
    @tapbox_msgbox   = TapBox.new x, y, "msgbox", @vpt_console; x += @tapbox_msgbox.width + 6
    @tapbox_msgbox_p = TapBox.new x, y, "msgbox_p", @vpt_console; x += @tapbox_msgbox_p.width + 6
    @tapbox_puts     = TapBox.new x, y, "puts", @vpt_console; x += @tapbox_puts.width + 6
    @tapbox_popup    = TapBox.new x, y, "popup", @vpt_console
    @tapbox_p.state        = 1
    @tapbox_print.state    = 1
    @tapbox_msgbox.state   = 1
    @tapbox_msgbox_p.state = 1
    @tapbox_puts.state     = 0
    @tapbox_popup.state    = 1
  end

  def generate_bmp_tab
    b = Bitmap.new Config::TAB_WIDTH, Graphics.height
    b.fill_rect 0, 0, b.width, b.height, Config::COLOR_TAB
    b
  end

  def generate_bmp_console_bg
    b = Bitmap.new Graphics.width + 1, Graphics.height
    b.fill_rect 0, 0, b.width, b.height, Config::COLOR_BACKGROUND
    b
  end

  def generate_bmp_content
    tmp = Bitmap.new 1, 1
    tmp.font.size = Config::CONTENT_TEXT_SIZE
    @real_size = tmp.text_size("").height
    b = Bitmap.new Graphics.width - Config::PADDING * 2, @real_size * Config::MAX_DRAWING_LINE
    b.font.color = Config::COLOR_CONTENT
    b.font.size = Config::CONTENT_TEXT_SIZE
    b
  end

  def get_bmp_content
    @spr_content.bitmap
  end

  def draw_console_content
    font_size = @real_size
    # 리스트가 꽉 찼을 때
    if @q_content.size >= Config::MAX_DRAWING_LINE
      get_bmp_content.clear
      for i in 0...@q_content.size
        get_bmp_content.draw_text 0, i * font_size, get_bmp_content.width, font_size, @q_content[i]
      end
    else
      i = @q_content.size - 1
      get_bmp_content.draw_text 0, i * font_size, get_bmp_content.width, font_size, @q_content[i]
    end
  end

  def update
    case @phase
    when 0
      update_tab_showing if @switch_tab_showing
    when 1
      if @tab_showing_tick > 0
        if SDL.getTicks - @tab_showing_tick >= Config::TICK_DELAY
          @spr_tab.x = 0
          @switch_tab_hiding = true
          @tab_showing_tick = -1
        end
      end
      update_tab_hiding if @switch_tab_hiding
    when 2
      update_bg_showing if @switch_bg_showing
      update_content_showing if @switch_content_showing
      if @switch_bg_showing == false && @switch_content_showing == false
        @phase = 3
      end
    when 5
      update_bg_hiding if @switch_bg_hiding
      update_content_hiding if @switch_content_hiding
      if @switch_bg_hiding == false && @switch_content_hiding == false
        @phase = 0
        @tab_showing_tick = -1
      end
    end
  end

  def update_tab_showing
    x = @spr_tab.x
    x *= 0.8
    @spr_tab.x = x
    if @spr_tab.x >= 0
      @switch_tab_showing = false
      @phase = 1
    end
  end

  def update_tab_hiding
    dst = @spr_tab.bitmap.width
    x = @spr_tab.x.abs + 1
    x *= 1.1
    @spr_tab.x = -(x.abs)
    if @spr_tab.x <= -dst
      @switch_tab_hiding = false
      @phase = 0
    end
  end

  def update_bg_showing
    dst = Graphics.width + 1
    w = @vpt_console.width + 1
    w *= 1.2
    @vpt_console.width = w
    if @vpt_console.width >= dst
      @vpt_console.width = dst
      @switch_bg_showing = false
    end
  end

  def update_bg_hiding
    dst = 1
    w = @vpt_console.width
    w *= 0.8
    @vpt_console.width = w
    if @vpt_console.width <= dst
      @vpt_console.width = dst
      @switch_bg_hiding = false
    end
  end

  def update_content_showing
    dst = Config::RECT_CONSOLE[2] + 1
    w = @vpt_content.width + 1
    w *= 1.2
    @vpt_content.width = w
    if @vpt_content.width >= dst
      @vpt_content.width = dst
      @switch_content_showing = false
    end
  end

  def update_content_hiding
    dst = 1
    w = @vpt_content.width
    w *= 0.8
    @vpt_content.width = w
    if @vpt_content.width <= dst
      @vpt_content.width = dst
      @switch_content_hiding = false
    end
  end

  def callback_touch(finger_id, touch_x, touch_y, action)
    # 단계별 처리
    case @phase
    # 탭이 안나온 상태
    when 0
      if @tab_showing_tick == -1
        # 영역 안에서
        if touch_x >= 0 && touch_x < 24
          # 최초 터치
          if action == Finger::DOWN || action == Finger::DRAG
            @init_x ||= touch_x
            @init_y ||= touch_y
          end
        end
        # 모든 영역에서 드래그
        if action == Finger::DRAG
          if not @init_x.nil?
            # 일정거리가 생기면
            if touch_x - @init_x >= 24
              @tab_showing_tick = SDL.getTicks
              @spr_tab.x = (-@spr_tab.bitmap.width)
              @switch_tab_showing = true
              @init_x = nil
              @init_y = nil
            end
          end
        # 최초 터치좌표값 초기화
        elsif action == Finger::UP
          @init_x = nil
          @init_y = nil
        end
      end
    # 탭 1차 표시
    when 1
      if touch_x >= 0 && touch_x < 24
        if action == Finger::DOWN || action == Finger::DRAG
          @init_x ||= touch_x
          @init_y ||= touch_y
        end
      end
      if action == Finger::DRAG
        if not @init_x.nil?
          # 일정거리가 생기면
          if touch_x - @init_x >= Graphics.width / 10
            @spr_tab.x = (-@spr_tab.bitmap.width)
            @switch_bg_showing = true
            @switch_content_showing = true
            @phase = 2
            @init_x = nil
            @init_y = nil
          end
        end
      elsif action == Finger::UP
        @init_x = nil
        @init_y = nil
      end
    # 콘솔 업데이트
    when 3
      if touch_x >= Config::RECT_CONSOLE[0] && touch_x < Config::RECT_CONSOLE[0] + Config::RECT_CONSOLE[2] &&
          touch_y >= Config::RECT_CONSOLE[1] && touch_y < Config::RECT_CONSOLE[1] + Config::RECT_CONSOLE[3]
        if action == Finger::DOWN || action == Finger::DRAG
          @init_x ||= touch_x
          @init_y ||= touch_y
          @scroll_y ||= @spr_content.y
        end
      end
      if touch_x >= @vpt_console.width - 24 && touch_x < @vpt_console.width
        if action == Finger::DOWN || action == Finger::DRAG
          @phase = 4
          return
        end
      end
      if action == Finger::DRAG
        if not @init_x.nil?
          dy = touch_y - @init_y
          @spr_content.y = @scroll_y + dy
          if @spr_content.y > get_bmp_content.height - @spr_content.src_rect.height
            @spr_content.y = get_bmp_content.height - @spr_content.src_rect.height
          end
        end
        @tapbox_save.state = 0 if @tapbox_save.has_pos(touch_x, touch_y) == false
        @tapbox_clear.state = 0 if @tapbox_clear.has_pos(touch_x, touch_y) == false
      elsif action == Finger::DOWN
        if @tapbox_save.has_pos touch_x, touch_y
          @tapbox_save.state = 1
        elsif @tapbox_clear.has_pos touch_x, touch_y
          @tapbox_clear.state = 1
        elsif @tapbox_p.has_pos touch_x, touch_y
          @tapbox_p.state = 1 - @tapbox_p.state
        elsif @tapbox_print.has_pos touch_x, touch_y
          @tapbox_print.state = 1 - @tapbox_print.state
        elsif @tapbox_msgbox.has_pos touch_x, touch_y
          @tapbox_msgbox.state = 1 - @tapbox_msgbox.state
        elsif @tapbox_msgbox_p.has_pos touch_x, touch_y
          @tapbox_msgbox_p.state = 1 - @tapbox_msgbox_p.state
        elsif @tapbox_puts.has_pos touch_x, touch_y
          @tapbox_puts.state = 1 - @tapbox_puts.state
        elsif @tapbox_popup.has_pos touch_x, touch_y
          @tapbox_popup.state = 1 - @tapbox_popup.state
        end
      elsif action == Finger::UP
        if @tapbox_save.has_pos touch_x, touch_y
          if @tapbox_save.state == 1
            @tapbox_save.state = 0
            NekoConsole.save
          end
        elsif @tapbox_clear.has_pos touch_x, touch_y
          if @tapbox_clear.state == 1
            @tapbox_clear.state = 0
            NekoConsole.clear
          end
        end
        @init_x = nil
        @init_y = nil
        @scroll_y = nil
      end
    # 콘솔 닫기
    when 4
      if action == Finger::DOWN || action == Finger::DRAG
        @init_x ||= touch_x
        @init_y ||= touch_y
      end
      if action == Finger::DRAG
        if not @init_x.nil?
          if @init_x - touch_x >= Graphics.width / 10
            @switch_bg_hiding = true
            @switch_content_hiding = true
            @phase = 5
          end
        end
      end
    end
  end

  def switch_on?(key)
    return @tapbox_p.state == 1         if key == :p
    return @tapbox_print.state == 1     if key == :print
    return @tapbox_msgbox.state == 1    if key == :msgbox
    return @tapbox_msgbox_p.state == 1  if key == :msgbox_p
    return @tapbox_puts.state == 1      if key == :puts
    return @tapbox_popup.state == 1     if key == :popup
    false
  end

  def get_divided_text(bitmap, max_width, str, esn=false)
    x = 0
    buf = ""
    arr_chunk = []
    for char in str.split(//)
      if esn == true
        if char == "\n"
          arr_chunk.push(buf)
          buf = ""
          x = 0
          next
        else
          buf += char
          w = bitmap.text_size(char).width
          x += w
        end
      else
        buf += char
        w = bitmap.text_size(char).width
        x += w
      end
      if x + w > max_width
        arr_chunk.push(buf)
        buf = ""
        x = 0
      end
    end
    arr_chunk.push(buf)
    return arr_chunk
  end

  def clear
    get_bmp_content.clear
    @q_content.clear
    @q_log.clear
  end

  def write(str, esn=false)
    for s in get_divided_text(get_bmp_content, Config::RECT_CONSOLE[2] - 2, str, esn)
      @q_content.push(s)
      if @q_content.size > Config::MAX_DRAWING_LINE
        @q_content.shift
      end
      draw_console_content
    end
    @q_log.push(str)
    if @q_log.size > Config::MAX_LOGGING_LINE
      @q_log.shift
    end
  end

  def save
    Dir.mkdir Config::LOG_DIR_NAME if !(FileTest.exist? Config::LOG_DIR_NAME and FileTest.directory? Config::LOG_DIR_NAME)
    t = Time.now
    filename = sprintf "#{Config::LOG_DIR_NAME}/%d-%02d-%02d-%02d-%02d-%05f.txt", t.year, t.month, t.day, t.hour, t.min, t.sec + t.to_f - t.to_i
    f = File.open filename, "w"
    @q_log.each do |log|
      f.write log
      f.write "\r\n"
    end
    f.close
    SDL.showAlert "Saved as \"#{filename}\""
  end
end

module NekoConsole
  class TapBox
    attr_reader :state

    def initialize(x, y, text, viewport)
      width, height = compute_rect text
      @state = 0
      @bmp_bg = [Bitmap.new(width + 4, height + 4), Bitmap.new(width + 4, height + 4)]
      draw_bitmap_background @bmp_bg[0], Color.new(0, 0, 0, 0), Config::COLOR_TAPBOX_1
      draw_bitmap_background @bmp_bg[1], Config::COLOR_TAPBOX_1, Config::COLOR_TAPBOX_0
      @bmp_text = [Bitmap.new(width, height), Bitmap.new(width, height)]
      @bmp_text[0].font.size = Config::TAP_TEXT_SIZE
      @bmp_text[0].font.color = Config::COLOR_TAPBOX_1
      @bmp_text[0].draw_text(0, 0, width, height, text)
      @bmp_text[1].font.size = Config::TAP_TEXT_SIZE
      @bmp_text[1].font.color = Config::COLOR_TAPBOX_0
      @bmp_text[1].draw_text(0, 0, width, height, text)
      @spr_background = Sprite.new viewport
      @spr_background.x = x
      @spr_background.y = y
      @spr_background.bitmap = @bmp_bg[0]
      @spr_text = Sprite.new viewport
      @spr_text.x = x + 2
      @spr_text.y = y + 2
      @spr_text.bitmap = @bmp_text[0]   
    end

    def draw_bitmap_background(bitmap, i_color, o_color, thick=1)
      bitmap.fill_rect thick, thick, bitmap.width - thick * 2, bitmap.height - thick * 2, i_color
      bitmap.fill_rect 0, 0, bitmap.width, thick, o_color
      bitmap.fill_rect 0, bitmap.height - thick, bitmap.width, thick, o_color
      bitmap.fill_rect 0, 0, thick, bitmap.height, o_color
      bitmap.fill_rect bitmap.width - thick, 0, thick, bitmap.height, o_color
    end

    def compute_rect(str)
      b = Bitmap.new 1, 1
      b.font.size = Config::TAP_TEXT_SIZE
      r = b.text_size(str)
      return r.width, r.height
    end

    def has_pos(x, y)
      return x >= @spr_background.x && x < @spr_background.x + @spr_background.bitmap.width &&
        y >= @spr_background.y && y < @spr_background.y + @spr_background.bitmap.height
    end

    def width
      @spr_background.bitmap.width
    end

    def state=(val)
      @state = val
      @spr_background.bitmap = @bmp_bg[@state]
      @spr_text.bitmap = @bmp_text[@state]
    end
  end
end

module Graphics
  class << self
    alias_method :neko_console_update, :update
    def update
      NekoConsole.update
      neko_console_update
    end
  end
end

module SDL
  class << self
    alias_method :neko_console_handle_pad_touch, :handlePadTouch
    def handlePadTouch(*args)
      dw, dh = Graphics.entity.w.to_f, Graphics.entity.h.to_f
      gw, gh = Graphics.width.to_f, Graphics.height.to_f
      r = dh / gh
      gw2 = gw * r
      ew2 = (dw - gw2) / 2
      r2 = dw / gw2
      NekoConsole.callback_touch args[0], (args[1] - ew2 / dw) * gw * r2, args[2] * gh, args[3]
      neko_console_handle_pad_touch *args
    end

    alias_method :neko_console_show_alert, :showAlert
    def showAlert(str)
      neko_console_show_alert str
    end
  end
end

module Kernel
  def print(*args)
    return if args.inspect.to_s =~ /(bgm_play|bgs_play|se_play|me_play) (.*)\\n/
    str = String.new
    args.each do |obj|
      str << (obj.nil? ? "nil" : obj.to_s) + '\n'
      if NekoConsole.switch_on? :print
        if obj.is_a? String
          # ident character
          obj.gsub! "\t", "  "
          # newline character
          obj.split("\n").each { |s| NekoConsole.write s, true }
        else
          NekoConsole.write obj, true
        end
      end
    end
    SDL.showAlert str if NekoConsole.switch_on? :popup
  end

  def p(*args)
    str = String.new
    args.each do |obj|
      str << obj.inspect + '\n'
      if NekoConsole.switch_on? :p
        NekoConsole.write obj.inspect
      end
    end
    SDL.showAlert str if NekoConsole.switch_on? :popup
  end

  def puts(*args)
    str = String.new
    args.each do |obj|
      str << (obj.nil? ? "" : obj.to_s) + '\n'
      if NekoConsole.switch_on? :puts
        if obj.is_a? String
          # ident character
          obj.gsub! "\t", "  "
          # newline character
          obj.split("\n").each { |s| NekoConsole.write s, true }
        else
          NekoConsole.write obj, true
        end
      end
    end
  end
end

undef msgbox
def msgbox(*args)
  str = String.new
  args.each do |obj|
    str << (obj.nil? ? "nil" : obj.to_s) + '\n'
    if NekoConsole.switch_on? :msgbox
      if obj.is_a? String
        # ident character
        obj.gsub! "\t", "  "
        # newline character
        obj.split("\n").each { |s| NekoConsole.write s, true }
      else
        NekoConsole.write obj, true
      end
    end
  end
  SDL.showAlert str if NekoConsole.switch_on? :popup
end

undef msgbox_p
def msgbox_p(*args)
  str = String.new
  args.each do |obj|
    str << obj.inspect + '\n'
    if NekoConsole.switch_on? :msgbox_p
      NekoConsole.write obj.inspect
    end
  end
  SDL.showAlert str if NekoConsole.switch_on? :popup
end

NekoConsole.init
#-------------------------------------------------------------------------------
end
#===============================================================================
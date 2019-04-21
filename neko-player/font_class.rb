=begin
  title  Font class (redefined-3)
  
  author jubin-park
  date   2018.07.14
  syntax ruby
  pltfrm Neko Player
  
  refer  https://raw.githubusercontent.com/Yangff/OpenRGSS-1/master/lib/openrgss/font.rb
=end
#===============================================================================
if [187, 192].include?($NEKO_RUBY) && RGSS.is_mobile?
#-------------------------------------------------------------------------------
class Font
  
  # Fonts 폴더 생성
  FONT_DIR = "./Fonts/"
  Dir.mkdir(FONT_DIR) if !(FileTest.exist?(FONT_DIR) and FileTest.directory?(FONT_DIR))
  
  # key   : 폰트명
  # value : 폰트 파일경로
  @@fonts_list = {}
  
  # key   : name, size
  # value : SDL::TTF
  @@cache = {}

  def self.init
    # `Couldn't open font .. Library not initialized' Error Patch
    SDL::TTF.init()
    # 1. 기본 폰트
    # 커스텀 폰트부터 우선검색, 먀지막 인덱스는 숨겨진 기본 폰트
    default_font_file = ["font.ttf", "/sdcard/KernysRGSS/font.ttf", "NanumGothic.mp3"]
    for i in 0..2
      if FileTest.exist?(default_font_file[i])
        pass = i
        break
      end
      pass = -1 if i == 2
    end
    # pass 가 -1인 경우 NanumGothic.mp3가 숨겨진 파일이라 검색이 안되지만,
    # open 함수로 발견이 될 수도 있으니 검색 시도한다.
    if pass == 0
      ttf = SDL::TTF.open(File.expand_path("") + "/" + default_font_file[pass], 1) rescue nil
    else
      ttf = SDL::TTF.open(default_font_file[pass], 1) rescue nil
    end
    # 숨겨진 기본 폰트(NanumGothic.mp3)도 없는 최악의 경우
    if ttf.nil?
      SDL.showAlert("There is no \"#{default_font_file[pass]}\" file.")
    else
      # 이름 + 스타일 취득 및 가공
      name = ttf.familyName + (ttf.styleName.capitalize == "Regular" ? "" : " " + ttf.styleName.capitalize)
      # 기본 폰트로 등록
      @name = name
      # 리스트에 추가
      @@fonts_list[name] = default_font_file[pass]
      # 따로 저장
      @@sdcard_font = [name, default_font_file[pass]]
      # 닫음
      ttf.close if !ttf.closed?
    end
    # 2. Fonts 폴더 폰트
    for font in Dir.entries(FONT_DIR)
      if File.extname(font) == ".ttf"
        # 경로 생성
        custom_font_file = File.expand_path("") + FONT_DIR[1..-1] + font
        # 폰트 로드
        ttf = SDL::TTF.open(custom_font_file, 1)
        # 이름 + 스타일 취득 및 가공
        name = ttf.familyName + (ttf.styleName.capitalize == "Regular" ? "" : " " + ttf.styleName.capitalize)
        # 리스트에 추가
        @@fonts_list[name] = custom_font_file
        # 닫음
        ttf.close if !ttf.closed?
      end
    end
  end
  init()
  
  # 폰트명 txt 파일로 추출
  def self.extract_font_name
    begin
      input = open(FONT_DIR + "Extracted_Font_Name.txt", "wb")
      input.write("#{@@sdcard_font[1]} => \"#{@@sdcard_font[0]}\"\n")
      for font in @@fonts_list.keys
        next if @@sdcard_font[1] == @@fonts_list[font]
        input.write("#{@@fonts_list[font]} => \"#{font}\"\n")
      end
    end
  end
  extract_font_name()
  
  # 폰트 존재 여부
  def self.exist?(fontname)
    @@fonts_list.has_key?(fontname)
  end
  
  def initialize(name = @@default_name, size = @@default_size)
    @name   = name
    @size   = size
    @bold   = @@default_bold
    @italic = @@default_italic
    @color  = @@default_color
  end
  
  def entity
    begin
      result = ( @@cache[[@name, @size]] ||= SDL::TTF.open(@@fonts_list[@name], @size) )
    rescue
      result = ( @@cache[[@name, @size]] ||= SDL::TTF.open("NanumGothic.mp3", @size) )
    end
    result.style = (@bold ? SDL::TTF::STYLE_BOLD : 0) | (@italic ? SDL::TTF::STYLE_ITALIC : 0)
    return result
  end

  # 클래스 변수 메소드화
  attr_accessor :name, :size, :bold, :italic, :color, :outline, :shadow, :out_color
  class << self
    [:name, :size, :bold, :italic, :color, :outline, :shadow, :out_color].each { |attribute|
      name = 'default_' + attribute.to_s
      define_method(name) { class_variable_get('@@'+name) }
      define_method(name+'=') { |value| class_variable_set('@@'+name, value) }
    }
  end
  
  def self.default_name=(value)
    if value.is_a?(String)
      if Font.exist?(value)
        @@default_name = value
        return
      end
    elsif value.is_a?(Array)
      for i in 0...value.size
        if Font.exist?(value[i])
          @@default_name = value[i]
          return
        end
      end
      return
    else
      return
    end
  end
  
  @@default_bold   = false
  @@default_italic = false
  @@default_color  = Color.new(255, 255, 255, 255)
end
#-------------------------------------------------------------------------------
end
#===============================================================================
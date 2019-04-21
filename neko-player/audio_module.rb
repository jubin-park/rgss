# encoding: utf-8

=begin
  title  audio.rb
 
  author zh99998
  modify jubin-park
  date   2017.02.05
  syntax ruby
  pltfrm android (neko player)
=end

# The module that carries out music and sound processing.

module Audio

  CHANNEL = {:BGS => 0, :ME => 1, :SE => (2...SDL::Mixer::CHANNELS)}

  @@se_channel = {}
  @@cache = {}
  @volume = {}

  class << self

    # Prepares MIDI playback by DirectMusic.
    #
    # A method of the processing at startup in RGSS2 for enabling execution at any time.
    #
    # MIDI playback is possible without calling this method, but in Windows Vista or later, a delay of 1 to 2 seconds will result at playback.

    def setup_mdi

    end

    # Starts BGM playback. Specifies the file name, volume, pitch, and playback starting position in that order.
    #
    # The playback starting position (RGSS3) is only valid for ogg or wav files.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.

    def bgm_play(filename, volume=100, pitch=100, pos=0)
      filename = RGSS.get_file(filename)
      @volume[:BGM] = volume = convert_volume(volume)
      if @bgm_name == filename
        SDL::Mixer.setVolumeMusic(volume)
        return
      end
      bgm_stop
      if cache_exist?(filename)
        #p "bgm cache is existed."
        music = @@cache[filename]
      else
        #p "no bgm cache is existed."
        music = SDL::Mixer::Music.load(filename)
        @@cache[filename] = music
      end
      SDL::Mixer.playMusic(music, -1) rescue puts($!)
      SDL::Mixer.setVolumeMusic(volume)
      @bgm_name = filename
    end

    # Stops BGM playback.

    def bgm_stop
      SDL::Mixer.haltMusic
      @bgm_name = nil
    end

    # Starts BGM fadeout. time is the length of the fadeout in milliseconds.

    def bgm_fade(ms)
      SDL::Mixer.fadeOutMusic(ms)
      @bgm_name = nil
    end

    # Gets the playback position of the BGM. Only valid for ogg or wav files. Returns 0 when not valid.

    def bgm_pos
      0
    end

    def bgm_playing?
      SDL::Mixer.playMusic?
    end

    def bgm_paused?
      SDL::Mixer.pauseMusic?
    end

    def bgm_pause
      SDL::Mixer.pauseMusic
    end

    def bgm_resume
      SDL::Mixer.resumeMusic
    end

    # Starts BGS playback. Specifies the file name, volume, pitch, and playback starting position in that order.
    #
    # The playback starting position (RGSS3) is only valid for ogg or wav files.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.

    def bgs_play(filename, volume=100, pitch=100, pos=0)
      filename = RGSS.get_file(filename)
      @volume[:BGS] = volume = convert_volume(volume)
      if @bgs_name == filename
        SDL::Mixer.setVolume(CHANNEL[:BGS], volume)
        return
      end
      bgs_stop
      if cache_exist?(filename)
        #p "bgs cache is existed."
        wave = @@cache[filename]
      else
        #p "no bgs cache is existed."
        wave = SDL::Mixer::Wave.load(filename)
        @@cache[filename] = wave
      end
      SDL::Mixer.playChannel(CHANNEL[:BGS], wave, -1)
      SDL::Mixer.setVolume(CHANNEL[:BGS], volume)
      @bgs_name = filename
    end

    # Stops BGS playback.

    def bgs_stop
      SDL::Mixer.halt(CHANNEL[:BGS])
      @bgs_name = nil
    end

    # Starts BGS fadeout. time is the length of the fadeout in milliseconds.

    def bgs_fade(ms)
      SDL::Mixer.fadeOut(CHANNEL[:BGS], ms)
      @bgs_name = nil
    end
    
    # Gets the playback position of the BGS. Only valid for ogg or wav files. Returns 0 when not valid.

    def bgs_pos
      0
    end

    def bgs_playing?
      SDL::Mixer.play?(CHANNEL[:BGS])
    end

    def bgs_paused?
      b = SDL::Mixer.pause?(CHANNEL[:BGS])
      return true if b == 1
      return false if b == 0
    end

    def bgs_pause
      SDL::Mixer.pause(CHANNEL[:BGS])
    end

    def bgs_resume
      SDL::Mixer.resume(CHANNEL[:BGS])
    end

    # Starts ME playback. Sets the file name, volume, and pitch in turn.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.
    #
    # When ME is playing, the BGM will temporarily stop. The timing of when the BGM restarts is slightly different from RGSS1.

    def update
      if @phase == 0
        if bgm_playing?
          SDL::Mixer.pauseMusic
          if bgm_paused?
            @phase = 1
          end
        end
      elsif @phase == 1
        if !me_playing?
          SDL::Mixer.resumeMusic
          @phase = nil
        end
      end
    end

    def me_play(filename, volume=100, pitch=100)
      filename = RGSS.get_file(filename)
      SDL.showAlert filename
      @volume[:ME] = volume = convert_volume(volume)
      if cache_exist?(filename)
        #p "me cache is existed."
        wave = @@cache[filename]
      else
        #p "no me cache is existed."
        wave = SDL::Mixer::Wave.load(filename) # rescue puts($!)
        @@cache[filename] = wave
      end
      # 배경음 페이드아웃
      @phase = 0
      SDL::Mixer.playChannel(CHANNEL[:ME], wave, 0)
      SDL::Mixer.setVolume(CHANNEL[:ME], volume)
    end

    # Stops ME playback.

    def me_stop
      SDL::Mixer.halt(CHANNEL[:ME])
    end

    # Starts ME fadeout. time is the length of the fadeout in milliseconds.

    def me_fade(ms)
      SDL::Mixer.fadeOut(CHANNEL[:ME], ms)
    end

    def me_playing?
      SDL::Mixer.play?(CHANNEL[:ME])
    end

    # Starts SE playback. Sets the file name, volume, and pitch in turn.
    #
    # Also automatically searches files included in RGSS-RTP. File extensions may be omitted.
    #
    # When attempting to play the same SE more than once in a very short period, they will automatically be filtered to prevent choppy playback

    def se_play(filename, volume=100, pitch=100)
      filename = RGSS.get_file(filename)
      @volume[:SE] = volume = convert_volume(volume)
      if cache_exist?(filename)
        #p "se cache is existed."
        wave = @@cache[filename]
      else
        #p "no se cache is existed."
        wave = SDL::Mixer::Wave.load(filename) # rescue puts($!)
        @@cache[filename] = wave
      end
      for i in CHANNEL[:SE]
        next if SDL::Mixer.play?(i)
        channel = i
        break
      end
      if channel
        wave = SDL::Mixer::Wave.load(filename)
        SDL::Mixer.playChannel(channel, wave, 0)
        SDL::Mixer.setVolume(channel, volume)
      end
    end

    # Stops all SE playback.

    def se_stop
      for i in CHANNEL[:SE]
        next unless SDL::Mixer.play?(i)
        SDL::Mixer.halt(i)
      end
    end

    protected

    def cache_exist?(filename)
      @@cache.has_key?(filename) &&
      (@@cache[filename].is_a?(SDL::Mixer::Music) && !@@cache[filename].destroyed?) ||
      (@@cache[filename].is_a?(SDL::Mixer::Wave) && !@@cache[filename].destroyed_)
    end

    def convert_volume(volume)
      volume = [[0, volume].max, 100].min # % percent
      volume = (1.28 * volume).round # real volume
      return volume
    end

  end
end
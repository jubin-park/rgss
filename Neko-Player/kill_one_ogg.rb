=begin
  title  kill_one_ogg
 
  author jubin-park
  date   2016.12.14
         2018.07.13
  syntax ruby
  pltfrm android (neko player)
=end
#===============================================================================
if $NEKO_RUBY.is_a?(Numeric)
#-------------------------------------------------------------------------------
class TocBootstrap
  attr_reader :data, :files
end

def kill_one_ogg(o_dirname, ext)
  dead = Hash.new
  keys = $toc_bootstrap.files.keys
  for k in keys
    index = $toc_bootstrap.files[k][0]
    num   = $toc_bootstrap.files[k][1]
    range = (index)...(index + num)
    chunk = $toc_bootstrap.data[range]
    dead[k] = $toc_bootstrap.decodeCode(chunk)
    
    orig_path = k
    split_dir = orig_path.split(/[\/\\]/)
    dirname = o_dirname.dup
    Dir.mkdir(dirname) if !FileTest.exist?(dirname)
    dirname << "/"
    for i in 0...split_dir.size-1
      dirname << split_dir[i] << "/"
      Dir.mkdir(dirname) if !FileTest.exist?(dirname)
    end
    
    f = open("./#{o_dirname}/#{orig_path}#{ext}", "wb")
    f.write(dead[k])
    f.close
  end
end

kill_one_ogg("Dead_rb", ".rb")
kill_one_ogg("Dead_txt", ".txt")

SDL.putenv"DPAD_SCALE=0.0"
$spr = Sprite.new
$spr.z = 9999999
$spr.opacity = 0
w, h = Graphics.width, Graphics.height
$spr.bitmap = Bitmap.new(w, h)
$spr.bitmap.font.color = Color.new(0, 168, 255)
$spr.bitmap.draw_text(0, 0, w, h, "Neko died. This page will close in 5 seconds.", 1)
loop {
  Graphics.update
  if SDL.getTicks < 4500
    $spr.opacity += 5
  else
    $spr.opacity -= 10
  end
  exit if SDL.getTicks > 5000
}
#-------------------------------------------------------------------------------
end
#===============================================================================

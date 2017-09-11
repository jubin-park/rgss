=begin
  title  kill_one_ogg
 
  author jubin-park
  date   2016.12.14
  syntax ruby
  pltfrm android (neko player)
=end
#===============================================================================
if $NEKO_RUBY.is_a?(Numeric)
#-------------------------------------------------------------------------------
class TocBootstrap
  attr_reader :data, :files
end
 
def kill_one_ogg
  dead = Hash.new
  keys = $toc_bootstrap.files.keys
  for k in keys
    index = $toc_bootstrap.files[k][0]
    num   = $toc_bootstrap.files[k][1]
    range = (index)...(index + num)
    chunk = $toc_bootstrap.data[range]
    dead[k] = $toc_bootstrap.decodeCode(chunk)
    name = k.gsub("/", "／")
    Dir.mkdir("Dead") rescue Errno::EEXIST
    f = open("./Dead/#{name}.txt", "wb")
    f.write(dead[k])
    f.close
  end
end

kill_one_ogg
#-------------------------------------------------------------------------------
end
#===============================================================================
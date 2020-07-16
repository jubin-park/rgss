=begin
  title  steam_command355_fix
 
  author jubin-park
  date   2020.07.16
  syntax ruby
=end

class Interpreter
  #--------------------------------------------------------------------------
  # * Script
  #--------------------------------------------------------------------------
  def command_355
    # Set first line to script
    script = @list[@index].parameters[0]
    script << "\n" if !is_script_concatenated?(script)
    # Loop
    loop do
      # If next event command is second line of script or after
      if @list[@index+1].code == 655
        # Add second line or after to script
        script += @list[@index + 1].parameters[0]
        script << "\n" if !is_script_concatenated?(@list[@index + 1].parameters[0])
      # If event command is not second line or after
      else
        # Abort loop
        break
      end
      # Advance index
      @index += 1
    end
    # Evaluation
    result = eval(script)
    # If return value is false
    if result == false
      # End
      return false
    end
    # Continue
    return true
  end
  
private

  MAX_LENGTH_PAIRS = [38, 37, 136, 234, 333, 431, 529, 726, 825, 923, 1022, 1120, 1218, 1317, 1415, 1514, 1612, 1711, 1809, 1907, 2006, 2104, 2203, 2301, 2400]

  def is_script_concatenated?(line)
    ascii_count = 0
    multibyte_count = 0
    
    for char in line.scan(/./)
      if char.size > 1
        multibyte_count += 1
      else
        ascii_count += 1
      end
    end

    return MAX_LENGTH_PAIRS.include?(multibyte_count * 100 + ascii_count)
  end
end
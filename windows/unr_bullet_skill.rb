alias custom_packet_recv2 custom_packet_recv
def custom_packet_recv(line)
  custom_packet_recv2(line)
  case line
  when /<packet> (.*) (.*) (.*) (.*) (.*) (.*) (.*) <\/packet>/
    if $6 == "bullet"
      return if $userdata.user_id == $7
      a = 보관이벤트($1.to_i)
      a.net_range_set($2.to_i)
      a.moveto($3.to_i, $4.to_i)
      a.direction = $5.to_i
    end
  end
end

def event_remove(event)
  remove_sprite event
  $game_map.events.delete event.id
end

class MUI_HUD < Window_Base
  def use_skill(skill)
    return if not $game_party.actors[0].skills.include?(skill.id)
    for i in skill.element_set
      case $data_system.elements[i]
      when "근거리"
        $game_player.player_melee(skill)
      when "원거리"
        $game_player.player_distance(skill)
      when "범위"
        $game_player.player_range(skill)
      when "총알"
        $game_player.player_bullet(skill)        
      when "버프"
        $game_player.player_buff(skill)
      end
    end
  end
end

class Game_Character  
  alias uas_initailize2 initialize
  alias event_process2 event_process
  
  def initialize
    uas_initailize2
    @bullet = false
    @net_bullet = false
  end
  
  def event_process
    bullet_process if @bullet
    net_bullet_process if @net_bullet
    event_process2
  end
end

class Game_Character
  def bullet_skill(skill, enemy)
    if @combo_wait <= 0
      enemy.animation_id = skill.animation2_id
      enemy.battler.skill_effect(self.battler, skill, enemy, enemy.animation_id)
      @delay = 8
      @combo_start = true
      @combo_wait_start = false
      @combo_count += 1
      @combo_time = 60
      UAS.Combo.draw(@combo_count)
      if @combo_count > UAS::Combo_Shake
        $game_screen.start_shake(1, 50, 10)
      end
      if @combo_count > UAS::KnockBack
        move = rand(10)
        case move
        when 0..7
          enemy.move_backward
        when 8
          enemy.turn_left_90
          enemy.move_backward
        when 9
          enemy.turn_right_90
          enemy.move_backward
        end
      end
    end
  end
  
  def player_bullet(skill)
    return if @skill_delay[skill.name] > 0
    if $game_party.actors[0].sp < skill.sp_cost
      $console.write_red("스킬 사용에 필요한 SP가 부족합니다.")
      return
    end
    $game_party.actors[0].sp -= skill.sp_cost
    animate(UAS::Distance_Motion)
    @skill_delay[skill.name] = @save_skill_delay[skill.name]
    event = skill.eva_f
    a = 보관이벤트(event)
    a.range_set(skill)
    a.moveto(x, y)
    a.direction = direction
    Network::send("<packet> #{event} #{skill.id} #{x} #{y} #{direction} bullet #{$userdata.user_id} </packet>")
  end
  
  def net_range_set(no)
    skill = $data_skills[no]
    @range_count = 0
    @range_max = skill.variance
    @net_bullet = true
    @rskill = skill
  end
    
  def range_set(skill)
    @range_count = 0
    @range_max = skill.variance
    @bullet = true
    @rskill = skill
  end
  
  def net_bullet_process
    if not moving?
      @range_count += 1
      if @range_count > @range_max
        @sprite_id = ""
        refresh
        erase
        event_remove(self)
      end            
      move_forward
      if not moving?
        @sprite_id = ""
        refresh
        erase
        moveto_outside
        event_remove(self)
      end
    end
  end
  
  def bullet_process
    if not moving?
      @range_count += 1
      if @range_count > @range_max
        @sprite_id = ""
        refresh
        erase
        event_remove(self)
      end            
      move_forward
      if not moving?
        new_x = x + (direction == 6 ? 1 : direction == 4 ? -1 : 0)
        new_y = y + (direction == 2 ? 1 : direction == 8 ? -1 : 0)
        for enemy in all_enemies
          if enemy.x == new_x and enemy.y == new_y and enemy.action
            $game_player.bullet_skill(@rskill, enemy)
          end
        end
        @sprite_id = ""
        refresh
        erase
        moveto_outside
        event_remove(self)
      end
    end
  end
end
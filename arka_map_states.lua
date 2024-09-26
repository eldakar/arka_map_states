arka_map_states = arka_map_states or {
  handler = nil,
  handler_gmcp = nil,
  handler_ui = nil,
  data = "",
  data_enemies = "",
  cnt_t = 0,
  cnt_e = 0,
  cnt_n = 0,
  size = 50
}

function arka_map_states:append(newdata)
  if not arka_map_states.data then
    arka_map_states.data = newdata
    return
  end
  arka_map_states.data = arka_map_states.data .. newdata
end
function arka_map_states:append_enemies(newdata)
    if not arka_map_states.data_enemies then
      arka_map_states.data_enemies = newdata
      return
    end 
    arka_map_states.data_enemies = arka_map_states.data_enemies .. newdata
end

-- NEW LOCATION EVENT SHOULD RESET THE STRING 
-- 

-- REPLACEMENTS
--states = { [6] = "✅✅✅✅✅✅✅", [5] = "<green>⬛✅✅✅✅✅✅", [4] = "<yellow>⬛⬛✅✅✅✅✅", [3] = "<yellow>⬛⬛⬛✅✅✅✅", [2] = "<red>⬛⬛⬛⬛⛔⛔⛔", [1] = "⬛⬛⬛⬛⬛⛔⛔", [0] = "⬛⬛⬛⬛⬛⬛⛔" }
--states_enemy_no_color = { [6] = "✅✅✅✅✅✅✅", [5] = "<green>⬛✅✅✅✅✅✅", [4] = "<yellow>⬛⬛✅✅✅✅✅", [3] = "<yellow>⬛⬛⬛✅✅✅✅", [2] = "<red>⬛⬛⬛⬛⛔⛔⛔", [1] = "⬛⬛⬛⬛⬛⛔⛔", [0] = "⬛⬛⬛⬛⬛⬛⛔" }
--states_normal = states
--states_enemy = states

states = { [6] = "<green>#######", [5] = "<green>-######", [4] = "<yellow>--#####", [3] = "<yellow>---####", [2] = "<red>----###", [1] = "<red>-----##", [0] = "<red>------#" }
states_enemy_no_color = { [6] = "#######", [5] = "-######", [4] = "--#####", [3] = "---####", [2] = "----###", [1] = "-----##", [0] = "------#" }
states_normal = states
states_enemy = states


function ateam:collect_people_on_location()
  ateam.people_on_location = {}
  arka_map_states.data = ""
  arka_map_states.data_enemies = ""
  arka_map_states.cnt_t = 0
  arka_map_states.cnt_e = 0
  arka_map_states.cnt_n = 0
  for k, v in pairs(gmcp.objects.nums) do
      if ateam.objs[tonumber(v)] then
          table.insert(ateam.people_on_location, ateam.objs[tonumber(v)]["desc"])
      end
  end
end

function scripts.ui.no_weapon_alert:blink() return end

function trigger_func_skrypty_ui_footer_elements_weapon_on() return end


function ateam:print_obj_team(id, obj)
  --
  -- id - id of object. for example '30000'. it's the id from Arkadia
  -- obj - dictionary of object
  --
  if id == ateam.my_id then
    arka_map_states.data = ""
    arka_map_states.data_enemies = "" --scripts.ui.states_window_navbar_str .. "\n\n"
    arka_map_states.cnt_t = 0
    arka_map_states.cnt_e = 0
    arka_map_states.cnt_n = 0
  end

  if obj then
      -- mark it as current target if necessary
      if obj["defense_target"] == true then
          ateam.current_defense_target = id
          ateam.current_defense_target_relative = ateam.team[id]
      end

      local str_id = " @"

      if ateam.team[id] then
          str_id = string.sub(" " .. ateam.team[id], 1, 3)
      end

      -- special section
      if obj["defense_target"] == true then
          arka_map_states:append("<green:team_console_bg>>>")
      else
          arka_map_states:append("<black:team_console_bg>--")
      end

      -- id section
      if ateam.broken_defense_names[obj["desc"]] then
          arka_map_states:append("<" .. ateam.options.broken_defense_fg_color .. ":" .. ateam.options.broken_defense_bg_color .. ">"..ateam.options.bracket_symbol_left .. str_id .. "]")
      else
          arka_map_states:append("<"..ateam.options.bracket_color..":team_console_bg>"..ateam.options.bracket_symbol_left.."<reset>" .. str_id .. "<"..ateam.options.bracket_color..":team_console_bg>"..ateam.options.bracket_symbol_right)
      end

      -- count attackers
      if ateam.options.visible_attacker_count then
          local str_attackers = "--"
          if table.size(ateam.team_enemies[id]) > 0 then
              str_attackers = scripts.utils.str_pad(tostring(table.size(ateam.team_enemies[id])), 2, "right")
          end
          arka_map_states:append("<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_left.."<reset><red:team_console_bg>"..str_attackers.."<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_right)
      end

      -- sneaky id section
      if ateam.sneaky_attack > 0 then
          arka_map_states:append("<white:team_console_bg>[  ]")
      end

      -- team lead
      local str_lead = ""
      if obj["team_leader"] and ateam.options.leader_indicator_symbol ~= "" then
          str_lead = "<yellow:team_console_bg>"..ateam.options.leader_indicator_symbol
      end

      -- hp section
      if states[obj["hp"]] then
          arka_map_states:append("<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_left.."<reset>" .. states[obj["hp"]] .. "<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_right.." "..str_lead)
      else
          debugc("HP value: " .. tostring(obj["hp"]))
      end

      if str_id ~= " @" then
          local hp_to_select = string.split(states[obj["hp"]], ">")[2]
      end

      -- stealth
      local stealth_symbol_left = ""
      local stealth_symbol_right = ""
      if ateam.options.visible_stealth and obj["hidden"] then
          stealth_symbol_left = "<white:team_console_bg>["
          stealth_symbol_right = "<white:team_console_bg>]"
      end

      -- name section
      local str_name = ateam.options.own_name
      local str_name_original = obj["desc"]
      if str_id ~= " @" then
          str_name = str_name_original
      end

      if ateam.paralyzed_names[obj["desc"]] then
          arka_map_states:append("<" .. ateam.options.team_mate_stun_fg_color .. ":" .. ateam.options.team_mate_stun_bg_color .. ">" .. str_name .. " ")
      elseif str_name ~= ateam.options.own_name then
          arka_map_states:append(stealth_symbol_left .. "<LimeGreen:team_console_bg>" .. str_name .. stealth_symbol_right .. " ")
      else
          arka_map_states:append(stealth_symbol_left .. "<white:team_console_bg>" .. str_name .. stealth_symbol_right .. " ")
      end

      -- zas section
      local zas_str = ""
      if ateam.team_enemies[id] then
--          zas_str = "  <- [" .. table.concat(ateam.team_enemies[id], ",") .. "]"
          arka_map_states:append("<white:team_console_bg>" .. zas_str)
      elseif not table.is_empty(ateam.team_enemies) and not obj.attack_num then
          arka_map_states:append("  <red:team_console_bg>X<reset>")
      end

      if scripts.ui.states_window_nav_states["guard_state"] and id == ateam.my_id then
        arka_map_states:append(" " .. scripts.ui.states_window_nav_states["guard_state"])
      end

      arka_map_states:append("\n<reset>")
  end
end

function ateam:print_obj_enemy(id, obj)
  --
  -- id - id of object. for example '30000'. it's the id from Arkadia
  -- obj - dictionary of object
  --

  if obj then
      -- mark it as current target if necessary
      if obj["attack_target"] == true then
          ateam.current_attack_target = id
          ateam.current_attack_target_relative = ateam.enemy_op_ids[id]
      end

      local print_id = ateam.enemy_op_ids[id]
      local str_id = "  "

      if tonumber(print_id) > 9 then
          str_id = print_id
      else
          str_id = " " .. print_id
      end

      -- special section
      if obj["attack_target"] == true then
          arka_map_states:append_enemies("<red:team_console_bg>>>")
      else
          arka_map_states:append_enemies("<white:team_console_bg>--")
      end

      -- id section
      if ateam.broken_defense_names[obj["desc"]] then
          arka_map_states:append_enemies("<" .. ateam.options.broken_defense_fg_color .. ":" .. ateam.options.broken_defense_bg_color .. ">".. ateam.options.bracket_symbol_left .. str_id .. "]")
      else
          local color = "white"
          if id == ateam.next_attack_objs.next_attak_obj and ateam.next_attack_objs.mark_in_state then
              color = "orange"
          end
          arka_map_states:append_enemies(string.format("<%s:team_console_bg>%s<%s>%s<%s>%s<reset>", ateam.options.bracket_color,
    ateam.options.bracket_symbol_left,
    color,
    str_id,
    ateam.options.bracket_color,
    ateam.options.bracket_symbol_right))
      end

      -- count attackers
      if ateam.options.visible_attacker_count then
          local str_attackers = "--"
          if table.size(ateam.attacking_by_team[id]) > 0 then
              str_attackers = scripts.utils.str_pad(tostring(table.size(ateam.attacking_by_team[id])), 2, "right")
          end
          arka_map_states:append_enemies("<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_left.."<reset><red:team_console_bg>".. str_attackers.."<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_right)
      end

      -- sneaky id section
      if ateam.sneaky_attack > 0 then
          arka_map_states:append_enemies("<white:team_console_bg>[  ]")
      end

      -- hp section
      arka_map_states:append_enemies("<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_left.."<reset>" .. states_enemy[obj["hp"]] .. "<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_right.." ")

      -- name section
      local str_name = obj["desc"]

      -- coloring for enemy desc
      local is_enemy = false
      if ateam.objs[ateam.my_id]["attack_num"] == id then
          if ateam.paralyzed_names[obj["desc"]] then
              arka_map_states:append_enemies("<" .. ateam.options.enemy_stun_fg_color .. ":" .. ateam.options.enemy_stun_bg_color .. ">" .. str_name)
          else
              arka_map_states:append_enemies("<red:team_console_bg>" .. str_name)
          end

          is_enemy = true
      elseif obj["enemy"] == true or ateam.team[obj["attack_num"]] then
          if ateam.paralyzed_names[obj["desc"]] then
              arka_map_states:append_enemies("<" .. ateam.options.enemy_stun_fg_color .. ":" .. ateam.options.enemy_stun_bg_color .. ">" .. str_name)
          else
              arka_map_states:append_enemies("<dark_violet:team_console_bg>" .. str_name)
          end

          is_enemy = true
      else
          if ateam.paralyzed_names[obj["desc"]] then
              arka_map_states:append_enemies("<" .. ateam.options.enemy_stun_fg_color .. ":" .. ateam.options.enemy_stun_bg_color .. ">" .. str_name)
          else
              arka_map_states:append_enemies("<white:team_console_bg>" .. str_name)
          end
      end

      -- attacking by whom section
      if table.size(ateam.attacking_by_team[id]) > 0 then
          by_whom_str = "  -> [" .. table.concat(ateam.attacking_by_team[id], ",") .. "]   "
          arka_map_states:append_enemies("<white:team_console_bg>" .. by_whom_str)
      end

      arka_map_states:append_enemies("\n<reset>")
  end
end

function ateam:print_obj_normal(id, obj)
  --
  -- id - id of object. for example '30000'. it's the id from Arkadia
  -- obj - dictionary of object
  --

  if obj then
      local print_id = ateam.normal_ids[id]
      local str_id = "  "

      if not print_id then
          str_id = "  "
      elseif tonumber(print_id) > 9 then
          str_id = print_id
      else
          str_id = " " .. print_id
      end

      arka_map_states:append_enemies("<black:team_console_bg>--")

      -- id section
      local color = "white"
      if id == ateam.next_attack_objs.next_attak_obj and ateam.next_attack_objs.mark_in_state then
          color = "orange"
      end
      arka_map_states:append_enemies(
        string.format("<%s:team_console_bg>%s<%s>%s<%s>%s<reset>", ateam.options.bracket_color,
        ateam.options.bracket_symbol_left,
        color,
        str_id,
        ateam.options.bracket_color,
        ateam.options.bracket_symbol_right))

      -- count attackers
      if ateam.options.visible_attacker_count then
          local str_attackers = "--"
          if table.size(ateam.attacking_by_team[id]) > 0 then
              str_attackers = scripts.utils.str_pad(tostring(table.size(ateam.attacking_by_team[id])), 2, "right")
          end
          arka_map_states:append_enemies("<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_left.."<reset><red:team_console_bg>"..str_attackers.."<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_right)
      end
      
      -- sneaky id section
      if ateam.sneaky_attack > 0 then
          if ateam.sneaky_attack > 1 or ateam:can_perform_sneaky_attack() then
              arka_map_states:append_enemies("<white:team_console_bg>[<sky_blue:team_console_bg>xx<white:team_console_bg>]")
          else
              arka_map_states:append_enemies("<white:team_console_bg>[  ]")
          end
      end

      -- hp section

      local str_state = states_normal[obj["hp"]]
      if scripts.ui.fancy.enabled then
          local name_or_type = string.split(obj["desc"], " ")
          name_or_type=name_or_type[#name_or_type]
          local icon_symbol = scripts.ui.fancy.object_icons[name_or_type]

          if icon_symbol ~= nil then
              str_state = utf8.gsub(str_state, "👤", icon_symbol, 1)
          end
      end

      arka_map_states:append_enemies("<"..ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_left.."<reset>" .. str_state .. "<" .. ateam.options.bracket_hp_color..":team_console_bg>"..ateam.options.bracket_symbol_right.." ")

      -- stealth
      local stealth_symbol_left = ""
      local stealth_symbol_right = ""
      if ateam.options.visible_stealth and obj["hidden"] then
          stealth_symbol_left = "<white:team_console_bg>["
          stealth_symbol_right = "<white:team_console_bg>]"
      end

      -- name section
      local str_name = obj["desc"]

      -- set color for desc
      arka_map_states:append_enemies(stealth_symbol_left .. "<white:team_console_bg>" .. str_name .. stealth_symbol_right)

      arka_map_states:append_enemies("\n<reset>")
  end
end


function arka_map_states:map_info()
  return "" .. cecho2string(self.data), true
end
function arka_map_states:cleanup()
  self.data=""
end

function arka_map_states:label_states()
    cecho("testlabel",arka_map_states.data)
    cecho("testlabell",arka_map_states.data_enemies)
end


function arka_map_states:popup_team_font_adjustment(size)
    if size < 10 then
        setLabelStyleSheet("testlabel", [[
            font-family: "Lucida Console", monospace;
            font-size: 10pt;
        ]])
    elseif size < 15 then
        setLabelStyleSheet("testlabel", [[
            font-family: "Lucida Console", monospace;
            font-size: 5pt;
        ]])
    end
    testlabel:setColor(20,20,20, 0)
end

function arka_map_states:popup_enemy_font_adjustment()
        setLabelStyleSheet("testlabell", [[
            font-family: "Lucida Console", monospace;
            font-size: 6pt;
        ]])
    testlabell:setColor(40,20,20, 230)
    self:fake()
end


function arka_map_states:popup()

    testlabell = Geyser.Label:new({
        name = "testlabell",
        x = "50%", y = "0",
        width = "100%", height = "100%",
    },scripts.ui.bottom)

    testlabel = Geyser.Label:new({
        name = "testlabel",
        x = "20%", y = "0",
        width = "30%", height = "100%",
    },scripts.ui.bottom)

    --name = "scripts.ui.bottom",
--    testlabel:setColor(100,0,0,80)

    setLabelStyleSheet("testlabel", [[font-family: "Lucida Console", monospace;font-size: 10pt;]])
    setLabelStyleSheet("testlabell", [[font-family: "Lucida Console", monospace;font-size: 8pt;]])

    testlabel:setColor(20,20,20, 0)
    testlabell:setColor(40,20,20, 230)

end

--gmcp_parsing_finished
function arka_map_states:resize_fonts()
    local cnt_t = 1
    local cnt_e = 0
    local combat = false
    -- count people
    for k, v in pairs(gmcp.objects.nums) do
        if ateam.objs[v].team == true then
            cnt_t = cnt_t + 1
        else 
            cnt_e = cnt_e + 1
        end
    end
    
    if cnt_t ~= self.cnt_t then
        setLabelStyleSheet("testlabel",arka_map_states_font_team[100][cnt_t])
        testlabel:setColor(20,20,20, 0)
        self.cnt_t = cnt_t
    end

    if cnt_e > 20 then cnt_e = 20 end
    if cnt_e == 0 then return end

    if cnt_e ~= self.cnt_e then
        setLabelStyleSheet("testlabell",arka_map_states_font_enemy[100][cnt_e])
        testlabell:setColor(40,20,20, 230)
        self.cnt_e = cnt_e
    end
end


function arka_map_states:init()
--arka_map_states:popup()
  --registerMapInfo("map_states", function() return self:map_info() end)
  --enableMapInfo("map_states")
  --self.handler = scripts.event_register:register_singleton_event_handler(self.handler, "printStatusDone", function() enableMapInfo("map_states") end)
  self.handler = scripts.event_register:register_singleton_event_handler(self.handler, "printStatusDone", function() self.label_states() end)
  self.handler_gmcp = scripts.event_register:register_singleton_event_handler(self.handler_gmcp, "gmcp_parsing_finished", function() arka_map_states:resize_fonts() end)
  self.handler_ui = scripts.event_register:register_singleton_event_handler(self.handler_ui, "uiReady", function() arka_map_states:popup() end)
  --uiReady
end

arka_map_states:init()

arka_map_states_font_team = {}
arka_map_states_font_enemy = {}
arka_map_states_font_team[100] = {}
arka_map_states_font_enemy[100] = {}

arka_map_states_font_team[100][1] = [[font-family: "Lucida Console", monospace;font-size: 10pt;]]
arka_map_states_font_team[100][2] = [[font-family: "Lucida Console", monospace;font-size: 10pt;]]
arka_map_states_font_team[100][3] = [[font-family: "Lucida Console", monospace;font-size: 10pt;]]
arka_map_states_font_team[100][4] = [[font-family: "Lucida Console", monospace;font-size: 10pt;]]
arka_map_states_font_team[100][5] = [[font-family: "Lucida Console", monospace;font-size: 10pt;]]
arka_map_states_font_team[100][6] = [[font-family: "Lucida Console", monospace;font-size: 10pt;]]
arka_map_states_font_team[100][7] = [[font-family: "Lucida Console", monospace;font-size: 9pt;]]
arka_map_states_font_team[100][8] = [[font-family: "Lucida Console", monospace;font-size: 8pt;]]
arka_map_states_font_team[100][9] = [[font-family: "Lucida Console", monospace;font-size: 8pt;]]
arka_map_states_font_team[100][10] = [[font-family: "Lucida Console", monospace;font-size: 6pt;]]
arka_map_states_font_team[100][11] = [[font-family: "Lucida Console", monospace;font-size: 6pt;]]
arka_map_states_font_team[100][12] = [[font-family: "Lucida Console", monospace;font-size: 6pt;]]
arka_map_states_font_team[100][13] = [[font-family: "Lucida Console", monospace;font-size: 5pt;]]
arka_map_states_font_team[100][14] = [[font-family: "Lucida Console", monospace;font-size: 5pt;]]
arka_map_states_font_team[100][15] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_team[100][16] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_team[100][17] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_team[100][18] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_team[100][19] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_team[100][20] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]

arka_map_states_font_enemy[100][1] = [[font-family: "Lucida Console", monospace;font-size: 14pt;]]
arka_map_states_font_enemy[100][2] = [[font-family: "Lucida Console", monospace;font-size: 14pt;]]
arka_map_states_font_enemy[100][3] = [[font-family: "Lucida Console", monospace;font-size: 14pt;]]
arka_map_states_font_enemy[100][4] = [[font-family: "Lucida Console", monospace;font-size: 14pt;]]
arka_map_states_font_enemy[100][5] = [[font-family: "Lucida Console", monospace;font-size: 14pt;]]
arka_map_states_font_enemy[100][6] = [[font-family: "Lucida Console", monospace;font-size: 12pt;]]
arka_map_states_font_enemy[100][7] = [[font-family: "Lucida Console", monospace;font-size: 10pt;]]
arka_map_states_font_enemy[100][8] = [[font-family: "Lucida Console", monospace;font-size: 8pt;]]
arka_map_states_font_enemy[100][9] = [[font-family: "Lucida Console", monospace;font-size: 8pt;]]
arka_map_states_font_enemy[100][10] = [[font-family: "Lucida Console", monospace;font-size: 6pt;]]
arka_map_states_font_enemy[100][11] = [[font-family: "Lucida Console", monospace;font-size: 6pt;]]
arka_map_states_font_enemy[100][12] = [[font-family: "Lucida Console", monospace;font-size: 6pt;]]
arka_map_states_font_enemy[100][13] = [[font-family: "Lucida Console", monospace;font-size: 5pt;]]
arka_map_states_font_enemy[100][14] = [[font-family: "Lucida Console", monospace;font-size: 5pt;]]
arka_map_states_font_enemy[100][15] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_enemy[100][16] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_enemy[100][17] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_enemy[100][18] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_enemy[100][19] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]
arka_map_states_font_enemy[100][20] = [[font-family: "Lucida Console", monospace;font-size: 4pt;]]


--team 1-7 font 10pt --
--team 8-9 font 8pt --
--team 10-12 font 6pt --


--enemy 1-5 font 14pt
function arka_map_states:fake()
    self.data = "--[ @][--][#######] [Eldakar] 2.32\n" ..
    "--[ 2][--][#######] [Eldakar] 2.32\n" ..
    "--[ 3][--][#######] [Eldakar] 2.32\n" ..
    "--[ 4][--][#######] [Eldakar] 2.32\n" ..
    "--[ 5][--][#######] [Eldakar] 2.32\n" ..
    "--[ 6][--][#######] [Eldakar] 2.32\n" ..
    "--[ 7][--][#######] [Eldakar] 2.32\n" ..
    "--[ 8][--][#######] [Eldakar] 2.32\n" ..
    "--[ 9][--][#######] [Eldakar] 2.32\n" ..
    "--[10][--][#######] [Eldakar] 2.32\n" ..
    "--[11][--][#######] [Eldakar] 2.32\n" ..
    "--[12][--][#######] [Eldakar] 2.32\n" ..
    "--[13][--][#######] [Eldakar] 2.32\n" ..
    "--[14][--][#######] [Eldakar] 2.32\n" ..
    "--[15][--][#######] [Eldakar] 2.32\n" ..
    "--[16][--][#######] [Eldakar] 2.32\n" ..
    "--[17][--][#######] [Eldakar] 2.32\n" ..
    "--[18][--][#######] [Eldakar] 2.32\n" ..
    "--[19][--][#######] [Eldakar] 2.32\n" ..
    "--[20][--][#######] [Eldakar] 2.32\n"
    self.data_enemies = "--[ 1][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 2][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 3][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 4][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 5][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 6][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 7][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 8][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[ 9][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[10][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[11][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[12][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[13][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[14][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[15][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[16][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[17][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[18][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[19][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n" .. 
                        "--[20][ 1][#######] gburowaty bialobrody krasnolud chaosu -> [@]\n"
    arka_map_states:label_states()
end


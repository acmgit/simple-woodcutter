local ms, mt = minetest.settings, minetest
local max_distance = tonumber(ms:get "simple_woodcutter.max_distance") or 40
local max_radius = tonumber(ms:get "simple_woodcutter.max_radius") or 1
local delay = tonumber(ms:get "simple_woodcutter.delay") or 0.01
local S = mt.get_translator(mt.get_current_modname())

mt.register_privilege("lumberjack", {
                             description = S("Player can lumber trees fast.")})

local function chop_around(pos, oldnode, digger)
  if (not digger) then return end
  local next_pos, digger_pos
  for distance = 1, max_distance do
      mt.after(delay,
      function()
          if (not digger) then return end
          next_pos = mt.find_node_near(pos, max_radius, {oldnode.name, "group:leaves"})
          if not next_pos then return end
          if not digger:get_player_control().sneak then return end
          digger_pos = digger:get_pos()
          if not digger_pos then return end
          mt.node_dig(next_pos, mt.get_node(next_pos), digger)
          pos = next_pos
      end) -- mt.after
  end -- for
end -- function

mt.register_on_dignode(function(pos, oldnode, digger)
  if not digger:get_player_control().sneak then return end
  if not mt.check_player_privs(digger:get_player_name(), {lumberjack=true}) then return end
  if not digger:get_wielded_item():get_definition().groups.axe then return end
  if digger:get_hp() == 0 then return end
  if not mt.registered_nodes[oldnode.name] then return end
  if not mt.registered_nodes[oldnode.name].groups.tree then return end


  minetest.after(delay, chop_around, pos, oldnode, digger)
end)

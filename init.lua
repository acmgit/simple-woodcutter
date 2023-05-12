local ms, mt = minetest.settings, minetest
local max_distance = tonumber(ms:get "simple_woodcutter.max_distance") or 40
local max_radius = tonumber(ms:get "simple_woodcutter.max_radius") or 1

local function chop_around(pos, oldnode, digger)
  local next_pos, digger_pos
  for distance = 1, max_distance do
      next_pos = mt.find_node_near(pos, max_radius, {oldnode.name, "group:leaves"})
      if not next_pos then break end
      digger_pos = digger:get_pos()
      if not digger_pos then break end
      if pos:distance(digger_pos) > max_distance then break end
      mt.node_dig(next_pos, mt.get_node(next_pos), digger)
      pos = next_pos
  end
end

mt.register_on_dignode(function(pos, oldnode, digger)
  if not mt.registered_nodes[oldnode.name].groups.tree then return end
  if not digger:get_wielded_item():get_definition().groups.axe then return end
  if digger:get_hp() == 0 then return end
  if not digger:get_player_control().sneak then return end
  chop_around(pos, oldnode, digger)
end)

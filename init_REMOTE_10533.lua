local ms, mt = minetest.settings, minetest
local max_distance = tonumber(ms:get "simple_woodcutter.max_distance") or 40
local max_radius = tonumber(ms:get "simple_woodcutter.max_radius") or 1
local delay = tonumber(ms:get "simple_woodcutter.delay") or 0.01
local S = mt.get_translator(mt.get_current_modname())

minetest.register_privilege("lumberjack", {
                             description = S("Player can lumber trees fast.")})

local function chop_around(pos, oldnode, digger)
  local next_pos = minetest.find_node_near(pos, max_radius, oldnode.name)
  if not next_pos then return end
  local digger_pos = digger:get_pos()
  if not digger_pos then return end
  if pos:distance(digger_pos) > max_distance then return end
  minetest.node_dig(next_pos, minetest.get_node(next_pos), digger)
  minetest.after(delay, chop_around, pos, oldnode, digger)
end

minetest.register_on_dignode(function(pos, oldnode, digger)
  if not minetest.registered_nodes[oldnode.name].groups.tree then return end
  if not digger:get_wielded_item():get_definition().groups.axe then return end
  if digger:get_hp() == 0 then return end
  if not mt.check_player_privs(digger:get_player_name(), {lumberjack=true}) then return end
  minetest.after(delay, chop_around, pos, oldnode, digger)
end)

--[[
使用随机IP进行压测，更接近真实场景

使用方式
wrk -c100 -t2 -d60s "http://10.0.16.15/" -s scripts/random_ip.lua
--]]

request = function()
  local random_ip = math.random(0, 255) .. '.' .. math.random(0, 255) 
                  .. '.' .. math.random(0, 255) .. '.' .. math.random(0, 255)
  path = '/ip?ip=' .. random_ip
  return wrk.format(nil, path)
end
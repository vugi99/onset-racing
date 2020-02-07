local plyvehs = {}
local checkpoints = nil

local playerscheckpoints = {}

local races = {}
   races["first"] = {
     {122952,105857,2400,-90},
     {121121,72574,1155},
     {111229,32815,1155},
     {98125,10518,1375},
     {98840,-38486,1240},
     {95131,-72866,1209},
     {89467,-90448,1632},
     {90715,-106145,1169},
     {99717,-111916,1263},
     {116731,-107788,1115},
     {134141,-129625,1151},
     {152931,-145749,1155}
   }

function createcheckpoints(mapname)
   checkpoints = {}
   for i,v in ipairs(races[mapname]) do
      if i ~= 1 then
         local obj = CreateObject(336, v[1], v[2], v[3] , 0, 0, 0, 10, 10, 10)
         SetObjectStreamDistance(obj, 30000)
          table.insert(checkpoints,obj)
      end
   end
end


AddEvent("OnPlayerJoin", function(ply)
   SetPlayerSpawnLocation(ply, races.first[1][1], races.first[1][2], races.first[1][3], races.first[1][4])
   SetPlayerRespawnTime(ply, 500)
   if not checkpoints then
      createcheckpoints("first")
      local tbl = {}
      tbl.ply = ply
      tbl.number = 0
      table.insert(playerscheckpoints,tbl)
      CallRemoteEvent(ply,"checkpointstbl",races["first"])
   end
end)

function spawnveh(ply,id,first)
   for i,v in ipairs(plyvehs) do
      if v.ply == ply then
         DestroyVehicle(v.vid)
         table.remove(plyvehs,i)
      end
   end
   local px,py,pz = GetPlayerLocation(ply)
   local h = GetPlayerHeading(ply)
   local veh = nil
   if custompos then
      veh = CreateVehicle(id, x, y, z)
      SetVehicleRotation(veh, rx, ry, rz)
   else
       veh = CreateVehicle(id, px, py, pz , h)
   end
   SetVehicleLicensePlate(veh, "RACING")
   SetVehicleRespawnParams(veh, false)
   AttachVehicleNitro(veh,true)
   local tbin = {}
   tbin.ply = ply
   tbin.vid = veh
   table.insert(plyvehs,tbin)
   if first == true then
      local ping = GetPlayerPing(ply)
      if ping == 0 then
          ping = 50
      else
         ping=ping*6
      end
      Delay(ping,function()
         SetPlayerInVehicle(ply, veh)
      end)
   else
      SetPlayerInVehicle(ply, veh)
   end
end

AddEvent("OnPlayerSpawn", function(ply)
      spawnveh(ply,12,true)
end)

AddEvent("OnPlayerLeaveVehicle",function(ply,veh,seat)
   if GetPlayerPropertyValue(ply,"leaving")==nil then
    spawnveh(ply,12)
   end
end)

AddEvent("OnGameTick",function()
    for i,v in ipairs(GetAllVehicles()) do
      SetVehicleHealth(v, 5000)
      SetVehicleDamage(v, 1, 0.0)
      SetVehicleDamage(v, 2, 0.0)
      SetVehicleDamage(v, 3, 0.0)
      SetVehicleDamage(v, 4, 0.0)
      SetVehicleDamage(v, 5, 0.0)
      SetVehicleDamage(v, 6, 0.0)
      SetVehicleDamage(v, 7, 0.0)
      SetVehicleDamage(v, 8, 0.0)
    end
end)

AddEvent("OnPlayerQuit",function(ply)
   for i,v in ipairs(plyvehs) do
      if v.ply == ply then
         SetPlayerPropertyValue(ply,"leaving",true,false)
         DestroyVehicle(v.vid)
         table.remove(plyvehs,i)
      end
   end
   for i,v in ipairs(playerscheckpoints) do
       if v.ply == ply then
         table.remove(playerscheckpoints,i)
       end
   end
end)

AddEvent("OnGameTick",function()
   for i,v in ipairs(playerscheckpoints) do
   if GetPlayerVehicle(v.ply)~=0 then
      local veh = GetPlayerVehicle(v.ply)
     for i,vc in ipairs(checkpoints) do
        if i==v.number+1 then
         local x,y,z = GetVehicleLocation(veh)
         local x2,y2,z2 = GetObjectLocation(vc)
         if GetDistance2D(x, y, x2, y2)<750 then
            v.number=i
            CallRemoteEvent(v.ply,"hidecheckpoint",vc)
         end
        end
     end
   end
   end
end)


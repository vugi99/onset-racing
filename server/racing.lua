local plyvehs = {}
local checkpoints = nil

local playerscheckpoints = {}

local currace = 1

local racesnumbers = {
   "first",
   "gudrace"
}
--[[
  spawns["name"] = {
      angle,
      1{x,y,z},
      2{x,y,z},
      ...
   }
]]--
local spawns = {}
   spawns["first"] = {
      -90,
      {122392,105408,2400},
      {122913,105408,2400},
      {123416,105408,2400},
      {122392,106408,2400},
      {122913,106408,2400},
      {123416,106408,2400},
      {122913,107408,2400},
      {123416,107408,2400}
   }
   spawns["gudrace"] = {
      -25,
      {-72024,26202,4600},
      {-72024,25732,4600},
      {-72024,25191,4600},
      {-73024,26202,4650},
      {-73024,25732,4650},
      {-73024,25191,4650},
      {-74024,26202,4650},
      {-74024,25732,4650}
   }

local races = {}
   races["first"] = {
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
     {152931,-145749,1155,-90}
   }
   races["gudrace"] = {
      {-57811,12338,4767},
      {-61033,-5821,4084},
      {-59680,-25989,3325},
      {-85770,-40159,3304},
      {-100516,-29882,3265},
      {-105346,-6557,2675},
      {-88862,-4111,2283},
      {-99669,-21663,1082},
      {-127300,-36820,1311},
      {-137911,-20320,1045},
      {-125381,-10583,1757},
      {-113182,-4591,2685},
      {-116626,8729,1885},
      {-130166,22023,2632},
      {-141201,32818,3764},
      {-129516,45903,2931},
      {-105833,41636,4398},
      {-85590,32032,4609,65},
    }

function createcheckpoints(mapname)
   if checkpoints then
       for i,v in ipairs(checkpoints) do
         DestroyObject(v)
       end
   end
   checkpoints = {}
   for i,v in ipairs(races[mapname]) do
         if i == #races[mapname] then
            local obj = CreateObject(646, v[1], v[2], v[3]+400 , 0, v[4], 0, 5, 5, 5)
          table.insert(checkpoints,obj)
         else
         local obj = CreateObject(336, v[1], v[2], v[3] , 0, 0, 0, 10, 10, 10)
          table.insert(checkpoints,obj)
         end
   end
end

function changerace()
   for i,v in ipairs(GetAllPlayers()) do
      createcheckpoints(racesnumbers[currace])
      local tbl = {}
      tbl.ply = v
      tbl.number = 0
      table.insert(playerscheckpoints,tbl)
      CallRemoteEvent(v,"checkpointstbl",races[racesnumbers[currace]])
      SetPlayerSpawnLocation(v, spawns[racesnumbers[currace]][i+1][1], spawns[racesnumbers[currace]][i+1][2], spawns[racesnumbers[currace]][i+1][3], spawns[racesnumbers[currace]][1])
      SetPlayerHealth(v, 0)
   end
end


AddEvent("OnPlayerJoin", function(ply)
   if GetPlayerCount()<=8 then
   if not checkpoints then
      SetPlayerSpawnLocation(ply, spawns[racesnumbers[currace]][2][1], spawns[racesnumbers[currace]][2][2], spawns[racesnumbers[currace]][2][3], spawns[racesnumbers[currace]][1])
   else
      SetPlayerSpawnLocation(ply, 125773.000000, 80246.000000, 1645.000000, 90.0)
   end
   SetPlayerRespawnTime(ply, 500)
   if not checkpoints then
      changerace()
   end
else
   KickPlayer(ply, "Max 8 players")
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
   for i,v in ipairs(playerscheckpoints) do
      if v.ply == ply then
         spawnveh(ply,12,true)
      end
   end
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
   if #playerscheckpoints==0 then
      checkpoints=nil
   end
end)

function checktorestart()
   if #playerscheckpoints==0 then
      if #racesnumbers==currace then
         currace=1
         changerace()
      else
         currace=currace+1
         changerace()
      end
   end
end

AddEvent("OnGameTick",function()
   for i,v in ipairs(playerscheckpoints) do
   if GetPlayerVehicle(v.ply)~=0 then
      local veh = GetPlayerVehicle(v.ply)
     for i2,vc in ipairs(checkpoints) do
        if i2==v.number+1 then
         local x,y,z = GetVehicleLocation(veh)
         local x2,y2,z2 = GetObjectLocation(vc)
         if GetDistance2D(x, y, x2, y2)<750 then
            v.number=i2
            CallRemoteEvent(v.ply,"hidecheckpoint",vc)
            if i2 == #checkpoints then
               table.remove(playerscheckpoints,i)
               checktorestart()
            end
         end
        end
     end
   end
   end
end)


local nitro = true
local dev = true
local time_after_finish_ms = 60000
local time_bef_start_s = 6

local plyvehs = {}
local checkpoints = nil

local finished = nil

local playerscheckpoints = {}

local finishclassement = {}

local currace = 1

function createcheckpoints(mapname)
   if checkpoints then
       for i,v in ipairs(checkpoints) do
         DestroyObject(v)
       end
   end
   checkpoints = {}
   for i,v in ipairs(races[mapname]) do
         if i+1 == #races[mapname] then
            local obj = CreateObject(52, races[mapname][i+1][1], races[mapname][i+1][2], races[mapname][i+1][3] , 0, races[mapname][i+1][4], 0, 1, 1, 1)
          table.insert(checkpoints,obj)
         else
            if races[mapname][i+1] then
         local obj = CreateObject(336, races[mapname][i+1][1], races[mapname][i+1][2], races[mapname][i+1][3] , 0, 0, 0, 10, 10, 10)
          table.insert(checkpoints,obj)
            end
         end
   end
end

function changerace()
   finishclassement = {}
   createcheckpoints(racesnumbers[currace])
   for i,v in ipairs(GetAllPlayers()) do
      local tbl = {}
      tbl.ply = v
      tbl.number = 0
      table.insert(playerscheckpoints,tbl)
      CallRemoteEvent(v,"checkpointstbl",races[racesnumbers[currace]],time_bef_start_s)
      SetPlayerSpawnLocation(v, spawns[racesnumbers[currace]][i+1][1], spawns[racesnumbers[currace]][i+1][2], spawns[racesnumbers[currace]][i+1][3], spawns[racesnumbers[currace]][1])
      SetPlayerHealth(v, 0)
      CallRemoteEvent(v,"StopSpec")
      CallRemoteEvent(v,"classement_update",i,GetPlayerCount())
   end
end


AddEvent("OnPlayerJoin", function(ply)
   if GetPlayerCount()<=16 then
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
   KickPlayer(ply, "Max 16 players")
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
   AttachVehicleNitro(veh,nitro)
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
   local found = false
   for i,v in ipairs(playerscheckpoints) do
      if v.ply == ply then
         found=true
         spawnveh(ply,12,true)
         v.number = 1
         CallRemoteEvent(ply,"reset_checkpoints")
      end
   end
   if not found then
      for i,v in ipairs(playerscheckpoints) do
         local ping = GetPlayerPing(ply)
         if ping == 0 then
             ping = 50
         else
            ping=ping*6
         end
         Delay(ping,function()
            speclogic(ply,playerscheckpoints[i].ply)
         end)
         break
      end
   end
end)

AddEvent("OnPlayerLeaveVehicle",function(ply,veh,seat)
   if GetPlayerPropertyValue(ply,"leaving")==nil then
      if GetPlayerPropertyValue(ply,"leavingtospec")==nil then
          spawnveh(ply,12)
      else
         for i,v in ipairs(plyvehs) do
            if v.ply == ply then
               DestroyVehicle(v.vid)
               table.remove(plyvehs,i)
               local ping = GetPlayerPing(ply)
               if ping == 0 then
                   ping = 50
                else
                ping=ping*6
               end
               Delay(ping,function()
                  for i,v in ipairs(playerscheckpoints) do
                     speclogic(ply,playerscheckpoints[i].ply)
                     break
                  end
               end)
            end
         end
         SetPlayerPropertyValue(ply,"leavingtospec",nil,false)
      end
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
   for i,v in ipairs(finishclassement) do
      if v == ply then
        table.remove(finishclassement,i)
      end
  end
   if GetPlayerCount()<2 then
      for i,v in ipairs(checkpoints) do
         DestroyObject(v)
       end
       checkpoints=nil
   else
       checktorestart()
   end
end)



function checktorestart()
   if #playerscheckpoints==0 then
      for i,v in ipairs(GetAllPlayers()) do
         CallRemoteEvent(v,"Start_finish_timer",time_after_finish_ms,true)
      end
      finished=true
      if #racesnumbers==currace then
         currace=1
         changerace()
      else
         currace=currace+1
         changerace()
      end
   else
      if #finishclassement==1 then
         for i,v in ipairs(GetAllPlayers()) do
            CallRemoteEvent(v,"Start_finish_timer",time_after_finish_ms,false)
         end
         finished=false
         Delay(time_after_finish_ms,function()
            if finished == false then
            playerscheckpoints={}
            checktorestart()
            end
         end)
      end
   end
end



function timercheck()
   for i,v in ipairs(playerscheckpoints) do
      if GetPlayerVehicle(v.ply)~=0 then
         local veh = GetPlayerVehicle(v.ply)
         if IsValidVehicle(veh) then
        for i2,vc in ipairs(checkpoints) do
           if i2+1==v.number+1 then
            local x,y,z = GetVehicleLocation(veh)
            if z>0 then
            if GetDistance2D(x, y, races[racesnumbers[currace]][i2+1][1], races[racesnumbers[currace]][i2+1][2])<750 then
               v.number=i2+1
               CallRemoteEvent(v.ply,"hidecheckpoint",vc)
               local place = 0
 
               if i2 == #checkpoints then
                  table.insert(finishclassement,v.ply)
                  place = #finishclassement
                  table.remove(playerscheckpoints,i)
                  if #playerscheckpoints>0 then
                           SetPlayerPropertyValue(v.ply,"leavingtospec",true,false)
                           RemovePlayerFromVehicle(v.ply)
                  end
                  checktorestart()
               else
                  place = #finishclassement+1
                  for iclass,vclass in ipairs(playerscheckpoints) do
                     if v.ply ~= vclass.ply then
                        if vclass.number >= v.number then
                           place=place+1
                        end
                     end
                  end
               end
               CallRemoteEvent(v.ply,"classement_update",place,GetPlayerCount())
               
            end
         else
            AddPlayerChat(v.ply,"Reseting your car")
            v.number = 1
            SetPlayerHealth(v.ply, 0)
            CallRemoteEvent(v.ply,"reset_checkpoints")
         end
           end
        end
      end
   end
      end
end

AddEvent("OnPackageStart",function()
   CreateTimer(timercheck, 35)
   if dev then
      print("DEV MODE ACTIVATED FOR " .. GetPackageName())
   end
end)

AddRemoteEvent("returncar_racing",function(ply)
   local veh = GetPlayerVehicle(ply)
   local rx,ry,rz = GetVehicleRotation(veh)
   SetVehicleRotation(veh, 0,ry,0)
   SetVehicleLinearVelocity(veh, 0, 0, 0 ,true)
   SetVehicleAngularVelocity(veh, 0, 0, 0 ,true)
end)

AddCommand("race",function(ply,id)
    if dev then
        if id ~= nil then
           currace=tonumber(id)
           playerscheckpoints={}
           changerace()
        end
    end
end)

AddRemoteEvent("changespec",function(ply,spectated)
   if #playerscheckpoints>0 then
      local lookindex = false
      local found = false
    for i,v in ipairs(playerscheckpoints) do
      if lookindex then
        speclogic(ply,v.ply)
        break
      end
       if v.ply==spectated then
         found = true
          if i==#playerscheckpoints then
            for i,v in ipairs(playerscheckpoints) do
               speclogic(ply,playerscheckpoints[i].ply)
               break
            end
          else
               lookindex=true
          end
       end
    end
    if not found then
      for i,v in ipairs(playerscheckpoints) do
         speclogic(ply,playerscheckpoints[i].ply)
         break
      end
    end
    
   end
end)

function speclogic(cmdply,ply)
   print(cmdply,ply)
       AddPlayerChat(cmdply,"You are spectating " .. GetPlayerName(ply))
       local x, y, z = GetPlayerLocation(ply)
       CallRemoteEvent(cmdply,"SpecRemoteEvent",true,ply,x,y,z)
end

AddRemoteEvent("last_checkpoint",function(ply)
     for i,v in ipairs(playerscheckpoints) do
         if v.ply == ply then
            if v.number == 1 then
               SetPlayerHealth(ply,0)
            else 
               local veh = GetPlayerVehicle(ply)
               local rx,ry,rz = GetVehicleRotation(veh)
               SetVehicleRotation(veh, 0,ry,0)
               SetVehicleLinearVelocity(veh, 0, 0, 0 ,true)
               SetVehicleAngularVelocity(veh, 0, 0, 0 ,true)
               SetVehicleLocation(veh,races[racesnumbers[currace]][v.number][1], races[racesnumbers[currace]][v.number][2], races[racesnumbers[currace]][v.number][3] + 200)
            end
         end
     end
end)

AddCommand("showspawns",function(ply)
   if dev then
    for i,v in ipairs(spawns[racesnumbers[currace]]) do
        if i > 1 then
         CreateObject(1363, v[1], v[2], v[3] , 0, spawns[racesnumbers[currace]][1], 0, 1, 1, 1)
        end
    end
   end
end)
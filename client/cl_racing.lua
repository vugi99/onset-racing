local checkpoints = nil

local compteur_state = nil
local compteur_time = nil

local waypoint = nil

local place = nil
local plycount = nil

local curindex = 1

local time_until_restart = nil

AddEvent("OnRenderHUD",function()
    local veh = GetPlayerVehicle(GetPlayerId())
    if veh~=0 then
        local x,y,z = GetVehicleLocation(veh)
        local ScreenX, ScreenY = GetScreenSize()
        DrawText(ScreenX-75,ScreenY-25,"Speed : " .. math.floor(GetVehicleForwardSpeed(veh)+0.5))
    end
    DrawText(0,400,"R = return your car")
    if (compteur_time~=nil ) then
        DrawText(0,425,"Time : " .. compteur_time .. " ms")
     end
    if (place~=nil and plycount~=nil ) then
       DrawText(0,450,"Position : " .. place .. "/" .. plycount)
    end
    if time_until_restart then
        DrawText(0,500,"Changing race in " .. tostring(time_until_restart) .. " ms")
    end
end)

function disablecollisions()
   for i,v in ipairs(GetStreamedObjects(false)) do
    GetObjectActor(v):SetActorEnableCollision(false)
   end
end

function update_compteur()
   if (compteur_time and compteur_state) then
      compteur_time=compteur_time+100
   end
end

AddEvent("OnPackageStart",function()
    CreateTimer(disablecollisions, 250)
    CreateTimer(update_compteur, 100)
end)

AddRemoteEvent("hidecheckpoint",function(id)
    GetObjectActor(id):SetActorHiddenInGame(true)
    curindex=curindex+1
    DestroyWaypoint(waypoint)
    if checkpoints[curindex] then
        if curindex==#checkpoints then
            waypoint=CreateWaypoint(checkpoints[curindex][1], checkpoints[curindex][2], checkpoints[curindex][3], "Finish Line")
        elseif curindex==#checkpoints+1 then
            compteur_state=false
        elseif curindex<#checkpoints then
          waypoint=CreateWaypoint(checkpoints[curindex][1], checkpoints[curindex][2], checkpoints[curindex][3], "Checkpoint " .. curindex)
        end
    end
end)

AddRemoteEvent("classement_update",function(placer,playercountr)
    place=placer
    plycount=playercountr
end)

AddRemoteEvent("checkpointstbl",function(tbl)
    checkpoints=tbl
    curindex = 1
    compteur_time=-500
    compteur_state=true
    if waypoint==nil then
       waypoint=CreateWaypoint(tbl[curindex][1], tbl[curindex][2], tbl[curindex][3], "Checkpoint " .. curindex)
    else
        DestroyWaypoint(waypoint)
        waypoint=CreateWaypoint(tbl[curindex][1], tbl[curindex][2], tbl[curindex][3], "Checkpoint " .. curindex)
    end
end)

AddEvent("OnKeyPress",function(key)
    local veh = GetPlayerVehicle(GetPlayerId()) 
    if veh~=0 then
         if key == "R" then
            CallRemoteEvent("returncar_racing")
         end
    end
end)

local showed_timer = nil

function update_time()
    if time_until_restart-50 > 0 then
       time_until_restart=time_until_restart-50
   else
       if showed_timer then
          DestroyTimer(showed_timer)
          showed_timer=nil
       end
       time_until_restart=nil
    end
end

AddRemoteEvent("Start_finish_timer", function(time_ms,isdestroy)
    if isdestroy then
        if showed_timer then
            DestroyTimer(showed_timer)
            showed_timer=nil
         end
         time_until_restart=nil
    else
       time_until_restart=time_ms
       showed_timer = CreateTimer(update_time,50)
    end
end) 


function setClothe(player, clothId) -- https://github.com/DKFN/ogk_gg/
	SetPlayerClothingPreset(player, clothId)
end
AddRemoteEvent("setClothe", setClothe) 

AddEvent("OnPlayerStreamIn", function(player, otherplayer)
    CallRemoteEvent("Askclothes", player, otherplayer)
end)


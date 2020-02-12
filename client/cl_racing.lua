
LoadPak("finishlinerouge", "/finishlinerouge/", "../../../OnsetModding/Plugins/finishlinerouge/Content")
LoadPak("finishlinevert", "/finishlinevert/", "../../../OnsetModding/Plugins/finishlinevert/Content")

local curstartlinemodel = nil



local checkpoints = nil

local compteur_state = nil
local compteur_time = nil

local waypoint = nil

local place = nil
local plycount = nil

local decompte = nil
local decompte_s = nil

local curindex = 1

local time_until_restart = nil

local afk_timer = nil
local afk_posx = nil
local afk_posy = nil

AddEvent("OnRenderHUD",function()
    local veh = GetPlayerVehicle(GetPlayerId())
    if veh~=0 then
        local x,y,z = GetVehicleLocation(veh)
        local ScreenX, ScreenY = GetScreenSize()
        DrawText(ScreenX-75,ScreenY-25,"Speed : " .. math.floor(GetVehicleForwardSpeed(veh)+0.5))
    end
    DrawText(0,375,"Ping " .. GetPing())
    if GetPlayerVehicle(GetPlayerId()) ~= 0 then
        DrawText(0,400,"R = return your car")
        DrawText(0,525,"C = last checkpoint")
    end
    if (compteur_time~=nil ) then
        DrawText(0,425,"Time : " .. compteur_time .. " ms")
     end
    if (place~=nil and plycount~=nil ) then
       DrawText(0,450,"Position : " .. place .. "/" .. plycount)
    end
    if time_until_restart then
        DrawText(0,500,"Changing race in " .. tostring(time_until_restart) .. " ms")
    end
    if decompte_s~=nil then
        DrawText(0,475,"Starting in " .. tostring(decompte_s) .. " s")
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
        if curindex+1==#checkpoints then
            local csound = CreateSound("sounds/checkpoint.mp3")
            SetSoundVolume(csound, 0.6)
            waypoint=CreateWaypoint(checkpoints[curindex+1][1], checkpoints[curindex+1][2], checkpoints[curindex+1][3], "Finish Line")
        elseif curindex+1==#checkpoints+1 then
            compteur_state=false
            CreateSound("sounds/race_end.mp3")
            if afk_timer then
              DestroyTimer(afk_timer)
              afk_timer=nil
            end
        elseif curindex+1<#checkpoints then
            local csound = CreateSound("sounds/checkpoint.mp3")
            SetSoundVolume(csound, 0.6)
          waypoint=CreateWaypoint(checkpoints[curindex+1][1], checkpoints[curindex+1][2], checkpoints[curindex+1][3], "Checkpoint " .. curindex)
        end
end)

AddRemoteEvent("classement_update",function(placer,playercountr)
    place=placer
    plycount=playercountr
end)

function createstart(modelpath)
   if curstartlinemodel ~= nil then
       curstartlinemodel:Destroy()
       curstartlinemodel = nil
   end
   curstartlinemodel = GetWorld():SpawnActor(AStaticMeshActor.Class(), FVector(checkpoints[1][1], checkpoints[1][2], checkpoints[1][3]), FRotator(0, checkpoints[1][4], 0))
   curstartlinemodel:GetStaticMeshComponent():SetMobility(EComponentMobility.Movable)
   curstartlinemodel:GetStaticMeshComponent():SetStaticMesh(UStaticMesh.LoadFromAsset(modelpath))
   curstartlinemodel:SetActorScale3D(FVector(1, 1, 1))
   curstartlinemodel:GetStaticMeshComponent():SetMobility(EComponentMobility.Static)
   curstartlinemodel:GetStaticMeshComponent():SetCollisionEnabled(ECollisionEnabled.NoCollision)
end

function decompte_update()
   if decompte_s-1 > 0 then
        decompte_s=decompte_s-1
        if decompte_s == 3 then
            local sound = CreateSound("sounds/race_start.mp3")
            SetSoundVolume(sound, 0.5)
        elseif decompte_s == 2 then
            local sound = CreateSound("sounds/race_start.mp3")
            SetSoundVolume(sound, 0.75)
        elseif decompte_s == 1 then
            local sound = CreateSound("sounds/race_start.mp3")
            SetSoundVolume(sound, 1)
        end
        CallEvent("GUI:NotifyCountValue", decompte_s)
   else
    local sound = CreateSound("sounds/race_start.mp3")
    SetSoundVolume(sound, 1.5)
    SetIgnoreMoveInput(false)
    decompte_s=nil
    DestroyTimer(decompte)
    decompte=nil
    compteur_time=0
    compteur_state=true
    createstart("/finishlinevert/finishlinesignvert")
    CallEvent("GUI:NotifyCountValue", -1)
   end
end

AddRemoteEvent("checkpointstbl",function(tbl,temps)
    checkpoints=tbl
    curindex = 1
    decompte_s = temps
    SetIgnoreMoveInput(true)
    decompte = CreateTimer(decompte_update,temps*1000/temps)
    createstart("/finishlinerouge/finishlinesignrouge")
    if afk_timer then
        DestroyTimer(afk_timer)
        afk_timer=nil
      end
    if waypoint==nil then
       waypoint=CreateWaypoint(tbl[curindex+1][1], tbl[curindex+1][2], tbl[curindex+1][3], "Checkpoint " .. curindex)
    else
        DestroyWaypoint(waypoint)
        waypoint=CreateWaypoint(tbl[curindex+1][1], tbl[curindex+1][2], tbl[curindex+1][3], "Checkpoint " .. curindex)
    end
end)

AddEvent("OnKeyPress",function(key)
    local veh = GetPlayerVehicle(GetPlayerId()) 
    if veh~=0 then
         if key == "R" then
            CallRemoteEvent("returncar_racing")
         end
         if key == "C" then
            CallRemoteEvent("last_checkpoint")
         end
    end
end)

local showed_timer = nil

function update_time()
    if time_until_restart-100 > 0 then
       time_until_restart=time_until_restart-100
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
       showed_timer = CreateTimer(update_time,100)
    end
end) 

AddRemoteEvent("reset_checkpoints",function()
    curindex = 1
    if waypoint==nil then
        waypoint=CreateWaypoint(checkpoints[curindex+1][1], checkpoints[curindex+1][2], checkpoints[curindex+1][3], "Checkpoint " .. curindex)
     else
         DestroyWaypoint(waypoint)
         waypoint=CreateWaypoint(checkpoints[curindex+1][1], checkpoints[curindex+1][2], checkpoints[curindex+1][3], "Checkpoint " .. curindex)
     end
end)

function check_afk()
   local x,y,z = GetPlayerLocation(GetPlayerId())
   if (x~=afk_posx or y ~= afk_posy) then
      afk_posx=x
      afk_posy=y
   else
    CallRemoteEvent("imafk")
   end
end

AddRemoteEvent("startlookingforafk",function()
    local x,y,z = GetPlayerLocation(GetPlayerId())
    afk_posx=x
    afk_posy=y
    local afk_timer = CreateTimer(check_afk,120000)
end)


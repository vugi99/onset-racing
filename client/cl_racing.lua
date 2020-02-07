local checkpoints = nil

local waypoint = nil

local curindex = 1

AddEvent("OnRenderHUD",function()
    local veh = GetPlayerVehicle(GetPlayerId())
    if veh~=0 then
        local x,y,z = GetVehicleLocation(veh)
        local ScreenX, ScreenY = GetScreenSize()
        DrawText(ScreenX-75,ScreenY-25,"Speed : " .. math.floor(GetVehicleForwardSpeed(veh)+0.5))
    end
end)

function disablecollisions()
   for i,v in ipairs(GetStreamedObjects(false)) do
    GetObjectActor(v):SetActorEnableCollision(false)
   end
end
AddEvent("OnPackageStart",function()
    CreateTimer(disablecollisions, 250)
end)

AddRemoteEvent("hidecheckpoint",function(id)
    GetObjectActor(id):SetActorHiddenInGame(true)
    curindex=curindex+1
    DestroyWaypoint(waypoint)
    if checkpoints[curindex] then
        if curindex==#checkpoints then
            waypoint=CreateWaypoint(checkpoints[curindex][1], checkpoints[curindex][2], checkpoints[curindex][3], "Finish Line")
        else
          waypoint=CreateWaypoint(checkpoints[curindex][1], checkpoints[curindex][2], checkpoints[curindex][3], "Checkpoint " .. curindex)
        end
    end
end)

AddRemoteEvent("checkpointstbl",function(tbl)
    checkpoints=tbl
    curindex = 1
    if waypoint==nil then
       waypoint=CreateWaypoint(tbl[curindex][1], tbl[curindex][2], tbl[curindex][3], "Checkpoint " .. curindex)
    else
        DestroyWaypoint(waypoint)
        waypoint=CreateWaypoint(tbl[curindex][1], tbl[curindex][2], tbl[curindex][3], "Checkpoint " .. curindex)
    end
end)
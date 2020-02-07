local checkpoints = nil

local waypoint = nil

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
     waypoint=CreateWaypoint(checkpoints[curindex][1], checkpoints[curindex][2], checkpoints[curindex][3], "Checkpoint " .. curindex-1)
    end
end)

AddRemoteEvent("checkpointstbl",function(tbl)
    checkpoints=tbl
    curindex = 2
    if waypoint==nil then
       waypoint=CreateWaypoint(tbl[2][1], tbl[2][2], tbl[2][3], "Checkpoint " .. curindex-1)
    else
        DestroyWaypoint(waypoint)
        waypoint=CreateWaypoint(tbl[2][1], tbl[2][2], tbl[2][3], "Checkpoint " .. curindex-1)
    end
end)
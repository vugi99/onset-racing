local raceeditorstate = false
local newstate = false

local spawncheck = false
local checkpointcheck = false
local firstcheck = false
local finishcheck = false

local spawnstable = {}

local racetable = {}

local checkpointsobjects = {}

function starteditor(ply,raceid)
    SetPlayerSpectate(ply, true)
   raceeditorstate=true
   if raceid~="new" then
    local mapname = racesnumbers[raceid]
      spawnstable=spawns[mapname]
      racetable=races[mapname]
      for i,v in ipairs(races[mapname]) do
        if i+1 == #races[mapname] then
           local obj = CreateObject(52, races[mapname][i+1][1], races[mapname][i+1][2], races[mapname][i+1][3] , 0, races[mapname][i+1][4], 0, 1, 1, 1)
         table.insert(checkpointsobjects,obj)
        else
           if races[mapname][i+1] then
        local obj = CreateObject(336, races[mapname][i+1][1], races[mapname][i+1][2], races[mapname][i+1][3] , 0, 0, 0, 10, 10, 10)
         table.insert(checkpointsobjects,obj)
           end
        end
    end
   else
       newstate=true
   end

end

function stopeditor(ply)

end

AddCommand("saverace",function(ply)
    if (raceeditorstate and spawncheck and checkpointcheck and finishcheck and finishcheck) then
       stopeditor(ply)
    end
end)

AddEvent("OnPlayerJoin",function(ply)
    if raceeditorstate then
        KickPlayer(ply, "Race editor loaded  , you can't join")
    end
end)

AddEvent("OnPlayerQuit",function(ply)
    raceeditorstate=false
    newstate=false
end)

local remove_objs_cons = true 

local objs = {}

objs[1] = 53
objs[2] = 336
objs[3] = 52


local admins_remove = {}

local constructed = {}

local shadows = {}

function rshadow(ply)
    if (shadows[ply]) then
        DestroyObject(shadows[ply].mapobjid)
        table.remove(shadows, ply)
    end
 end

 AddRemoteEvent("RemoveShadow",rshadow)

function OnPlayerQuit(ply)
    rshadow(ply)
    if (remove_objs_cons == true) then
        local steamid = tostring(GetPlayerSteamId(ply))

        local index = 1 -- DjCtavia#3870

        while index < #constructed + 1 do
            if (constructed[index].owner == steamid) then
                DestroyObject(constructed[index].mapobjid)
                table.remove(constructed, index)
                index = index - 1
            end
            index = index + 1
        end
        for k,v in ipairs(GetAllPlayers()) do
            CallRemoteEvent(v, "Constructed_sync", constructed)
        end
    end
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function Createobj(ply,x,y,z,rotx,roty)
    if (shadows[ply]) then
        local objtocreate = shadows[ply].mapobjid
        SetObjectLocation(objtocreate,x,y,z)
        SetObjectRotation(objtocreate,rotx,roty,0)
        local tbltoinsert = {}
        tbltoinsert.mapobjid = shadows[ply].mapobjid
        tbltoinsert.objid = shadows[ply].objid
        tbltoinsert.owner = tostring(GetPlayerSteamId(ply))
        table.insert(constructed,tbltoinsert)
        CallRemoteEvent(ply, "Createdobj", shadows[ply].mapobjid, true)
        for k,v in ipairs(GetAllPlayers()) do
            CallRemoteEvent(v, "Constructed_sync", constructed)
        end
        table.remove(shadows, ply)
    end
end

AddRemoteEvent("Createcons", Createobj)

function OnPlayerSpawn(ply)
    CallRemoteEvent(ply, "numberof_objects", #objs)
    CallRemoteEvent(ply,"objs_table_cons",objs)
end
AddEvent("OnPlayerSpawn", OnPlayerSpawn)

function Removeobj(ply,hitentity)
    local steamid = tostring(GetPlayerSteamId(ply))
    for i,v in ipairs(constructed) do
        if (hitentity==v.mapobjid) then
            if (v.owner == steamid or admins_remove[steamid]) then
                DestroyObject(hitentity)
                table.remove(constructed,i)
                for k,v in ipairs(GetAllPlayers()) do
                    CallRemoteEvent(v, "Constructed_sync", constructed)
                end
            else
                AddPlayerChat(ply,"You can't remove this object")
            end
        end
    end
end
AddRemoteEvent("Removeobj", Removeobj)

function CreateShadow(ply,conid,angle,x,y,z)
    if shadows[ply] then
        DestroyObject(shadows[ply].mapobjid)
        table.remove(shadows,ply)
    end
    local anglex = 0
    local size = 1
    if conid == 2 then
       size = 10
    end
    local identifier = CreateObject(objs[conid], x, y, -1000 , anglex, angle, 0, size, size, size)
    if (identifier~=false) then
        shadows[ply] = {}
        shadows[ply].objid = conid
        shadows[ply].mapobjid = identifier
        CallRemoteEvent(ply,"created_shadow_tbl",shadows[ply])
        --[[for k,v in ipairs(GetAllPlayers()) do
           CallRemoteEvent(v,"Createdobj",identifier,false)
        end]]--
    else
        print("Error at CreateObject Construction mod")
    end
end
AddRemoteEvent("CreateShadow",CreateShadow)

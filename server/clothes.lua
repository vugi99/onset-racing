local playersclothes = {}

-- modified from https://github.com/DKFN/ogk_gg/
function OnPlayerSpawncloth(playerid)
    playersclothes[playerid] = {}
    playersclothes[playerid].cloth = 15
    for _, v in ipairs(GetAllPlayers()) do 
        CallRemoteEvent(v, "setClothe", playerid, playersclothes[playerid].cloth) 
        if playersclothes[v] then
        CallRemoteEvent(playerid, "setClothe", v, playersclothes[v].cloth) 
        end
    end
 end
 AddEvent("OnPlayerSpawn", OnPlayerSpawncloth)
 
 local function SendPlayerSkin(requesterId, playerId)
    if playersclothes[playerId] and playersclothes[playerId].cloth then
        CallRemoteEvent(requesterId, "setClothe", playerId, playersclothes[playerId].cloth)
    else
        Delay(2000, function() 
            SendPlayerSkin(requesterId, playerId)
        end)
    end
 end
 AddRemoteEvent("Askclothes", SendPlayerSkin)

AddEvent("OnPlayerQuit",function(ply)
    table.remove(playersclothes,ply)
end)
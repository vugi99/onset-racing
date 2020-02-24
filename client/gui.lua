local gui
AddEvent("OnPackageStart", function()
    gui = CreateWebUI(0.0, 0.0, 0.0, 0.0, 5, 24)
	LoadWebFile(gui, "http://asset/racing/gui/build/index.html")
	SetWebAlignment(gui, 0.0, 0.0)
	SetWebAnchors(gui, 0.0, 0.0, 1.0, 1.0)
    SetWebVisibility(gui, WEB_HITINVISIBLE)
end)

AddEvent("OnWebLoadComplete", function(web)
    if web == gui then
    end
end)

-- Timers 
CreateTimer(function()
    local playerId = GetPlayerId()
    if gui and IsPlayerInVehicle(playerId) then
        local veh = GetPlayerVehicle(playerId)
        local plySpeed = math.floor(GetVehicleForwardSpeed(veh)+0.5)
        ExecuteWebJS(gui, 'NotifySpeed("'..plySpeed..'")')
    end
end, 20)

AddEvent("GUI:NotifyCountValue", function(counterValue)
    ExecuteWebJS(gui, "NotifyDecompte('"..counterValue.."')")
end)

AddEvent("GUI:SetRaceTime", function(compteur_time)
    if gui then
        ExecuteWebJS(gui, "NotifyTime('"..compteur_time.."')")
    end
end)

AddEvent("GUI:PlayerFinished", function(compteur_time, position)
    if gui then
        ExecuteWebJS(gui, "PlayerFinished('"..json.stringify({ time = compteur_time, place = position}).."')")
        Delay(10000, function()
            ExecuteWebJS(gui, "ClearFinishTime()")
        end)
    end
end)

local lastnb = -1

AddEvent("GUI:PlayerPassedCheckpoint", function(compteur_time, nb)
    if gui then
        lastnb = nb
        ExecuteWebJS(gui, "PlayerPassedCheckpoint('"..json.stringify({time = compteur_time, nb = nb}).."')")
        Delay(2000, function()
            if lastnb == nb then
               ExecuteWebJS(gui, "HideCheckPoint('"..compteur_time.."')")
            end
        end)
    end
end)

AddEvent("GUI:UpdatePlayerPosition", function(playerPos, playerCount)
    if gui then
        ExecuteWebJS(gui, "NotifyPosition('"..json.stringify({pos = playerPos, total = playerCount}).."')")
    end
end)
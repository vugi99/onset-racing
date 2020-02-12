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


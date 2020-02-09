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
        -- Cal remote event for server data hydration
        AddPlayerChat("TEST")
    end
end)

-- Timers 
CreateTimer(function()
    if gui then
        local veh = GetPlayerVehicle(GetPlayerId())
        local plySpeed = math.floor(GetVehicleForwardSpeed(veh)+0.5)
        ExecuteWebJS(gui, 'NotifySpeed("'..plySpeed..'")')
    end
end, 20)


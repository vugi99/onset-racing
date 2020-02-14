local editorstate = false

AddRemoteEvent("editorenable",function()
    editorstate = true
end)

local curstruct = 1
local currotyaw = 0
local remove_obj = false

local creatingshadow = false

local numb_of_objs = 0

local objs = {}

local shadow = nil

local constructed = {}

function OnKeyPress(key)
    if creatingshadow == false then
    if key == "E" then
        if (editorstate == true) then
            remove_obj = not remove_obj
            if remove_obj then
                CallRemoteEvent("RemoveShadow")
                shadow=nil
            end
        end
    end
    if key == "Mouse Wheel Up" then
		curstruct = curstruct + 1
        curstruct = ((curstruct - 1) % numb_of_objs) + 1
    end
    if key == "Mouse Wheel Down" then
		curstruct = curstruct + 1
		curstruct = (curstruct % numb_of_objs) + 1
    end
    if key == "R" then
        if (currotyaw + 90 > 180) then
            currotyaw = -90
        else
            currotyaw = currotyaw + 90
        end
    end
    if key == "Left Mouse Button" then
        if editorstate then
            if (remove_obj==false) then
                local rotx , roty , rotz = GetObjectRotation(shadow.mapobjid)
                local ox, oy, oz = GetObjectLocation(shadow.mapobjid)
                CallRemoteEvent("Createcons",ox,oy,oz,rotx,roty)
                shadow=nil
            else
                local ScreenX, ScreenY = GetScreenSize()
                SetMouseLocation(ScreenX/2, ScreenY/2)
                local entityType, entityId = GetMouseHitEntity()
                local x,y,z = GetMouseHitLocation()
            if entityType==2 then
                local cx, cy, cz = GetCameraForwardVector()
                local ltx = x+cx*65
                local lty = y+cy*65
                local ltz = z+cz*65
                local eltx = x+cx*65+cx*10000
                local elty = y+cy*65+cy*10000
                local eltz = z+cz*65+cz*10000
                local hittype, hitid, impactX, impactY, impactZ = LineTrace(ltx,lty,ltz,eltx,elty,eltz,4)
                    entityType=hittype
                    entityId=hitid
            end
                if (entityId~=0) then
                	CallRemoteEvent("Removeobj",entityId)
                end
            end
        end
    end
end
end
AddEvent("OnKeyPress", OnKeyPress)
local lasthitposx = nil
local lasthitposy = nil
local lasthitposz = nil
local lastang = nil

local lastcons = nil

local lastconsactivated = nil

function tickhook(DeltaSeconds)
    if creatingshadow==false then
    if editorstate then
		local ScreenX, ScreenY = GetScreenSize()
		SetMouseLocation(ScreenX/2, ScreenY/2)
		if remove_obj == false then
		lastconsactivated = true
        local x,y,z = GetMouseHitLocation()
        local entityType, entityId = GetMouseHitEntity()
			if (x ~= lasthitposx or y ~= lasthitposy or z ~= lasthitposz or lastang ~= currotyaw or lastconsactivated ~= editorstate or lastcons ~= curstruct) then
				lasthitposx = x
				lasthitposy = y
				lasthitposz = z
				lastang = currotyaw
				lastcons = curstruct
				lastconsactivated = true
                if (x ~= 0 and y ~= 0 and z ~= 0) then
                    local pitch,yaw,roll = GetCameraRotation()
                    if shadow==nil then
                    creatingshadow=true
                    CallRemoteEvent("CreateShadow", curstruct, currotyaw,x,y,z)
                    end
                    if shadow~=nil then
                        local conid = curstruct
                        local angle = currotyaw
                        local hitentity = entityId
                        if (shadow.objid==conid) then
                            local px, py, pz = GetCameraLocation(true)
                            local dist = GetDistance3D(px, py, pz, x, y, z)
                            if (dist<10000) then
                                --AddPlayerChat("X2 : " .. x .. " Y2 : " .. y .. " Z2 : " .. z .. " Angle2 : " .. angle)
                                GetObjectActor(shadow.mapobjid):SetActorLocation(FVector(x, y, z))
                                local anglex = 0
                                GetObjectActor(shadow.mapobjid):SetActorRotation(FRotator(anglex, angle, 0))
                            else
                                AddPlayerChat("Too far from you")
                            end
                        else
                            CallRemoteEvent("CreateShadow", curstruct, currotyaw,x,y,z)
                            creatingshadow=true
                        end
                    end
                else
					AddPlayerChat("Please look at valid locations")
                    end
				end
            end
        end
	else
        lastconsactivated=false
    end
end
AddEvent("OnGameTick", tickhook)

local rtim = nil

function retry_timer()
    if IsValidObject(shadow.mapobjid) then
	    GetObjectActor(shadow.mapobjid):SetActorEnableCollision(false)
	    SetObjectCastShadow(shadow.mapobjid, false)
        EnableObjectHitEvents(shadow.mapobjid , false)
        GetObjectStaticMeshComponent(shadow.mapobjid):SetMobility(EComponentMobility.Movable)
        creatingshadow=false
        SetObjectOutline(shadow.mapobjid,true)
        DestroyTimer(rtim)
    end
end

AddRemoteEvent("Createdobj", function(objid, collision)
    local delay = 50
    if (GetPing() ~= 0) then
        delay = GetPing() * 6
    end
    Delay(delay,function()
	    GetObjectActor(objid):SetActorEnableCollision(collision)
	    SetObjectCastShadow(objid, collision)
        EnableObjectHitEvents(objid , collision)
        if collision == true then
            GetObjectStaticMeshComponent(objid):SetMobility(EComponentMobility.Static)
            SetObjectOutline(objid,false)
        else
            GetObjectStaticMeshComponent(objid):SetMobility(EComponentMobility.Movable)
        end
    end)
end)

AddRemoteEvent("numberof_objects", function(number)
    numb_of_objs = number
end)

function render_cons()
    if editorstate then
	    DrawText(5, 425, "Press E to toggle remove")
	    DrawText(5, 450, "Press R to rotate")
	    DrawText(5, 475, "Use the mouse wheel to change your object")
        DrawText(5, 500, "Use the left click to place your object")
        DrawText(5, 575, "DON'T FORGET TO DO /saverace")
	    if remove_obj then
            local entityType, entityId = GetMouseHitEntity()
            local x,y,z = GetMouseHitLocation()
            if (entityId ~= 0) then
                local x, y, z = GetObjectLocation(entityId)
                local bResult, ScreenX, ScreenY = WorldToScreen(x, y, z)
                if bResult then
                    DrawText(ScreenX - 40, ScreenY, "Left Click to remove")
                end
            end
    	end
    end
end
AddEvent("OnRenderHUD", render_cons)



AddRemoteEvent("objs_table_cons",function(tbl)
    objs = tbl
end)

AddRemoteEvent("created_shadow_tbl",function(tbl_obj)
    shadow=tbl_obj
    local delay = 50
    if (GetPing() ~= 0) then
        delay = GetPing() * 6
    end
    Delay(delay,function()
        if IsValidObject(shadow.mapobjid) then
	    GetObjectActor(shadow.mapobjid):SetActorEnableCollision(false)
	    SetObjectCastShadow(shadow.mapobjid, false)
        EnableObjectHitEvents(shadow.mapobjid , false)
        GetObjectStaticMeshComponent(shadow.mapobjid):SetMobility(EComponentMobility.Movable)
        SetObjectOutline(shadow.mapobjid,true)
        creatingshadow=false
        else
            rtim = CreateTimer(retry_timer, 100)
    end
    end)
end)

AddRemoteEvent("Constructed_sync",function(constr_tbl)
    constructed=constr_tbl
end)


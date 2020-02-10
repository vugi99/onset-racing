function OnPackageStart()
	local pakname = "finishline"
	local res = LoadPak(pakname, "/finishline/", "../../../OnsetModding/Plugins/finishline/Content")


	res = ReplaceObjectModelMesh(52, "/finishline/finishlinesign")
	
    local pakname = "finishlinerouge"
	local res = LoadPak(pakname, "/finishlinerouge/", "../../../OnsetModding/Plugins/finishlinerouge/Content")


	res = ReplaceObjectModelMesh(51, "/finishlinerouge/finishlinesignrouge")
	local pakname = "finishlinevert"
	local res = LoadPak(pakname, "/finishlinevert/", "../../../OnsetModding/Plugins/finishlinevert/Content")


	res = ReplaceObjectModelMesh(50, "/finishlinevert/finishlinesignvert")

end
AddEvent("OnPackageStart", OnPackageStart)
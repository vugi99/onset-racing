function OnPackageStart()
	local pakname = "finishline"
	local res = LoadPak(pakname, "/finishline/", "../../../OnsetModding/Plugins/finishline/Content")


	res = ReplaceObjectModelMesh(52, "/finishline/finishlinesign")

	local pakname = "finishlinerouge"
	local res = LoadPak(pakname, "/finishlinerouge/", "../../../OnsetModding/Plugins/finishlinerouge/Content")


	res = ReplaceObjectModelMesh(53, "/finishlinerouge/finishlinesignrouge")

end
AddEvent("OnPackageStart", OnPackageStart)
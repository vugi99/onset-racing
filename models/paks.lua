function OnPackageStart()
	local pakname = "finishline"
	local res = LoadPak(pakname, "/finishline/", "../../../OnsetModding/Plugins/finishline/Content")


	res = ReplaceObjectModelMesh(52, "/finishline/finishlinesign")

end
AddEvent("OnPackageStart", OnPackageStart)
-- https://github.com/DKFN/ogk_gg/
function setClothe(player, clothId)
	SetPlayerClothingPreset(player, clothId)
end
AddRemoteEvent("setClothe", setClothe) 

AddEvent("OnPlayerStreamIn", function(player, otherplayer)
    CallRemoteEvent("Askclothes", player, otherplayer)
end)
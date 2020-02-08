local spectable = {}

function speclogic(cmdply,ply)
    for i,v in ipairs(spectable) do
        if v.id == cmdply then
         table.remove(spectable,i)
        end
     end
     local x, y, z = GetPlayerLocation(cmdply)
        tblspecin = {}
        tblspecin.id = cmdply
        tblspecin.specid = ply
        table.insert(spectable,tblspecin)
        AddPlayerChat(cmdply,"You are spectating " .. GetPlayerName(ply))
        local x, y, z = GetPlayerLocation(ply)
        CallRemoteEvent(cmdply,"SpecRemoteEvent",true,ply)
end

AddEvent("OnPlayerQuit",function(ply)
    for i,v in ipairs(spectable) do
       if v.id == ply then
        table.remove(spectable,i)
       end
    end
end)

AddRemoteEvent("NoLongerSpectating",function(ply)
    for i,v in ipairs(spectable) do
        if v.id == ply then
         table.remove(spectable,i)
        end
     end
end)


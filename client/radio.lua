local radio = "https://www.internet-radio.com/servers/tools/playlistgenerator/?u=http://144.217.129.213:8151/listen.pls?sid=1&t=.pls"

local radiostate = false

local sound = nil

AddEvent("OnKeyPress",function(key)
    if key == "Y" then
       radiostate=not radiostate
       if radiostate then
        sound = CreateSound(radio)
        SetSoundVolume(sound, 0.4)
       else
          if sound then
            DestroySound(sound)
            sound=nil
          end
       end
    end
end)

AddEvent("OnRenderHUD",function()
    DrawText(0,550,"Y = toggle radio")
end)

local zombieQuerier    = require("BZM_ClientQueryZombie")
local sharedData       = require("BZM_ClientSharedData")
local BZM_Enums        = require("BZM_Enums")
local BZM_Commands     = require("BZM_Commands")

local function TestReRoll(keynum)
    if keynum == Keyboard.KEY_F9 then

        local thisFrameZombies = zombieQuerier.QueryZombieInCell()
        if thisFrameZombies then
            sendClientCommand(sharedData.GetPlayer(),BZM_Enums.BZM_OnlineModule,BZM_Commands.ReRollZombies,thisFrameZombies)
        end
        
    end
end

Events.OnKeyPressed.Add(TestReRoll)



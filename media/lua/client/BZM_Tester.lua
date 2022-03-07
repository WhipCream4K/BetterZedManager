
local zombieQuerier    = require("BZM_ClientQueryZombie")
local sharedData       = require("BZM_ClientSharedData")
local BZM_Enums        = require("BZM_Enums")
local BZM_Commands     = require("BZM_Commands")
local BZM_Utils        = require("BZM_Utils")

local function TestReRoll(keynum)
    if keynum == Keyboard.KEY_F9 then

        local thisFrameZombies = zombieQuerier.QueryAndUpdateZombieMemo(sharedData.ZombieMemory)
        sendClientCommand(sharedData.GetPlayer(),BZM_Enums.BZM_OnlineModule,BZM_Commands.ReRollZombies,thisFrameZombies)
        
    elseif keynum == Keyboard.KEY_F10 then
        BZM_Utils.DebugPrintWithBanner("Show list of memo",true)
        for key, value in pairs(sharedData.ZombieMemory) do
            BZM_Utils.DebugPrint("Zombie ID: "..key)
            BZM_Utils.DebugPrint("WakeupType: "..tostring(value[BZM_Enums.Memo.WakeupType]))
        end
    end
end

Events.OnKeyPressed.Add(TestReRoll)



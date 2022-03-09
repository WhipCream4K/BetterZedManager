
local zombieManager     = require("BZM_ZombieManager")
local sharedData        = require("BZM_ClientSharedData")
local BZM_Enums         = require("BZM_Enums")
local BZM_Commands      = require("BZM_Commands")
local BZM_Utils         = require("BZM_Utils")

local function TestReRoll(keynum)
    if keynum == Keyboard.KEY_F9 then

        local thisFrameZombies = zombieManager.QueryZombiesAgainstMemory(sharedData.thisPlayerIndex,sharedData.zombieMemory)
        sendClientCommand(sharedData.GetPlayer(),BZM_Enums.OnlineModule,BZM_Commands.ReRollZombies,thisFrameZombies)
        
    elseif keynum == Keyboard.KEY_F10 then
        -- BZM_Utils.DebugPrintWithBanner("Show list of memo",true)
        -- for key, value in pairs(sharedData.zombieMemory:GetTable()) do
        --     BZM_Utils.DebugPrint("Zombie ID: "..key)
        --     BZM_Utils.DebugPrint("WakeupType: "..tostring(value[BZM_Enums.Memo.WakeupType]))
        -- end
        sendClientCommand(sharedData.GetPlayer(),BZM_Enums.OnlineModule,BZM_Commands.TestServerQueryZombies,{})
    end
end

Events.OnKeyPressed.Add(TestReRoll)



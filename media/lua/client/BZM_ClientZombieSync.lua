-- handles zombie syncing during the first frame

local zombieSync    = {}

-- modules stack
local sharedData        = require("BZM_ClientSharedData")
local BZM_Enums         = require("BZM_Enums")
local BZM_Utils         = require("BZM_Utils")

local GetSandboxOptions = getSandboxOptions

zombieSync.UpdateClientZombies = function (serverMemo)

    local zombieInCell = sharedData.GetZombiesInCell()
    local sandboxOptions = GetSandboxOptions()
    local defaultZombieSpeed = sandboxOptions:getOptionByName(BZM_Enums.SandboxLore.ZombieSpeed):getValue()
    local convertZombie = BZM_Utils.FamousZombieTypeUpdate
    local zombieTypeStr = BZM_Enums.Memo.ZombieType
    local wakeupTypeStr = BZM_Enums.Memo.WakeupType
    
    for i = 0, zombieInCell:size() - 1,1 do
        
        local zombie = zombieInCell:get(i)
        local zombieID = zombie:getOnlineID()
        
        local newZombieData = serverMemo[zombieID]
    
        if newZombieData then
    
            local newZombieType = newZombieData[zombieTypeStr] or defaultZombieSpeed
            convertZombie(sandboxOptions,zombie,newZombieType)
    
            -- for fake dead we save the wake up type for later
            local wakeupType = newZombieData[wakeupTypeStr]
    
            if wakeupType then
                local modData = zombie:getModData()
                modData[BZM_Enums.ModDataValue.BZM_Data] = modData[BZM_Enums.ModDataValue.BZM_Data] or {}
                modData[BZM_Enums.ModDataValue.BZM_Data][BZM_Enums.ModDataValue.WakeupType] = wakeupType
            end
            
        end
    
    end
        
    sandboxOptions:set(BZM_Enums.SandboxLore.ZombieSpeed,defaultZombieSpeed)

end

-- Events.OnCreatePlayer.Add(OnCreatePlayer) -- call once after player click screen

return zombieSync
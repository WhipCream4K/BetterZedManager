
local sharedTable = {
    ZombieMemory = {
        -- zombieObj = nil,
        -- wakeupType = nil -- for syncing with fake deads please also remove the data when you done
    },
    -- PlayerObj = nil,
    ThisPlayerIndex = 0,
}

-- modules stack
local BZM_Enums         = require("BZM_Enums")
local BZM_Utils         = require("BZM_Utils")
local BZM_Commands      = require("BZM_Commands")


-- variable stack

-- function stack
local GetSandboxOptions = getSandboxOptions
local SendClientCMD     = sendClientCommand
local GetPlayer         = nil


sharedTable.GetPlayer = function ()
    return GetPlayer(sharedTable.ThisPlayerIndex)
end

sharedTable.GetZombiesInCell = function ()

    local player = GetPlayer(sharedTable.ThisPlayerIndex)
    if not player then
        return nil
    end
    local playerCell = player:getCell()
    if not playerCell then
        return nil
    end
    return playerCell:getZombieList()

end

-- export this function
sharedTable.RevalidateClientMemory = function (findZombieID)
    
    local clientZombieMemo = sharedTable.ZombieMemory
    local zombieTypeKey = BZM_Enums.Memo.ZombieObj

    local zombieList = sharedTable.GetZombiesInCell()
    
    for i = 0, zombieList:size() - 1, 1 do
        
        local zombie = zombieList:get(i)
        local zombieID = zombie:getOnlineID()

        if clientZombieMemo[zombieID] then
            
            clientZombieMemo[zombieID][zombieTypeKey] = zombie
            
        end

    end

    return clientZombieMemo[findZombieID]

end

sharedTable.UpdeadMemoryFirstFrame = function (serverMemo)

    local zombieTypeKey = BZM_Enums.Memo.ZombieType
    local wakeupTypeKey = BZM_Enums.Memo.WakeupType

    local clientZombieMemo = sharedTable.ZombieMemory

    for zombieID, dataTable in pairs(serverMemo) do
        
        BZM_Utils.DebugPrint("Sync zombies from previous player:"..zombieID.." zombieType: "..tostring(dataTable[zombieTypeKey].." wakeupType: "..tostring(dataTable[wakeupTypeKey])))
        
        -- overwrites the old one if needed
        
        local zombieTable = clientZombieMemo[zombieID]

        if not zombieTable then

            clientZombieMemo[zombieID] = {}
            zombieTable = clientZombieMemo[zombieID]
            -- zombieTable[zombieTypeKey] = dataTable[zombieTypeKey]
            -- zombieTable[wakeupTypeKey] = dataTable[wakeupTypeKey]
        end

        zombieTable[zombieTypeKey] = dataTable[zombieTypeKey]
        zombieTable[wakeupTypeKey] = dataTable[wakeupTypeKey]
        
        -- if not zombieTable or not(zombieTable[zombieTypeKey] or zombieTable[wakeupTypeKey]) then
            
        --     -- clientZombieMemo[zombieID] = clientZombieMemo[zombieID] or {}
            
        --     zombieTable[zombieTypeKey] = dataTable[zombieTypeKey]
        --     zombieTable[wakeupTypeKey] = dataTable[wakeupTypeKey]
            
        -- end
        



    end
    
end

-- export this function
sharedTable.UpdateMemoryFromServer = function (serverMemo)
    
    local zombieMemory = sharedTable.ZombieMemory

    BZM_Utils.DebugPrintWithBanner("Updating Zombies",true)
    
    local wakeupTypeStr = BZM_Enums.Memo.WakeupType
    local zombieTypeStr = BZM_Enums.Memo.ZombieType

    -- update data from server
    for zombieID, dataTable in pairs(serverMemo) do

        -- if we don't have data from ourselves that means it comes from other player
        -- we will save that data for later
        if not zombieMemory[zombieID] then
            zombieMemory[zombieID] = {}
            -- if the zombie is a fake dead the we store the wake up type
            zombieMemory[zombieID][wakeupTypeStr] = dataTable[wakeupTypeStr] or nil
            zombieMemory[zombieID][zombieTypeStr] = dataTable[zombieTypeStr] or nil

        end

    end

    local convertZombie = BZM_Utils.FamousZombieTypeUpdate
    -- local zombieTypeStr = BZM_Enums.ModDataValue.ZombieType
    -- local wakeupTypeStr = BZM_Enums.ModDataValue.WakeupType

    -- Update client zombies
    local clientZombieList = sharedTable.GetZombiesInCell()
    local sandboxOptions = GetSandboxOptions()
    local defaultZombieSpeed = sandboxOptions:getOptionByName(BZM_Enums.SandboxLore.ZombieSpeed):getValue()
    
    for i = 0, clientZombieList:size() - 1,1 do
        
        local zombie = clientZombieList:get(i)
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

local function OnAfterEveryThingInit()
    
    -- at the first frame we need to sync all previous zombie memory from the server
    SendClientCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.SyncServerZombiesIndividual,{})
    Events.EveryTenMinutes.Remove(OnAfterEveryThingInit)

end

local function OnCreatePlayer(playerIndex,player)
    -- sharedTable.PlayerObj = player
    -- if not isClient() then
    --     -- is playing solo
    --     sharedTable.ThisPlayerIndex = playerIndex
    --     GetPlayer = getSpecificPlayer
    -- else

    -- end

    sharedTable.ThisPlayerIndex = playerIndex
    GetPlayer = getSpecificPlayer
    BZM_Utils.DebugPrintWithBanner("Current PlayerID: "..sharedTable.ThisPlayerIndex,true)
    
    Events.EveryTenMinutes.Add(OnAfterEveryThingInit)

end


Events.OnCreatePlayer.Add(OnCreatePlayer) -- call once after player click screen


return sharedTable
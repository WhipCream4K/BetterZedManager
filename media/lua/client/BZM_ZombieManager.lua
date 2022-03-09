require("BZM_ZombieMemory")

local zombieManager = {}

-- moudules stack
local BZM_Enums             = require("BZM_Enums")
local BZM_Utils             = require("BZM_Utils")

-- variables stack
local interestZombieStates = {"idle","sitting"}

-- function stack
local GetSandboxOptions     = getSandboxOptions

---Update current client zombie from zombie memory object
---@param oldZombieMemory ZombieMemory
---@param newZombieMemory ZombieMemory
zombieManager.UpdateClientZombies = function (oldZombieMemory,newZombieMemory)

    local currentZombieTable    = oldZombieMemory:GetTable()
    local newZombieTable        = newZombieMemory:GetTable()
    
    local sandboxOptions = GetSandboxOptions()
    local defaultZombieSpeed = sandboxOptions:getOptionByName(BZM_Enums.SandboxLore.ZombieSpeed):getValue()
    local convertZombie = BZM_Utils.FamousZombieTypeUpdate
    local setModData    = BZM_Utils.SetModData
    local zombieTypeKey = BZM_Enums.Memo.ZombieType
    local wakeupTypeKey = BZM_Enums.Memo.WakeupType
    local zombieObjKey  = BZM_Enums.Memo.ZombieObj
    

    for zombieID, data in pairs(currentZombieTable) do
        local zombie = data[zombieObjKey]
        local newZombieData = newZombieTable[zombieID]
        if zombie and newZombieData then
            local newZombieType = newZombieData[zombieTypeKey] or defaultZombieSpeed
            convertZombie(sandboxOptions,zombie,newZombieType)

            -- fake dead
            local wakeupType = newZombieData[wakeupTypeKey]
            if wakeupType then
                local modData = zombie:getModData()
                setModData(modData,BZM_Enums.ModDataValue.WakeupType,wakeupType)
            end
        end
    end

    sandboxOptions:set(BZM_Enums.SandboxLore.ZombieSpeed,defaultZombieSpeed)

end

---Query All zombies in player's cell and delete all duplicate from zombieMemory
---@param playerIndex integer
---@param zombieMemory ZombieMemory
---@return table
zombieManager.QueryZombiesAgainstMemory = function (playerIndex,zombieMemory)

    local zombieList = BZM_Utils.GetZombieListFromPlayerIndex(playerIndex)
    
    if not zombieList then
        BZM_Utils.DebugPrintWithBanner("ZombieMemory not valid",true)
        return
    end

    local playerSquare  = BZM_Utils.GetPlayerCurrentSquare(playerIndex)
    local isValueInList = BZM_Utils.IsValueInList
    local filterList    = nil
    local isNear        = BZM_Utils.IsSquareNearSquare
    local filterRange   = tonumber(SandboxVars.BetterZedManager.RespawnUnseenDistance)
    
    local zombieObjStr = BZM_Enums.Memo.ZombieObj
    local zombieCount   = zombieList:size()
    
    if zombieCount > 0 then
        BZM_Utils.DebugPrintWithBanner("Create filterList",true)
        filterList = {}
    else
        return filterList
    end

    for i = 0, zombieCount - 1,1 do
        
        local zombie = zombieList:get(i)
        local zombieID = zombie:getOnlineID()

        if not zombieMemory:IsExist(zombieID) then

            local zombieSquare = zombie:getCurrentSquare()

            if not isNear(playerSquare,zombieSquare,filterRange) then

                local realState = zombie:getRealState()
                if isValueInList(realState,interestZombieStates) then
                    filterList[#filterList+1] = zombieID
                end
    
                -- assigne zombieobj to the client memo
                zombieMemory:SetData(zombieID,zombieObjStr,zombie)

            end
        end

        -- if we never clean then the temp will be a reference and we will keep appending the set
        -- else if we always clean the memory will be released and we append a new set

    end

    return filterList

end

zombieManager.FindAndUpdateZombies = function (playerIndex,findID,zombieMemory)
    
    local zombieObjKey = BZM_Enums.Memo.ZombieObj
    local zombieList = BZM_Utils.GetZombieListFromPlayerIndex(playerIndex)
    -- local currentZombieTable = zombieMemory:GetTable()
    
    for i = 0, zombieList:size() - 1, 1 do
        
        local zombie = zombieList:get(i)
        local zombieID = zombie:getOnlineID()

        if zombieID == findID then
            zombieMemory:SetData(zombieID,zombieObjKey,zombie)
            return zombieMemory:GetDataByZombieID(zombieID)
        end

    end

    return nil
end


return zombieManager
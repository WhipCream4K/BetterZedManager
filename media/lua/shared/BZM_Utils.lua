
local utils = {}

-- modules stack
-- local sharedData        = require("BZM_SharedData")
local BZM_Enums         = require("BZM_Enums")

---return if the value is the same as in list
---@param inValue any
---@param list any
utils.IsValueInList = function (inValue,list)

    for _, value in ipairs(list) do
        if inValue == value then
            return true
        end
    end
    
    return false
end

utils.FamousZombieTypeUpdate = function(sandboxOptions,zombie,newType)

    local isWakeup =  math.abs(newType - BZM_Enums.ZombieType.Crawlers) -- if we minus newType then 1 = FakeDead 0 = Craweler

    local sandboxLoreSpeed = BZM_Enums.SandboxLore.ZombieSpeed

    if isWakeup <= 1 then
        sandboxOptions:set(sandboxLoreSpeed,2)
        zombie:setCanWalk(false)
        zombie:setFallOnFront(true)
        zombie:toggleCrawling() -- toggle crawling already DoZombieStats
        zombie:setFakeDead(isWakeup == 1)
        return
    end

    sandboxOptions:set(sandboxLoreSpeed,newType)
    zombie:makeInactive(true)
    zombie:makeInactive(false)


    -- if newType == ZombieType.FakeDeads then
    --     sandboxOptions:set("ZombieLore.Speed",2)
    --     zombie:setCanWalk(false)
    --     zombie:setFallOnFront(true)
    --     zombie:toggleCrawling() -- toggle crawling already DoZombieStats
    --     zombie:setFakeDead(true)
    -- else if newType == ZombieType.Crawlers then
    --     sandboxOptions:set("ZombieLore.Speed",2)
    --     zombie:setCanWalk(false)
    --     zombie:setFallOnFront(true)
    --     zombie:toggleCrawling() -- toggle crawling already DoZombieStats
    -- else
    --     sandboxOptions:set("ZombieLore.Speed",newType)
    --     zombie:makeInactive(true)
    --     zombie:makeInactive(false)
    -- end

    -- sandboxOptions:set("ZombieLore.Speed",2) -- from checking the source code we need to set to something which is not 3
    -- zombie:DoZombieSpeeds(newSpeeend

end

utils.InitSharedZombieModData = function (zombie,zombieDataTable)
    
end

utils.GetRandFromList = function (randNumber,pool)

    local accumulatedProbability = 0

    for i = 1, #pool, 1 do
        accumulatedProbability = accumulatedProbability + pool[i]
        if randNumber <= accumulatedProbability then
            return i
        end
    end
    
    return 0

end

-- utils.GetBaseSpeedByType = function (type)

--     local sanboxvars = SandboxVars.BetterZedManager

--     if type == ZombieType.Sprinters then
--         return sanboxvars.SprintersBaseSpeed
--     elseif type == ZombieType.FastShamblers then
--         return sanboxvars.FastShamblersBaseSpeed
--     else
--         return sanboxvars.ShamblersBaseSpeed
--     end
-- end

-- utils.GetRandSpeedRangeByType = function (type)

--     local sanboxvars = SandboxVars.BetterZedManager
--     local ZombRand = ZombRand
    
--     local divider = 10000
--     if type == ZombieType.Sprinters then
--         return ZombRand(sanboxvars.SprintersSpeedRandRange) / divider
--     elseif type == ZombieType.FastShamblers then
--         return ZombRand(sanboxvars.FastShamblersSpeedRandRange) / divider
--     else
--         return ZombRand(sanboxvars.ShamblersSpeedRandRange) / divider
--     end
-- end

utils.DebugPrintWithBanner = function (msg,isClient)

    if not SandboxVars.BetterZedManager.GenerateDebugInfo then
        return
    end

    if getDebug() or isServer() then

        local side = nil
        if isClient then
            side = "----- Client -------"
        else   
            side = "---------------------- Server ---------------------------"
        end

        print("------ BetterZedManager --------")
        print(side)
        print(msg)

    end

end

utils.SetModData = function (modData,type,value)
    -- initialize our moddata block
    modData[BZM_Enums.ModDataValue.BZM_Data] = modData[BZM_Enums.ModDataValue.BZM_Data] or {}
    modData[BZM_Enums.ModDataValue.BZM_Data][type] = value
end

utils.InitFakeDeadModData = function (modData,zombieID,zombieMemory)

    if not zombieMemory[zombieID] then
        return
    end

    modData[BZM_Enums.ModDataValue.BZM_Data] = {} -- initialize our zone of table

    local ourData = modData[BZM_Enums.ModDataValue.BZM_Data]

    -- the normal walking one is fine but we need to sync the fake deads one
    local wakeupType = zombieMemory[zombieID].wakeupType

    if not wakeupType then
        utils.DebugPrintWithBanner("No wake up type in this: "..zombieID,true)
        return -- normal walking zombie
    end
    
    utils.DebugPrintWithBanner("This wake up type: "..wakeupType,true)
    ourData[BZM_Enums.ModDataValue.WakeupType] = wakeupType

end

utils.GetPlayerCurrentSquare = function (playerIndex)
    return getSpecificPlayer(playerIndex):getCurrentSquare()
end

utils.SendClientCMD = function (playerIndex,command,args)
    sendClientCommand(getSpecificPlayer(playerIndex),BZM_Enums.BZM_OnlineModule,command,args)
end

utils.GetZombieListFromPlayerIndex = function (playerIndex)
    
    local player = getSpecificPlayer(playerIndex)
    if not player then
        return nil
    end
    local playerCell = player:getCell()
    if not playerCell then
        return nil
    end
    return playerCell:getZombieList()
end

utils.DebugPrint = function (msg)
    
    if not SandboxVars.BetterZedManager.GenerateDebugInfo then
        return
    end

    if getDebug() or isServer() then
        print(msg)
    end

end

utils.IsSquareNearSquare = function (thisSquare,targetSquare,range)
    local distance = thisSquare:DistTo(targetSquare)
    return distance <= range
end

utils.IsSquareNearMovingObject = function (thisSquare,movingObject,range)
    local distance = thisSquare:DistToProper(movingObject)
    return distance <= range
end

utils.IsSquareNearPos = function (posX,posY,square,range)
    local distance = square:DistTo(posX,posY)
    return distance <= range
end

return utils
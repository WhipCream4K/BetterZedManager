-- handles the zombies randomizing

local randomzier = {}

-- modules stack
local BZM_Commands          = require("BZM_Commands")
local BZM_Utils             = require("BZM_Utils")
local BZM_Enums             = require("BZM_Enums")

-- variable stack
local zombieTypePool                        = {}
local zombieTypePoolAccumulateChance        = 0
local fakeDeadsWakeupPool                   = {}
local fakeDeadWakeupPoolAccumulateChance    = 0


-- export this function
randomzier.Random = function (rollTableTobeUsed,outRollTable)
    
    BZM_Utils.DebugPrintWithBanner("Rolling Zombies",false)

    if getDebug() then
        local poolSize = 0
        for _, _ in pairs(rollTableTobeUsed) do
            poolSize = poolSize + 1
        end
    
        BZM_Utils.DebugPrint("TotalPool: "..poolSize)
    end

    local outNewZombieSpeed = {}

    local zombRand = ZombRand -- pull to local
    local getRandFromList = BZM_Utils.GetRandFromList

    local memoEnums = BZM_Enums.Memo
    
    local zombieTypeKey = memoEnums.ZombieType
    local wakeupTypeKey = memoEnums.WakeupType

    for zombieID, memo in pairs(rollTableTobeUsed) do
        
        outNewZombieSpeed[zombieID] = {}

        local randNumber = zombRand(zombieTypePoolAccumulateChance) + 1
        local zombieType = getRandFromList(randNumber,zombieTypePool)
        
        -- speed change is not supported at the moment
        -- local totalSpeed = BZM_Utils.GetBaseSpeedByType(zombieType)
        -- totalSpeed = totalSpeed + BZM_Utils.GetRandSpeedRangeByType(zombieType)

        outNewZombieSpeed[zombieID][zombieTypeKey] = zombieType
        memo[zombieTypeKey] = zombieType

        -- update out roll table
        outRollTable[zombieID] = outRollTable[zombieID] or {}
        local outDataTable = outRollTable[zombieID]
        outDataTable[zombieTypeKey] = zombieType
        
        if zombieType == BZM_Enums.ZombieType.FakeDeads then

            local wakeupRand = zombRand(fakeDeadWakeupPoolAccumulateChance) + 1
            local wakeupType = getRandFromList(wakeupRand,fakeDeadsWakeupPool)

            outNewZombieSpeed[zombieID][wakeupTypeKey] = wakeupType
            memo[wakeupTypeKey] = wakeupType

            -- update out roll table
            outDataTable[wakeupTypeKey] = wakeupType

            BZM_Utils.DebugPrint("ZombieID: "..zombieID.." becomes: "..zombieType.." wakeupType: "..tostring(wakeupType))

        end
        
        
        -- BZM_Utils.DebugPrint("ZombieID: "..zombieID.." becomes: "..zombieType.." wakeupType: "..tostring(wakeupTypeStr))

    end

    return outNewZombieSpeed

end

local function InitVariables()
    
    local currentSandbox = SandboxVars.BetterZedManager
    local zombieTypeEnums = BZM_Enums.ZombieType

    zombieTypePool[zombieTypeEnums.Sprinters] = currentSandbox.PercentSprinters
    zombieTypePool[zombieTypeEnums.FastShamblers] = currentSandbox.PercentFastShamblers
    zombieTypePool[zombieTypeEnums.Shamblers] = currentSandbox.PercentShamblers
    zombieTypePool[zombieTypeEnums.Crawlers] = currentSandbox.PercentCrawlers

    if currentSandbox.EnableFakeDeads then

        zombieTypePool[zombieTypeEnums.FakeDeads] = currentSandbox.PercentFakeDeads
        
        local fakeDeadWakeUpTypeEnums = BZM_Enums.FakeDeadWakeupType
        -- Init fake dead pool
        fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.Sprinters] = currentSandbox.FakeDeadsPercentWakeAsSprinters
        fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.FastShamblers] = currentSandbox.FakeDeadsPercentWakeAsFastShamblers
        fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.Shamblers] = currentSandbox.FakeDeadsPercentWakeAsShamblers
        fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.Crawlers] = currentSandbox.FakeDeadsPercentWakeAsCrawlers

        for i = 1, #fakeDeadsWakeupPool,1 do
            fakeDeadWakeupPoolAccumulateChance = fakeDeadWakeupPoolAccumulateChance + fakeDeadsWakeupPool[i]
        end

    end

    for i = 1, #zombieTypePool,1 do
        zombieTypePoolAccumulateChance= zombieTypePoolAccumulateChance + zombieTypePool[i]
    end

end

Events.OnGameBoot.Add(InitVariables)

return randomzier


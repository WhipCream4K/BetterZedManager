-- -- headguard for server during lua load
-- -- not sure if it does anything
-- if not isServer() and not isCoopHost() then
--     return
-- end
-- ------------------------------------------

-- local BZM_Commands = require("BZM_Commands")
-- local BZM_Utils = require("BZM_Utils")
-- local BZM_Enums = require("BZM_Enums")

-- local SendServerCMD = sendServerCommand
-- local GetOnlinePlayers = getOnlinePlayers
-- local GetGameTime      = getGameTime

-- -- this stays in server side
-- local serverZombiePool = {}
-- local zombieTypePool = {}
-- local zombieTypePoolAccumulateChance = 0
-- local clientCommandCounter = 0
-- local rerollLimitInMins = 0
-- local rerollCounterInMins = 0
-- local isModDisable = false
-- local rerollEvent = nil

-- local fakeDeadsWakeupPool = {}
-- local fakeDeadWakeupPoolAccumulateChange = 0

-- local function BroadcastClientQueryZombiesList()
--     SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.QueryClientZombies,{})
-- end

-- local function RerollOneMinuteCounter()

--     rerollCounterInMins = rerollCounterInMins + 1

--     -- BZM_Utils.DebugPrintWithBanner("Reroll One minute: "..rerollTimeOneMinutesCounter)

--     if(rerollCounterInMins >= rerollLimitInMins) then
--         BroadcastClientQueryZombiesList()
--         rerollCounterInMins = 0
--     end

-- end

-- local function SetActiveMod(value)
--     if value then
--         rerollCounterInMins = 0
--         rerollEvent.Remove(RerollOneMinuteCounter)
--     else
--         rerollEvent.Add(RerollOneMinuteCounter)
--     end
-- end

-- local function ModDisableCheck()

--     local gameHours = GetGameTime():getHour()
--     local sandboxVars = SandboxVars.BetterZedManager

--     BZM_Utils.DebugPrintWithBanner("Game Hours: "..gameHours,false)
    
--     if not isModDisable and gameHours >= sandboxVars.DisableFrom then
--         isModDisable = true
--         BZM_Utils.DebugPrint("BetterZedManager now disable: ")
--         SetActiveMod(false)
--     elseif gameHours >= sandboxVars.DisableTo and isModDisable then
--         BZM_Utils.DebugPrint("BetterZedManager now enable: ")
--         isModDisable = false
--         SetActiveMod(true)
--     end

-- end


-- local function ShouldModDisableFirstFrame()
    
--     local gameHours = GetGameTime():getHour()
--     local sandboxVars = SandboxVars.BetterZedManager
--     local disableFrom = sandboxVars.DisableFrom
--     local disableTo = sandboxVars.DisableTo

--     if disableFrom >= gameHours or gameHours <= disableTo then
--         isModDisable = true
--         SetActiveMod(false)
--     end
    
--     BZM_Utils.DebugPrintWithBanner("Should not disable this mod first frame",false)

--     Events.EveryHours.Add(ModDisableCheck)
--     Events.EveryOneMinute.Remove(ShouldModDisableFirstFrame)

-- end

-- -- Initialization HERE
-- local function InitVariables()

--     BZM_Utils.DebugPrintWithBanner("Init Server Variables", false)
    
--     -- pool of zombie types, orders arrange in the same manner as zombie lore
--     local currentSandbox = SandboxVars.BetterZedManager
--     local zombieTypeEnums = BZM_Enums.ZombieType
    
--     -- Init zombie type pool
--     zombieTypePool[zombieTypeEnums.Sprinters] = currentSandbox.PercentSprinters
--     zombieTypePool[zombieTypeEnums.FastShamblers] = currentSandbox.PercentFastShamblers
--     zombieTypePool[zombieTypeEnums.Shamblers] = currentSandbox.PercentShamblers
--     zombieTypePool[zombieTypeEnums.Crawlers] = currentSandbox.PercentCrawlers

--     if currentSandbox.EnableFakeDeads then

--         zombieTypePool[zombieTypeEnums.FakeDeads] = currentSandbox.PercentFakeDeads
        
--         local fakeDeadWakeUpTypeEnums = BZM_Enums.FakeDeadWakeupType
--         -- Init fake dead pool
--         fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.Sprinters] = currentSandbox.FakeDeadsPercentWakeAsSprinters
--         fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.FastShamblers] = currentSandbox.FakeDeadsPercentWakeAsFastShamblers
--         fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.Shamblers] = currentSandbox.FakeDeadsPercentWakeAsShamblers
--         fakeDeadsWakeupPool[fakeDeadWakeUpTypeEnums.Crawlers] = currentSandbox.FakeDeadsPercentWakeAsCrawlers

--         for i = 1, #fakeDeadsWakeupPool,1 do
--             fakeDeadWakeupPoolAccumulateChange = fakeDeadWakeupPoolAccumulateChange + fakeDeadsWakeupPool[i]
--         end

--     end
    
--     for i = 1, #zombieTypePool,1 do
--         zombieTypePoolAccumulateChance= zombieTypePoolAccumulateChance + zombieTypePool[i]
--     end
    

    
--     -- Init respawn timer
--     rerollLimitInMins = currentSandbox.RespawnTimeInMinutes
--     if rerollLimitInMins > 0 then
--         rerollEvent = Events.EveryOneMinute
--         rerollEvent.Add(RerollOneMinuteCounter)
--     end

--     if currentSandbox.CanBeDisabled then
--         Events.EveryOneMinute.Add(ShouldModDisableFirstFrame)
--     end

-- end

-- local function GetZombieType(number)
    
--     local accumulatedProbability = 0

--     for i = 1, #zombieTypePool, 1 do
--         accumulatedProbability = accumulatedProbability + zombieTypePool[i]
--         if number <= accumulatedProbability then
--             return i
--         end
--     end
    
--     return 0
-- end

-- local function RollZombies()

--     BZM_Utils.DebugPrintWithBanner("Rolling Zombies",false)

--     if getDebug() then
--         local poolSize = 0
--         for _, _ in pairs(serverZombiePool) do
--             poolSize = poolSize + 1
--         end
    
--         BZM_Utils.DebugPrint("TotalPool: "..poolSize)
--     end


--     local outNewZombieSpeed = {}

--     local zombRand = ZombRand -- pull to local
--     local getRandFromList = BZM_Utils.GetRandFromList

--     local modaDataValueEnums = BZM_Enums.ModDataValue
    
--     local zombieTypeStr = modaDataValueEnums.ZombieType
--     local wakeupTypeStr = modaDataValueEnums.WakeupType

--     for zombieID, _ in pairs(serverZombiePool) do
        
--         outNewZombieSpeed[zombieID] = {}

--         local randNumber = zombRand(zombieTypePoolAccumulateChance) + 1
--         local zombieType = getRandFromList(randNumber,zombieTypePool)
        
--         -- speed change is not supported at the moment
--         -- local totalSpeed = BZM_Utils.GetBaseSpeedByType(zombieType)
--         -- totalSpeed = totalSpeed + BZM_Utils.GetRandSpeedRangeByType(zombieType)

--         outNewZombieSpeed[zombieID][zombieTypeStr] = zombieType
        
--         if zombieType == BZM_Enums.ZombieType.FakeDeads then
--             local wakeupRand = zombRand(fakeDeadWakeupPoolAccumulateChange) + 1
--             local wakeupType = getRandFromList(wakeupRand,fakeDeadsWakeupPool)

--             outNewZombieSpeed[zombieID][wakeupTypeStr] = wakeupType

--         end
        
        
--         BZM_Utils.DebugPrint("ZombieID: "..zombieID.." becomes: "..zombieType)

--     end

--     -- tell all the players to update their zombie
--     SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.UpdateZombies,outNewZombieSpeed)

--     serverZombiePool = {} -- deallocation

-- end

-- local function GatherZombieInServer(playerOnlineID,zombieList)

--     if not zombieList then
--         return
--     end
    
--     BZM_Utils.DebugPrintWithBanner("Gathering player's zombies: "..playerOnlineID)

--     -- as ArrayList<IsoPlayers>
--     local onlinePlayers = GetOnlinePlayers() -- should be fine to call
--     local totalOnlinePlayers = onlinePlayers:size()

--     BZM_Utils.DebugPrintWithBanner("Total Players: "..totalOnlinePlayers)

--     -- sanity check
--     if totalOnlinePlayers <= 0 then
--         return
--     end

--     clientCommandCounter = clientCommandCounter + 1

--     BZM_Utils.DebugPrintWithBanner("Client Counter : "..clientCommandCounter)
    
--     for i = 1, #zombieList, 1 do
--         -- this guaruntee the uniqueness of zombies by making it a set
--         serverZombiePool[zombieList[i]] = true
--     end
    
--     if clientCommandCounter >= totalOnlinePlayers then
--         clientCommandCounter = 0
--         RollZombies()
--     end

-- end

-- local function BroadcastSyncFakeDeads(playerOnlineID,zombieArgs)

--     if zombieArgs == nil then
--         return
--     end
    
--     local onlineData = {}
--     onlineData[BZM_Enums.OnlineArgs.PlayerID] = playerOnlineID
--     onlineData[BZM_Enums.OnlineArgs.ZombieID] = zombieArgs[BZM_Enums.OnlineArgs.ZombieID]

--     -- local posX = zombieArgs["posX"]
--     -- local posY = zombieArgs["posY"]
--     -- local posZ = zombieArgs["posZ"]

--     BZM_Utils.DebugPrintWithBanner("Please Sync this zombie: "..zombieArgs[BZM_Enums.OnlineArgs.ZombieID],false)

--     SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.SyncFakeDead,onlineData)

-- end

-- local function OnClientToServer(module,command,player,args)

--     if module == BZM_Enums.BZM_OnlineModule then
--         if command == BZM_Commands.ReRollZombies then
--             GatherZombieInServer(player:getOnlineID(),args)
--         elseif command == BZM_Commands.SyncFakeDead then
--             BroadcastSyncFakeDeads(player:getOnlineID(),args)
--         end
--     end

-- end


-- Events.OnGameBoot.Add(InitVariables)
-- Events.OnClientCommand.Add(OnClientToServer)
-- require("BZM_Enums")
-- require("BZM_FakeDead")

-- local BZM_Commands = require("BZM_Commands")
-- local BZM_Utils = require("BZM_Utils")
-- local BZM_Module = "BZM_Module"


-- local thisPlayerIndex = 0
-- local interestZombieStates = {"idle","sitting"}

-- local rerollTimeInMins = 0
-- local rerollTimeOneMinutesCounter = 0

-- local rerollEvent = nil
-- local isDisabled = false

-- local priorZombieMemory = {}

-- function GetPriorZombieMemory()
--     return priorZombieMemory
-- end

-- local function CleanZombieMemo()
--     priorZombieMemory = {}

--     -- reset
--     local zombieList = BZM_Utils.GetZombieListFromPlayer(thisPlayerIndex)

--     for i = 0, zombieList:size() - 1,1 do
--         local zombie = zombieList:get(i)
--         local zombieID = zombie:getOnlineID()
--         priorZombieMemory[zombieID] = zombie
--     end

-- end

-- local function FilterZombies(zombieArray)
    
--     local filterList = nil

--     if not zombieArray then
--         return filterList
--     end

--     local cleaningMethod = SandboxVars.BetterZedManager.ZombieMemoryCleaningMethod

--     local tempZombieMemo = priorZombieMemory -- ref

--     if cleaningMethod == CleanMemMethod.AlwaysClean then
--         priorZombieMemory = {}
--     end

--     local zombieCount = zombieArray:size()
--     local isvalueInList = BZM_Utils.IsValueInList

--     for i = 0, zombieCount - 1,1 do
--         local zombieObj = zombieArray:get(i)
--         local zombieID = zombieObj:getOnlineID()

--         if not tempZombieMemo[zombieID] then
--             local realState = zombieObj:getRealState()
--             if isvalueInList(realState,interestZombieStates) then
                
--                 if not filterList then
--                     filterList = {}
--                 end

--                 filterList[#filterList+1] = zombieID

--             end
--         end

--         -- if we never clean then the temp will be a reference and we will keep appending the set
--         -- else if we always clean the memory will be released and we append a new set
--         -- if cleaningMethod == CleanMemMethod.NeverClean or
--         -- cleaningMethod == CleanMemMethod.CleanEveryDay then
--         --     tempZombieMemo[zombieID] = true
--         -- elseif cleaningMethod == CleanMemMethod.AlwaysClean then
--         --     priorZombieMemory[zombieID] = true
--         -- end
--         priorZombieMemory[zombieID] = zombieObj

--     end

--     return filterList

-- end

-- local function ReRollZombies()

--     local zombieList = BZM_Utils.GetZombieListFromPlayer(thisPlayerIndex)
--     local filterZombie = FilterZombies(zombieList)

--     -- re roollllllll
--     if not filterZombie then
--         return
--     end

--     sendClientCommand(getSpecificPlayer(thisPlayerIndex),BZM_Module,BZM_Commands.ReRollZombies,filterZombie)

-- end


-- local function UpdateClientZombies(newServerZombiesList)
 
--     if not newServerZombiesList then
--         return
--     end

--     BZM_Utils.DebugPrintWithBanner("Updating Client Zombie",true)

--     local thisPlayer = getSpecificPlayer(thisPlayerIndex)
--     local sandboxOptions = getSandboxOptions()
--     local defaultZombieSpeed = sandboxOptions:getOptionByName(SandboxLore.ZombieSpeed):getValue()
--     local currentPlayerCell = thisPlayer:getCell()

--     -- sanity check
--     -- if not currentPlayerCell then
--     --     return
--     -- end

--     -- local zombieList = currentPlayerCell:getZombieList()
--     -- -- sanity check
--     -- if not zombieList then
--     --     return
--     -- end

--     -- local zombieCount = zombieList:size()
--     -- -- sanity check
--     -- if zombieCount <= 0 then
--     --     return
--     -- end

--     -- keep on the stack
--     local isValueInList = BZM_Utils.IsValueInList
--     local convertZombie = BZM_Utils.FamousZombieTypeUpdate
--     local bzmModIndicator = ModDataValue.BZM_Data
--     local wakeupTypeStr = ModDataValue.WakeupType
--     local zombieTypeStr = ModDataValue.ZombieType

--     for key, value in pairs(newServerZombiesList) do
        
--     end

--     -- zombieList is an ArrayList(JAVA), so it starts with 0 index
--     -- for i = 0, zombieCount - 1, 1 do
--     --     local zombieObj = zombieList:get(i)
--     --     local realState = zombieObj:getRealState()
--     --     -- we only interest in this zombie state
--     --     if isValueInList(realState,interestZombieStates) then
            
--     --         local zombieID = zombieObj:getOnlineID()
--     --         local speedTable = newSpeedTable[zombieID]
--     --         local newZombieType = speedTable[zombieTypeStr] or defaultZombieSpeed
            
--     --         -- famous zombie changing function
--     --         convertZombie(sandboxOptions,zombieObj,newZombieType)

--     --         -- for fake dead we save the wake up type for later
--     --         local wakeupType = newSpeedTable[zombieID][wakeupTypeStr]
--     --         if wakeupType then
--     --             local modData = zombieObj:getModData()
--     --             modData[bzmModIndicator] = modData[bzmModIndicator] or {}
--     --             modData[bzmModIndicator][wakeupTypeStr] = wakeupType
--     --         end

--     --     end
--     -- end

--     -- for zombieID, zombieObj in pairs(priorZombieMemory) do
--     --     local realState = zombieObj:getRealState()
--     --     if isValueInList(realState,interestZombieStates) then
--     --         local speedTable = newSpeedTable[zombieID]
--     --         if speedTable then

--     --             local newZombieType = speedTable[zombieTypeStr] or defaultZombieSpeed
--     --             convertZombie(sandboxOptions,zombieObj,newZombieType)

--     --             -- for fake dead we save the wake up type for later
--     --             local wakeupType = newSpeedTable[zombieID][wakeupTypeStr]
--     --             if wakeupType then
--     --                 local modData = zombieObj:getModData()
--     --                 modData[bzmModIndicator] = modData[bzmModIndicator] or {}
--     --                 modData[bzmModIndicator][wakeupTypeStr] = wakeupType
--     --             end
                
--     --         end
--     --     end
--     -- end

--     sandboxOptions:set(SandboxLore.ZombieSpeed,defaultZombieSpeed)

-- end


-- local function RerollOneMinuteCounter()

--     rerollTimeOneMinutesCounter = rerollTimeOneMinutesCounter + 1

--     -- BZM_Utils.DebugPrintWithBanner("Reroll One minute: "..rerollTimeOneMinutesCounter)

--     if(rerollTimeOneMinutesCounter >= rerollTimeInMins) then
--         ReRollZombies()
--         rerollTimeOneMinutesCounter = 0
--     end

-- end

-- local function ResetRerollTimer()
--     rerollTimeOneMinutesCounter = 0
-- end

-- local function ModDisableCheck()

--     local gameHours = getGameTime():getHour()
--     local sandboxVars = SandboxVars.BetterZedManager

--     BZM_Utils.DebugPrintWithBanner("Game Hours: "..gameHours,true)
    
--     if not isDisabled and gameHours == sandboxVars.DisableFrom then
--         isDisabled = true
--         BZM_Utils.DebugPrint("BetterZedManager now disable: ")
--         ResetRerollTimer()
--         rerollEvent.Remove(RerollOneMinuteCounter)
--     elseif gameHours == sandboxVars.DisableTo and isDisabled then
--         BZM_Utils.DebugPrint("BetterZedManager now enable: ")
--         isDisabled = false
--         rerollEvent.Add(RerollOneMinuteCounter)
--     end
-- end


-- local function InitVariables()
    
--     -- sandboxvars has to be loaded during game start after the sandbox has been loaded else it uses the default
--     local sandboxVars = SandboxVars.BetterZedManager
    
    
--     -- rerollTimeInMins = sandboxVars.RespawnTimeInMinutes
--     -- BZM_Utils.DebugPrintWithBanner("rerollTimeInHours: "..rerollTimeInMins,true)

--     -- if rerollTimeInMins > 0 then
--     --     rerollEvent = Events.EveryOneMinute
--     --     rerollEvent.Add(RerollOneMinuteCounter)
--     -- end


--     if sandboxVars.ZombieMemoryCleaningMethod == CleanMemMethod.CleanEveryDay then
--         Events.EveryDays.Add(CleanZombieMemo)
--     end

--     -- if sandboxVars.CanBeDisabled then
--     --     Events.EveryHours.Add(ModDisableCheck)
--     -- end

-- end

-- -- local function SyncFakeDeadsOnOurClient(id)
    
-- --     if not id then
-- --         return
-- --     end

    
-- --     BZM_Utils.DebugPrintWithBanner("Sync Fake Deads: "..id,true)

-- --     -- fakeDeadsOverServer[id] = true
-- --     -- local zombieList = BZM_Utils.GetZombieListFromPlayer(thisPlayerIndex)
-- --     -- TODO: bypass if we don't have memory

-- --     if priorZombieMemory then
-- --         if priorZombieMemory[id] then
-- --             local zombie = priorZombieMemory[id]

-- --             local modData = zombie:getModData()
-- --             local sandboxOptions =  getSandboxOptions()
-- --             local defaultZombieSpeed = sandboxOptions:getOptionByName("ZombieLore.Speed"):getValue()
            
-- --             sandboxOptions:set("ZombieLore.Speed",2)
-- --             zombie:setFakeDead(false)
-- --             zombie:toggleCrawling()
        
-- --             modData.justRevive = true
-- --             sandboxOptions:set("ZombieLore.Speed",defaultZombieSpeed)

-- --         end
-- --     end


-- -- end

-- local function ServerToClient(module,command,args)
--     if module == BZM_Module then
--         if command == BZM_Commands.UpdateZombies then
--             UpdateClientZombies(args)
--         elseif command == BZM_Commands.QueryClientZombies then
--             ReRollZombies()
--         elseif command == BZM_Commands.SyncFakeDeads then
--             local myOnlineID = getSpecificPlayer(thisPlayerIndex):getOnlineID()
--             if myOnlineID ~= args[OnlineArgs.PlayerID] then
--                 SyncFakeDeads(priorZombieMemory,args[OnlineArgs.ZombieID])
--             end

--         end
--     end
-- end

-- local function TestSprinters()
    
--     BZM_Utils.DebugPrintWithBanner("Server Statistic",true)
--     local player = getServerStatistic()
--     if not player then
--         print("Sad no table")
--     end
--     for key, value in pairs(player) do
--         print(key)
--         print(value)
--     end
--     -- if player then
--     --     local playerCell = player:getCell()
--     --     local zombieList = playerCell:getZombieList()
--     --     local zombieCount = zombieList:size()

--     --     for i = 0, zombieCount - 1,1 do
--     --         print("SpeedMod: "..zombieList:get(i):getSpeedMod())
--     --     end
--     -- end
-- end

-- local function TestReRoll(keynum)
--     if keynum == Keyboard.KEY_F9 then
--         ReRollZombies()
--     end
-- end

-- local function WakeTheDead(zombie)

--     local modData = zombie:getModData()
--     local zombieID = zombie:getOnlineID()
--     local player = getSpecificPlayer(thisPlayerIndex)

--     local sandboxOptions =  getSandboxOptions()
--     local defaultZombieSpeed = sandboxOptions:getOptionByName("ZombieLore.Speed"):getValue()
    
--     sandboxOptions:set("ZombieLore.Speed",2)
--     zombie:setFakeDead(false)
--     zombie:toggleCrawling()
--     modData.justRevive = true
--     sandboxOptions:set("ZombieLore.Speed",defaultZombieSpeed)

--     if isClient() then
--         -- tell other people to sync with this mf
--         sendClientCommand(player,BZM_Module,BZM_Commands.SyncFakeDeads,{zombieID = zombieID})
--     end

-- end

-- -- local function OnWorldSound(x,y,z,radius,volume,source)

-- --     BZM_Utils.DebugPrintWithBanner("On Someone sound at volume: "..volume,true)
-- --     BZM_Utils.DebugPrint("At radius: "..radius)

-- --     -- local zombieList = BZM_Utils.GetZombieListFromPlayer(thisPlayerIndex)
-- --     -- if not zombieList then
-- --     --     return
-- --     -- end

-- --     -- for i = 0, zombieList:size() - 1,1 do
-- --     --     local zombie = zombieList:get(i)
-- --     --     if zombie:isFakeDead() then
-- --     --         local currentSquare = zombie:getCurrentSquare()
-- --     --         local distanceToSound = currentSquare:DistTo(source:getSquare())
-- --     --         BZM_Utils.DebugPrint("Distance form to sound: "..distanceToSound)
-- --     --         if distanceToSound <= radius then
-- --     --             -- we are inside the sound radius
-- --     --             WakeTheDead(zombie)
-- --     --         end
-- --     --     end
-- --     -- end

-- -- end

-- local function OnCreatePlayer(playerIndex,player)
--     thisPlayerIndex = playerIndex
-- end

-- -- local function OnZombieUpdate(zombie)
    
-- --     local modData = zombie:getModData()

-- --     if modData.justRevive == true then

-- --         zombie:setCanWalk(false)
-- --         zombie:setFallOnFront(true)
-- --         zombie:toggleCrawling()
-- --         zombie:DoZombieSpeeds(0.56) -- magic number that makes zombie goes crawler
-- --         modData.justRevive = nil
-- --         return

-- --     end

    
-- --     if not zombie:isFakeDead() then
-- --         return
-- --     end
    
-- --     local zombieID = zombie:getOnlineID()
-- --     local player = getSpecificPlayer(thisPlayerIndex)
-- --     local playerCurrentSquare = player:getCurrentSquare()
-- --     if playerCurrentSquare == zombie:getCurrentSquare() or fakeDeadsOverServer[zombieID] then
-- --         WakeTheDead(zombie)
-- --         -- fakeDeadsOverServer[zombieID] = nil
-- --     end

-- -- end

-- -- Events.OnZombieUpdate.Add(OnZombieUpdate)
-- Events.OnServerCommand.Add(ServerToClient)
-- Events.OnCreatePlayer.Add(OnCreatePlayer) -- call once after player click screen
-- Events.OnGameTimeLoaded.Add(InitVariables)
-- Events.OnKeyPressed.Add(TestReRoll)

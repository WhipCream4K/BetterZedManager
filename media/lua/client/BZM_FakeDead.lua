
-- local BZM_Utils = require("BZM_Utils")

-- local GetSandboxOptions = getSandboxOptions
-- local GetPlayer         = getSpecificPlayer
-- local IsClient          = isClient
-- local SendClientCMD     = sendClientCommand

-- local BZM_Module = "BZM_Module"
-- local BZM_Commands = require("BZM_Commands")


-- local thisPlayerIndex = 0
-- local concerningNoises = {}

-- local justReviveStr         = ModDataValue.JustRevive
-- local startStandingStr      = ModDataValue.StartStanding 
-- local modDataIndicatorStr   = ModDataValue.BZM_Data
-- local wakeupTypeStr         = ModDataValue.WakeupType

-- local function PreparingWakeUp(modData,zombie,shouldNotifyOtherClient)

--     if not modData then
--         return
--     end

--     zombie:setCrawler(false)
--     zombie:setKnockedDown(false)
--     zombie:setStaggerBack(false)

--     modData[justReviveStr] = true

--     if shouldNotifyOtherClient and IsClient() then

--         -- another sanity check
--         if zombie:isFakeDead() and not SandboxVars.BetterZedManager.FakeDeadsDisableJumpScare then
--             local player = GetPlayer(thisPlayerIndex)
--             local soundEmitter = player:getEmitter()
--             if not soundEmitter:isPlaying("ZombieSurprisedPlayer") then
--                 soundEmitter:playSoundImpl("ZombieSurprisedPlayer",player) -- play local sound
--             end
--         end

--         local onlineData = {}
--         onlineData[OnlineArgs.ZombieID] = zombie:getOnlineID()

--         SendClientCMD(GetPlayer(thisPlayerIndex),BZM_Module,BZM_Commands.SyncFakeDeads,onlineData)

--     end

--     zombie:setFakeDead(false)

-- end

-- local function ChangeZombieSpeedAfterStanding(modData,zombie)
    
--     if not modData then
--         return
--     end

--     local sandboxOptions = GetSandboxOptions()
--     local defaultZombieSpeed = sandboxOptions:getOptionByName(SandboxLore.ZombieSpeed):getValue()

--     zombie:setCanWalk(true)

--     BZM_Utils.FamousZombieTypeUpdate(sandboxOptions,zombie,modData[wakeupTypeStr])
--     modData[startStandingStr] = false

--     zombie:DoZombieSpeeds(0.86) -- I don't know if it does anything

--     sandboxOptions:set(SandboxLore.ZombieSpeed,defaultZombieSpeed)

-- end

-- local function WakeUpTheDead(modData,zombie)

--     if not modData then
--         BZM_Utils.DebugPrintWithBanner("NO Moddata found",true)
--         return
--     end

--     local sandboxOptions =  GetSandboxOptions()
--     local defaultZombieSpeed = sandboxOptions:getOptionByName(SandboxLore.ZombieSpeed):getValue()

--     local wakeupType = modData[wakeupTypeStr]

--     sandboxOptions:set(SandboxLore.ZombieSpeed,2)

--     zombie:setCanWalk(false)
--     zombie:setCrawler(true)
--     zombie:setFallOnFront(true)
--     zombie:setOnFloor(true)
--     zombie:DoZombieStats()
--     zombie:DoZombieSpeeds(0.56) -- magic number that makes zombie goes crawler

--     -- if wakeupType == FakeDeadWakeupType.Crawlers then
--     --     zombie:setCanWalk(false)
--     --     zombie:setCrawler(true)
--     --     zombie:setFallOnFront(true)
--     --     zombie:setOnFloor(true)
--     --     zombie:DoZombieStats()
--     --     zombie:DoZombieSpeeds(0.56) -- magic number that makes zombie goes crawler
--     -- else

--     --     zombie:setCanWalk(true)
--     --     -- zombie:setFallOnFront(true)
--     --     zombie:setOnFloor(true)
        
--     --     zombie:makeInactive(true)
--     --     zombie:makeInactive(false)

--     --     zombie:DoZombieSpeeds(0.86) -- magic number that makes zombie goes walking
--     --     modData[startStandingStr] = true
--     -- end

--     if wakeupType ~= FakeDeadWakeupType.Crawlers then
--         modData[startStandingStr] = true
--     end

--     -- zombie:setTurnDelta(20.0) -- doesn't work
    
--     modData[justReviveStr] = false

--     sandboxOptions:set(SandboxLore.ZombieSpeed,defaultZombieSpeed)

-- end

-- local function OnWorldSound(x,y,z,radius,volume,source)

--     -- BZM_Utils.DebugPrintWithBanner("On Someone sound at volume: "..volume,true)
--     -- BZM_Utils.DebugPrint("At radius: "..radius)

--     local activeNoiseVolume = SandboxVars.BetterZedManager.FakeDeadsActiveVolume

--     if volume < activeNoiseVolume then
--         return
--     end

--     concerningNoises[#concerningNoises+1] = {
--         posX = x,
--         posY = y,
--         radius = radius
--     }

-- end

-- local function OnCreatePlayer(playerIndex,player)
--     thisPlayerIndex = playerIndex
-- end

-- local function OnPostRender() -- after one frame has passed
--     concerningNoises = {}
-- end



-- local function OnZombieUpdate(zombie)
    
--     local modData = zombie:getModData()[modDataIndicatorStr]

--     if modData and modData[startStandingStr] then
--         ChangeZombieSpeedAfterStanding(modData,zombie)
--         return
--     end

--     -- we wake the dead by two conditions
--     -- 1. player is near the fake deads
--     -- 2. the fake deads heard any noises from a nearby player

--     -- apparently the waking up of a fake dead requires 2 game loop to be functional

--     if modData and modData[justReviveStr] then
--         -- actually waking up as a crawler
--         WakeUpTheDead(modData,zombie)
--         return
--     end

--     if not zombie:isFakeDead() then
--         return
--     else
--         -- check if there's a concerning noise
--         local zombieSquare = zombie:getCurrentSquare()
--         local isNearSoundSource = BZM_Utils.IsSquareNearPos

--         if concerningNoises then
--             for _, value in pairs(concerningNoises) do
--                 local isNear = isNearSoundSource(value.posX,value.posY,zombieSquare,value.radius)
--                 if isNear then
--                     PreparingWakeUp(modData,zombie,true)
--                 end
--             end
--         end
--         -- check if player is near the zombie
--         local player = GetPlayer(thisPlayerIndex)
--         local playerSquare = player:getCurrentSquare()
--         local distanceToWake = 1.3
--         local isnear = BZM_Utils.IsSquareNearSquare(playerSquare,zombieSquare,distanceToWake)
        
        
--         if isnear and zombie:CanSee(player) then
--             BZM_Utils.DebugPrintWithBanner("Player Near: "..tostring(isnear),true)
--             PreparingWakeUp(modData,zombie,true)
--             return
--         end
        
--     end

-- end

-- function SyncFakeDeads(priorZombieMemory,zombieID,zombieArgs) -- one global function to sync the zombie in our client
    
--     local zombie = priorZombieMemory[zombieID]

--     -- we ensure that there's always going to be a memory of zombie
--     if not zombie then
--         return
--     end

--     -- if not zombie then
--     --     -- TODO: fix this the square will only retreive the first instance of the zombie
--     --     local square = getSquare(zombiePosX,zombiePosY,zombiePosZ)
--     --     local zombieObj = square:getZombie()
--     --     priorZombieMemory[zombieID] = zombieObj
--     --     zombie = zombieObj
--     -- end

--     local modData = zombie:getModData()
--     PreparingWakeUp(modData[modDataIndicatorStr],zombie,false)

-- end


-- local function InitVariables()
    
--     local isEnableFakeDead = SandboxVars.BetterZedManager.EnableFakeDeads

--     BZM_Utils.DebugPrintWithBanner("EnableFakeDeads: "..tostring(isEnableFakeDead))
    
--     if isEnableFakeDead then
--         Events.OnCreatePlayer.Add(OnCreatePlayer) -- call once after player click screen
--         Events.OnZombieUpdate.Add(OnZombieUpdate)
--         Events.OnWorldSound.Add(OnWorldSound)
--         Events.OnPostRender.Add(OnPostRender)
--     end

-- end

-- Events.OnLoad.Add(InitVariables)




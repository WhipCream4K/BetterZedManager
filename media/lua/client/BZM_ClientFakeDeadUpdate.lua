
-- handles fake zombies update mostly

-- require("BZM_Enums")

-- moduel stack
local BZM_Commands          = require("BZM_Commands")
local BZM_Utils             = require("BZM_Utils")
local BZM_Enums             = require("BZM_Enums")
local sharedData            = require("BZM_ClientSharedData")

-- variable stack
-- local playerObject       = 0
-- local thisPlayerIndex    = 0
local concerningNoises      = nil
local fakeDeadUpdate        = {}

-- function stack
local GetPlayer             = getSpecificPlayer
local SendClientCMD         = sendClientCommand
local IsClient              = isClient
local GetSandboxOptions     = getSandboxOptions


-- local function OnCreatePlayer(id,player)
--     playerObject = player
--     thisPlayerIndex = id
-- end

-- export this function
fakeDeadUpdate.PreparingWakeUp = function (modData,zombie,shouldNotifyOtherClient,shouldPlaySound)

    if not modData then
        return
    end

    -- local zombieID   = zombie:getOnlineID()
    -- local clientMemo = sharedData.ZombieMemory
    -- clientMemo[zombieID][BZM_Enums.Memo.IsAlreadyWake] = false

    zombie:setCrawler(false)
    zombie:setKnockedDown(false)
    zombie:setStaggerBack(false)

    modData[BZM_Enums.ModDataValue.JustRevive] = true

    if shouldNotifyOtherClient and IsClient() then

        local onlineData = {}
        onlineData[BZM_Enums.OnlineArgs.ZombieID] = zombie:getOnlineID()

        SendClientCMD(sharedData.GetPlayer(),BZM_Enums.BZM_OnlineModule,BZM_Commands.SyncFakeDead,onlineData)

    end

    if shouldPlaySound then
        -- another sanity check
        if zombie:isFakeDead() and not SandboxVars.BetterZedManager.FakeDeadsDisableJumpScare then
            -- local player = GetPlayer(thisPlayerIndex)
            local soundEmitter = sharedData.GetPlayer():getEmitter()
            if not soundEmitter:isPlaying("ZombieSurprisedPlayer") then
                soundEmitter:playSoundImpl("ZombieSurprisedPlayer",sharedData.GetPlayer()) -- play local sound
            end
        end
    end

    zombie:setFakeDead(false)
    -- zombie:DoZombieStats()

end


local function ChangeZombieSpeedAfterStanding(bzmModData,zombie)
    
    if not bzmModData then
        return
    end

    local sandboxOptions = GetSandboxOptions()
    local defaultZombieSpeed = sandboxOptions:getOptionByName(BZM_Enums.SandboxLore.ZombieSpeed):getValue()

    zombie:setCanWalk(true)

    local wakeupType = bzmModData[BZM_Enums.ModDataValue.WakeupType]

    if not wakeupType then
        BZM_Utils.DebugPrint("AYYYYYYY YO THIS ZOMBIE DOESNT HAVE WAKE UP TYPE")
        wakeupType = defaultZombieSpeed
    end

    -- set zombie type
    sandboxOptions:set(BZM_Enums.SandboxLore.ZombieSpeed,wakeupType)

    zombie:makeInactive(true)
    zombie:makeInactive(false)
    
    bzmModData[BZM_Enums.ModDataValue.StartStanding] = false

    -- this line somehow prevents the sudden jump form crawling to standing
    zombie:DoZombieSpeeds(0.86)

    sandboxOptions:set(BZM_Enums.SandboxLore.ZombieSpeed,defaultZombieSpeed)

end

local function WakeUpTheDead(bzmModData,zombie)

    if not bzmModData then
        BZM_Utils.DebugPrintWithBanner("NO Moddata found",true)
        return
    end

    local sandboxOptions =  GetSandboxOptions()
    local sandboxLoreSpeed = BZM_Enums.SandboxLore.ZombieSpeed
    local defaultZombieSpeed = sandboxOptions:getOptionByName(sandboxLoreSpeed):getValue()

    local wakeupType = bzmModData[BZM_Enums.ModDataValue.WakeupType]

    sandboxOptions:set(sandboxLoreSpeed,2)

    zombie:setCanWalk(false)
    zombie:setCrawler(true)
    zombie:setFallOnFront(true)
    zombie:setOnFloor(true)
    zombie:DoZombieStats()
    zombie:DoZombieSpeeds(0.56) -- magic number that makes zombie goes crawler

    -- if wakeupType == FakeDeadWakeupType.Crawlers then
    --     zombie:setCanWalk(false)
    --     zombie:setCrawler(true)
    --     zombie:setFallOnFront(true)
    --     zombie:setOnFloor(true)
    --     zombie:DoZombieStats()
    --     zombie:DoZombieSpeeds(0.56) -- magic number that makes zombie goes crawler
    -- else

    --     zombie:setCanWalk(true)
    --     -- zombie:setFallOnFront(true)
    --     zombie:setOnFloor(true)
        
    --     zombie:makeInactive(true)
    --     zombie:makeInactive(false)

    --     zombie:DoZombieSpeeds(0.86) -- magic number that makes zombie goes walking
    --     modData[startStandingStr] = true
    -- end

    if wakeupType ~= BZM_Enums.FakeDeadWakeupType.Crawlers then
        bzmModData[BZM_Enums.ModDataValue.StartStanding] = true
    end

    -- zombie:setTurnDelta(20.0) -- doesn't work
    
    bzmModData[BZM_Enums.ModDataValue.JustRevive] = false

    sandboxOptions:set(sandboxLoreSpeed,defaultZombieSpeed)

end

local function RemoveSound()
    concerningNoises = nil -- deallocation
    Events.OnPostRender.Remove(RemoveSound)
end

local function OnWorldSound(x,y,z,radius,volume,source)

    -- BZM_Utils.DebugPrintWithBanner("On Someone sound at volume: "..volume,true)
    -- BZM_Utils.DebugPrint("At radius: "..radius)

    local activeNoiseVolume = SandboxVars.BetterZedManager.FakeDeadsActiveVolume

    if volume < activeNoiseVolume then
        return
    end

    -- if not concerningNoises then
    --     concerningNoises = {}
    -- end

    concerningNoises = {
        posX = x,
        posY = y,
        radius = radius
    }

    Events.OnPostRender.Add(RemoveSound)

end

local function OnHitZombie(zombie, character, bodyPartType, handWeapon)
    
    local thisPlayerId = sharedData.GetPlayer():getOnlineID()
    local hittingPlayerId = character:getOnlineID()

    if not zombie:isDead() and zombie:isFakeDead() then
        
        local ourModData = zombie:getModData()[BZM_Enums.ModDataValue.BZM_Data]
        fakeDeadUpdate.PreparingWakeUp(ourModData,zombie,thisPlayerId == hittingPlayerId,false)

    end
end


local function OnZombieUpdate(zombie)

    local zombieID = zombie:getOnlineID()
    local modData = zombie:getModData()

    if not modData[BZM_Enums.ModDataValue.BZM_Data] then
        
        -- if modData is not available maybe this zombie doesn't exist on this client
        -- need to check the shared memory and add the appropiate data
        -- BZM_Utils.InitFakeDeadModData(modData,zombieID,sharedData.ZombieMemory)
        
        local clientZombieMemo = sharedData.ZombieMemory
        
        local thisZombieData = clientZombieMemo[zombieID]

        if not thisZombieData then
            return -- have no data here
        end

        local wakeupType = thisZombieData[BZM_Enums.Memo.WakeupType]
        
        if not wakeupType then
            -- not yet evaluated from the server
            return
        end

        modData[BZM_Enums.ModDataValue.BZM_Data] = {} -- initialize our zone of table
        modData[BZM_Enums.ModDataValue.BZM_Data][BZM_Enums.ModDataValue.WakeupType] = wakeupType
    
    end
    
    local ourModData = modData[BZM_Enums.ModDataValue.BZM_Data]

    if not ourModData then
        return
    end


    -- local clientMemo = sharedData.ZombieMemory
    -- if clientMemo[zombieID][BZM_Enums.Memo.IsAlreadyWake] then

    if ourModData[BZM_Enums.ModDataValue.StartStanding] then
        ChangeZombieSpeedAfterStanding(ourModData,zombie)
        return
    end

    if ourModData[BZM_Enums.ModDataValue.JustRevive] then
        -- actually waking up as a crawler
        BZM_Utils.DebugPrint("Waking up this zombie: "..zombieID)
        WakeUpTheDead(ourModData,zombie)
        return
    end

    if not zombie:isFakeDead() then

        -- control when another player brings a fake dead over to this player cell
        -- then we have to tell this player to wake that fake dead
        local thisZombieData = sharedData.ZombieMemory[zombieID]
    
        if thisZombieData and thisZombieData[BZM_Enums.Memo.AwakeLater] then
            thisZombieData[BZM_Enums.Memo.AwakeLater] = false
            fakeDeadUpdate.PreparingWakeUp(ourModData,zombie,false,false)
        end

        return
    else

        -- check if there's a concerning noise
        local zombieSquare = zombie:getCurrentSquare()
        local isNearSoundSource = BZM_Utils.IsSquareNearPos

        -- sanity check
        if concerningNoises and zombieSquare then

            local isNear = isNearSoundSource(concerningNoises.posX,concerningNoises.posY,zombieSquare,concerningNoises.radius)
            if isNear then
                BZM_Utils.DebugPrintWithBanner("Zombie Wake by sound id: "..zombieID,true)
                fakeDeadUpdate.PreparingWakeUp(ourModData,zombie,true,false)
                return
            end

        end

        -- sanity check
        if zombieSquare then
                    -- check if player is near the zombie
        local player = sharedData.GetPlayer()
        local playerSquare = player:getCurrentSquare()
        local distanceToWake = tonumber(SandboxVars.BetterZedManager.FakeDeadsWakeupDistance)
        local isnear = BZM_Utils.IsSquareNearSquare(playerSquare,zombieSquare,distanceToWake)
        
            if isnear and zombie:CanSee(player) then
                BZM_Utils.DebugPrintWithBanner("Player Near: "..zombieID,true)
                fakeDeadUpdate.PreparingWakeUp(ourModData,zombie,true,true)
                return
            end

        end


        -- prevent the zombie to stand up
        zombie:setFallOnFront(true)
        zombie:setCanWalk(false)
        zombie:setCrawler(true)
        zombie:setOnFloor(true)
        zombie:DoZombieStats()

        
    end


end

local function InitVariables()
    
    local isEnableFakeDead = SandboxVars.BetterZedManager.EnableFakeDeads

    BZM_Utils.DebugPrintWithBanner("EnableFakeDeads: "..tostring(isEnableFakeDead),true)
    
    if isEnableFakeDead then
        -- Events.OnCreatePlayer.Add(OnCreatePlayer) -- call once after player click screen
        Events.OnZombieUpdate.Add(OnZombieUpdate)
        Events.OnWorldSound.Add(OnWorldSound)
        -- Events.OnRenderTick.Add(OnPostRender)
        Events.OnHitZombie.Add(OnHitZombie)
    end

end

Events.OnLoad.Add(InitVariables)

return fakeDeadUpdate
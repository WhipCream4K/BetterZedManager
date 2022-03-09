-- handles the timer that will call for zombie respawn

-- modules stack
local BZM_Commands          = require("BZM_Commands")
local BZM_Utils             = require("BZM_Utils")
local BZM_Enums             = require("BZM_Enums")

-- variable stack
local rerollCounterInMins   = 0
local rerollLimitInMins     = 0
local rerollEvent           = nil

local resetCounterInMins    = 0
local resetLimitInMins      = 0
local resetEvent            = nil

local isModDisable          = false

-- function stack
local GetGameTime           = getGameTime
local SendServerCMD         = sendServerCommand

local function CallRespawn()
    SendServerCMD(BZM_Enums.OnlineModule,BZM_Commands.QueryClientZombies,{})
end

local function CountToRespawn()

    rerollCounterInMins = rerollCounterInMins + 1

    if(rerollCounterInMins >= rerollLimitInMins) then
        rerollCounterInMins = 0
        CallRespawn()
    end

end

local function CallReset()
    SendServerCMD(BZM_Enums.OnlineModule,BZM_Commands.ResetServerMemo,{})
end

local function CountToReset()
    
    resetCounterInMins = resetCounterInMins + 1

    if(resetCounterInMins >= resetLimitInMins) then
        ResetServerMemo()
        resetCounterInMins = 0
        CallReset()
    end

end

local function SetActiveMod(value)
    if value then
        rerollCounterInMins = 0
        resetCounterInMins = 0
        rerollEvent.Remove(CountToRespawn)
        resetEvent.Remove(CountToReset)
    else
        rerollEvent.Add(CountToRespawn)
        resetEvent.Add(CountToReset)
    end
end

local function ModDisableCheck()

    local gameHours = GetGameTime():getHour()
    local sandboxVars = SandboxVars.BetterZedManager

    BZM_Utils.DebugPrintWithBanner("Game Hours: "..gameHours,false)
    
    if not isModDisable and gameHours >= sandboxVars.DisableFrom then
        isModDisable = true
        BZM_Utils.DebugPrint("BetterZedManager now disable: ")
        SetActiveMod(false)
    elseif gameHours >= sandboxVars.DisableTo and isModDisable then
        BZM_Utils.DebugPrint("BetterZedManager now enable: ")
        isModDisable = false
        SetActiveMod(true)
    end

end



local function ShouldModDisableFirstFrame()
    
    local gameHours = GetGameTime():getHour()
    local sandboxVars = SandboxVars.BetterZedManager
    local disableFrom = sandboxVars.DisableFrom
    local disableTo = sandboxVars.DisableTo

    if disableFrom >= gameHours or gameHours <= disableTo then
        isModDisable = true
        SetActiveMod(false)
    end
    
    BZM_Utils.DebugPrintWithBanner("Should not disable this mod first frame",false)

    Events.EveryHours.Add(ModDisableCheck)
    Events.EveryOneMinute.Remove(ShouldModDisableFirstFrame)

end

local function InitVariables()

    local currentSandbox = SandboxVars.BetterZedManager

    rerollLimitInMins = currentSandbox.RespawnTimeInMinutes

    if rerollLimitInMins > 0 then
        rerollEvent = Events.EveryOneMinute
        rerollEvent.Add(CountToRespawn)
    end

    if currentSandbox.ZombieMemoryCleaningMethod == BZM_Enums.CleanMemMethod.CleanSpecified then

        local respawnTime = currentSandbox.RespawnTimeInMinutes
        local cleanTime = currentSandbox.CleanTime
        local remainder = 0

        if cleanTime > respawnTime then
            remainder = cleanTime % respawnTime
        else
            remainder = respawnTime % cleanTime
        end

        -- offset the clean time so that it's not trigger at the same time slot
        if remainder == 0 then
            remainder = 3
        else
            remainder = 0
        end

        resetEvent = Events.EveryOneMinute
        resetLimitInMins = cleanTime + remainder
        resetEvent.Add(CountToReset)
    elseif currentSandbox.ZombieMemoryCleaningMethod == BZM_Enums.CleanMemMethod.CleanEveryDay then
        resetEvent = Events.EveryDays
        resetEvent.Add(CallReset)
    end

    if currentSandbox.CanBeDisabled then
        Events.EveryOneMinute.Add(ShouldModDisableFirstFrame)
    end
    
end

Events.OnGameBoot.Add(InitVariables)
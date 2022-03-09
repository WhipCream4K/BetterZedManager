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

    rerollCounterInMins = rerollCounterInMins + 1

    if(rerollCounterInMins >= rerollLimitInMins) then
        SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.QueryClientZombies,{})
        rerollCounterInMins = 0
    end

end

local function CallReset()
    
    resetCounterInMins = resetCounterInMins + 1

    if(resetCounterInMins >= resetLimitInMins) then
        ResetServerMemo()
        SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.ResetServerMemo,{})
        resetCounterInMins = 0
    end

end

local function SetActiveMod(value)
    if value then
        rerollCounterInMins = 0
        resetCounterInMins = 0
        rerollEvent.Remove(CallRespawn)
        resetEvent.Remove(CallReset)
    else
        rerollEvent.Add(CallRespawn)
        resetEvent.Add(CallReset)
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
        rerollEvent.Add(CallRespawn)
    end

    if currentSandbox.ZombieMemoryCleaningMethod == BZM_Enums.CleanMemMethod.CleanSpecified then
        resetEvent = Events.EveryOneMinute
        resetEvent.Add(CallReset)
    elseif currentSandbox.ZombieMemoryCleaningMethod == BZM_Enums.CleanMemMethod.CleanEveryDay then
        resetEvent = Events.EveryDays
        resetEvent.Add(CallReset)
    end

    if currentSandbox.CanBeDisabled then
        Events.EveryOneMinute.Add(ShouldModDisableFirstFrame)
    end
    
end

Events.OnGameBoot.Add(InitVariables)
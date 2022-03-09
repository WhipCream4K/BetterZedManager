
-- require("BZM_ZombieMemory")

local BZM_Enums     = require("BZM_Enums")
local BZM_Commands  = require("BZM_Commands")

local sharedData = {
    zombieMemory = ZombieMemory:New(),
    thisPlayerIndex = 0
}

-- function stack
local GetPlayer     = getSpecificPlayer
local SendClientCMD = sendClientCommand

sharedData.GetPlayer = function ()
    return GetPlayer(sharedData.thisPlayerIndex)
end

sharedData.GetZombiesInCell = function ()
    
    local player = GetPlayer(sharedData.thisPlayerIndex)
    if not player then
        return
    end

    local playerCell = player:getCell()
    if not playerCell then
        return
    end

    return playerCell:getZombieList()
    
end

local function SyncWhenEnter()

    -- at the first frame we need to sync all previous zombie memory from the server
    SendClientCMD(BZM_Enums.OnlineModule,BZM_Commands.SyncServerZombiesIndividual,{})
    Events.EveryTenMinutes.Remove(SyncWhenEnter)
    
end

local function OnCreatePlayer(playerIndex,player)
    sharedData.thisPlayerIndex = playerIndex
    Events.EveryTenMinutes.Add(SyncWhenEnter)
end

Events.OnCreatePlayer.Add(OnCreatePlayer)

return sharedData
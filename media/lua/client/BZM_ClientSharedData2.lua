
require("BZM_ZombieMemory")

local sharedData = {
    zombieMemory = ZombieMemory:New(),
    thisPlayerIndex = 0
}

-- function stack
local GetPlayer     = getSpecificPlayer

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

local function OnPlayerCreate(playerIndex,player)
    sharedData.thisPlayerIndex = playerIndex
end

Events.OnPlayerCreate.Add(OnPlayerCreate)

return sharedData
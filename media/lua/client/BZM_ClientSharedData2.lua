
require("BZM_ZombieMemory")

local sharedData = {
    zombieMemory = ZombieMemory:New(),
    thisPlayerIndex = 0
}

local function OnPlayerCreate(playerIndex,player)
    sharedData.thisPlayerIndex = playerIndex
end

Events.OnPlayerCreate.Add(OnPlayerCreate)

return sharedData
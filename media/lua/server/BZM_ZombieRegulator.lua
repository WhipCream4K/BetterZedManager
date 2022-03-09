-- handles the zombies regulation through out the client and server

local regulator = {}

-- modules stack
local BZM_Commands      = require("BZM_Commands")
local BZM_Utils         = require("BZM_Utils")
local BZM_Enums         = require("BZM_Enums")

-- variables stack
local clientCounter     = 0

-- functions stack
local GetOnlinePlayers = getOnlinePlayers

-- export funciton
regulator.RoundUpZombies = function (playerOnlineID,zombieList,outZombieMemory,checkAgainstMemo)

    if not zombieList then
        return
    end
    
    BZM_Utils.DebugPrintWithBanner("Gathering player's zombies: "..playerOnlineID)

    -- as ArrayList<IsoPlayers>
    local onlinePlayers = GetOnlinePlayers() -- should be fine to call
    local totalOnlinePlayers = onlinePlayers:size()

    BZM_Utils.DebugPrintWithBanner("Total Players: "..totalOnlinePlayers)

    -- sanity check
    if totalOnlinePlayers <= 0 then
        return
    end

    clientCounter = clientCounter + 1

    -- if clientCounter == 1 then -- if it's the first one calling then we reset the temp memo
    --     outZombieMemory = {}
    -- end

    BZM_Utils.DebugPrintWithBanner("Client Counter : "..clientCounter)
    
    local counter = 0
    local checkAgainstZombieMemo = checkAgainstMemo:GetTable()

    for i = 1, #zombieList, 1 do
        -- this guaruntee the uniqueness of zombies by making it a set
        if not checkAgainstZombieMemo[zombieList[i]] then

            outZombieMemory[zombieList[i]] = {}
            checkAgainstZombieMemo[zombieList[i]] = {}

            counter = counter + 1
        end
        
    end

    BZM_Utils.DebugPrint("Total zombies in this player: "..counter)

    if clientCounter >= totalOnlinePlayers then
        clientCounter = 0
        return true
    end

    return false

end

return regulator

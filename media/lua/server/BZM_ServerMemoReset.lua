require("BZM_ZombieMemory")

local serverReset = {}

-- modules stack
local BZM_Enums         = require("BZM_Enums")
local BZM_Utils         = require("BZM_Utils")

-- variables stack
local clientCounter     = 0

-- function stack
local GetOnlinePlayers  = getOnlinePlayers

serverReset.Reset = function (playerOnlineID,serverMemo,clientMemo)
    
    if clientMemo then
        
        local listOfTypes   = {BZM_Enums.Memo.ZombieType,BZM_Enums.Memo.WakeupType}
        BZM_Utils.DebugPrintWithBanner("Resetting Player's ZombieMemo: "..playerOnlineID)
        serverMemo:UpdateDataPerType(clientMemo,listOfTypes)

    end

    -- as ArrayList<IsoPlayers>
    local onlinePlayers = GetOnlinePlayers() -- should be fine to call
    local totalOnlinePlayers = onlinePlayers:size()
    BZM_Utils.DebugPrintWithBanner("Total Players: "..totalOnlinePlayers)      

    clientCounter = clientCounter + 1

    if clientCounter >= totalOnlinePlayers then
        return true
    end

    return false

end

return serverReset
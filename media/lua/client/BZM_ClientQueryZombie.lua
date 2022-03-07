-- handle querying all zombies in player cell to server

local queryZombie = {}

-- module stack
local sharedData            = require("BZM_ClientSharedData")
local BZM_Utils             = require("BZM_Utils")
local BZM_Enums             = require("BZM_Enums")
local BZM_Commands          = require("BZM_Commands")

-- variables stack
local interestZombieStates = {"idle","sitting"}

-- function stack
local SendClientCMD         = sendClientCommand


-- export this function
queryZombie.QueryAndUpdateZombieMemo = function (clientMemo)
    
    local zombieList = sharedData.GetZombiesInCell()
    
    -- if not outZombiememory then
    --     BZM_Utils.DebugPrintWithBanner("ZombieMemory not valid",true)
    --     return
    -- end

    local isValueInList  = BZM_Utils.IsValueInList
    local filterList     = nil
    
    -- local cleaningMethod = SandboxVars.BetterZedManager.ZombieMemoryCleaningMethod
    
    -- if cleaningMethod == BZM_Enums.CleanMemMethod.AlwaysClean then
    --     sharedData.ZombieMemory = {}
    -- end
    -- local tempZombieMemo = clientMemo
    local zombieObjStr = BZM_Enums.Memo.ZombieObj

    for i = 0, zombieList:size() - 1,1 do
        
        local zombie = zombieList:get(i)
        local zombieID = zombie:getOnlineID()

        if not clientMemo[zombieID] then
            local realState = zombie:getRealState()
            if isValueInList(realState,interestZombieStates) then

                if not filterList then
                    BZM_Utils.DebugPrintWithBanner("Create filterList",true)                 
                    filterList = {}
                end

                -- BZM_Utils.DebugPrint("Valid ZombieID: "..zombieID)
                
                filterList[#filterList+1] = zombieID
            end

            -- assigne zombieobj to the client memo
            clientMemo[zombieID] = {}
            clientMemo[zombieID][zombieObjStr] = zombie

        end

        -- if we never clean then the temp will be a reference and we will keep appending the set
        -- else if we always clean the memory will be released and we append a new set
        -- sharedData.ZombieMemory[zombieID].zombieObj = zombie
        -- tempZombieMemo[zombieID] = tempZombieMemo[zombieID] or {}
        -- tempZombieMemo[zombieID][zombieObjStr] = zombie
        

        -- clientMemo[zombieID][zombieObjStr] = clientMemo[zombieID][zombieObjStr] or {}
        -- clientMemo[zombieID][zombieObjStr] = zombie

    end

    return filterList
    -- if not filterList then
    --     BZM_Utils.DebugPrintWithBanner("Some how nil",true)
    --     return
    -- end

    -- SendClientCMD(sharedData.GetPlayer(),BZM_Enums.BZM_OnlineModule,BZM_Commands.ReRollZombies,filterList)

end

return queryZombie
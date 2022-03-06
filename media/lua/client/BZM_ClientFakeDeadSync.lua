-- handle syncroziation of fake deads

-- module stack
local fakeDeadUpdate        = require("BZM_ClientZombieUpdate")
local BZM_Utils             = require("BZM_Utils")
local sharedData            = require("BZM_ClientSharedData")
local BZM_Enums             = require("BZM_Enums")

-- variable stack
local fakeDeadSync          = {}

fakeDeadSync.SyncFakeDeadsFirstFrame = function ()
    
    local zombieList = sharedData.GetZombiesInCell()
    local clientZombieMemo = sharedData.ZombieMemory

    for i = 0, zombieList:size() - 1,1 do
        local zombie = zombieList:get(i)
        local zombieID = zombie:getOnlineID()

        local zombieData = clientZombieMemo[zombieID]
        if zombieData then
            
            -- if this memo has wake up type then it's a fake dead
            -- call it to lie on front
            local wakeupType = zombieData[BZM_Enums.Memo.WakeupType]
            if wakeupType then
                
                zombie:setFallOnFront(true)

            end
            
        end
        
    end

    Events.OnPostRender.Remove(fakeDeadSync.SyncFakeDeadsFirstFrame)

end

-- export this function
fakeDeadSync.SyncFakeDeads = function (zombieID)

    local zombie = sharedData.ZombieMemory[zombieID][BZM_Enums.Memo.ZombieObj]

    if not zombie then
        -- if we can't find zombie this frame that means
        -- we don't have that zombie in our cell right now

        -- we will ask our memory to see if we know the existance of this zombie
        local zombieData = sharedData.RevalidateClientMemory(zombieID)
        
        -- we already revalidate the code but still there's no zombie in our range so we can't do anything
        if not zombieData then
            BZM_Utils.DebugPrintWithBanner("This ZombieID: "..zombieID.." doesn't exist in this player cell: "..sharedData.ThisPlayerIndex,true)
            return
        else

            -- if it exist in our memory but we don't have it in the cell then
            -- we just have it update later in our fake update
            local isInCellRightNow = zombieData[BZM_Enums.Memo.ZombieObj]

            if not isInCellRightNow then
                return
            else   
                zombie = isInCellRightNow
            end
        end

        return
    end

    BZM_Utils.DebugPrintWithBanner("Syncing with server, Zombie ID: "..zombieID,true)

    local ourModData = zombie:getModData()[BZM_Enums.ModDataValue.BZM_Data]
    fakeDeadUpdate.PreparingWakeUp(ourModData,zombie,false)

end

return fakeDeadSync
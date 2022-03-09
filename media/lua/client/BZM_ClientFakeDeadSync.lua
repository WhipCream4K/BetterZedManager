-- handle syncroziation of fake deads

-- module stack
local fakeDeadUpdate        = require("BZM_ClientFakeDeadUpdate")
local BZM_Utils             = require("BZM_Utils")
-- local sharedData            = require("BZM_ClientSharedData")
local sharedData            = require("BZM_ClientSharedData2")
local zombieManager         = require("BZM_ZombieManager")
local BZM_Enums             = require("BZM_Enums")

-- variable stack
local fakeDeadSync          = {}

-- fakeDeadSync.SyncFakeDeadsFirstFrame = function ()
    
--     local zombieList = sharedData.GetZombiesInCell()
--     local clientZombieMemo = sharedData.ZombieMemory

--     for i = 0, zombieList:size() - 1,1 do
--         local zombie = zombieList:get(i)
--         local zombieID = zombie:getOnlineID()

--         local zombieData = clientZombieMemo[zombieID]
--         if zombieData then
            
--             -- if this memo has wake up type then it's a fake dead
--             -- call it to lie on front
--             local wakeupType = zombieData[BZM_Enums.Memo.WakeupType]
--             if wakeupType then
            
--                 print("ZombieID: "..zombieID.." Fall on front")
--                 zombie:setFallOnFront(true)

--             end
            
--         end
        
--     end

--     Events.OnPostRender.Remove(fakeDeadSync.SyncFakeDeadsFirstFrame)

-- end

-- export this function
fakeDeadSync.SyncFakeDeads = function (zombieID)

    local clientMemo = sharedData.zombieMemory

    -- local thisFakeDeadData = clientMemo[zombieID]
    
    if not clientMemo:IsExist(zombieID) then
        -- we can't do anything if this player doesn't have data
        -- maybe an undefined behaviour
        BZM_Utils.DebugPrintWithBanner("Syncing fake dead but this player doesn't have its data",true)
        BZM_Utils.DebugPrint("zombieID: "..zombieID)
        return
    end

    local zombie = clientMemo:GetZombieObj(zombieID)

    if not zombie then

        -- if we can't find zombie this frame that means
        -- we don't have that zombie in our cell right now

        -- we will ask our memory to see if we know the existance of this zombie
        local zombieData = zombieManager.FindAndUpdateZombies(sharedData.thisPlayerIndex,zombieID,sharedData.zombieMemory)
        
        -- if it exist in our memory but we don't have it in the cell then
        -- we just have it update later in our fake update
        if not zombieData then
            
            BZM_Utils.DebugPrintWithBanner("This ZombieID: "..zombieID.." doesn't exist in this player cell: "..sharedData.thisPlayerIndex,true)
            BZM_Utils.DebugPrint("Will save to wake later")
            -- thisFakeDeadData[BZM_Enums.Memo.AwakeLater] = true
            -- sharedData.zombieMemory:SetData(zombieID,BZM_Enums.Memo.AwakeLater,true)
            
            return
        else
    
            local someHowNoneFind = zombieData[BZM_Enums.Memo.ZombieObj]

            if not someHowNoneFind then
                return
            else   
                zombie = someHowNoneFind
            end
            
        end

    end

    
    local ourModData = zombie:getModData()[BZM_Enums.ModDataValue.BZM_Data]

    if ourModData then
        BZM_Utils.DebugPrintWithBanner("Syncing with server, Zombie ID: "..zombieID,true)
        fakeDeadUpdate.PreparingWakeUp(ourModData,zombie,false,false)
    end


end

return fakeDeadSync
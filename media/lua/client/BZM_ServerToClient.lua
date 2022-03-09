-- handle the server command

-- require("BZM_ZombieMemory")

-- modules stack
local BZM_Enums         = require("BZM_Enums")
local BZM_Commands      = require("BZM_Commands")
local BZM_Utils         = require("BZM_Utils")
local fakeDeadSync      = require("BZM_ClientFakeDeadSync")
-- local sharedData        = require("BZM_ClientSharedData")
-- local zombieQuerier     = require("BZM_ClientQueryZombie")
-- local zombieSync        = require("BZM_ClientZombieSync")
local sharedData        = require("BZM_ClientSharedData2")
local zombieManger      = require("BZM_ZombieManager")

-- variables stack

-- function stack
local GetPlayer         = getPlayerByOnlineID
local SendClientCMD     = sendClientCommand

local function ReQueryZombieInCell()

    local zombieInCell = BZM_Utils.GetZombieListFromPlayerIndex(sharedData.thisPlayerIndex)

    local sendZombieMemo = {}
    local oldZombieMemo = sharedData.zombieMemory:GetTable()
    local wakeupTypeKey = BZM_Enums.Memo.WakeupType
    local zombieTypeKey = BZM_Enums.Memo.ZombieType
    
    for i = 0, zombieInCell:size() - 1, 1 do

        local zombie = zombieInCell:get(i)
        local zombieID = zombie:getOnlineID()

        if oldZombieMemo[zombieID] then
            sendZombieMemo[zombieID] = {}
            local newData = sendZombieMemo[zombieID]
            local oldData = oldZombieMemo[zombieID]
            newData[zombieTypeKey] = oldData[zombieTypeKey]
            newData[wakeupTypeKey] = oldData[wakeupTypeKey]
        end

    end
    
    SendClientCMD(sharedData.GetPlayer(),BZM_Commands.ResetServerMemoAnswer,sendZombieMemo)

end

local function ServerToClient(module,command,args)
    
    if module == BZM_Enums.OnlineModule then
        
        if command == BZM_Commands.UpdateZombies then
            
            local serverMemo = ZombieMemory:NewFromTable(args)
            sharedData.zombieMemory:UpdateData(serverMemo)
            zombieManger.UpdateClientZombies(sharedData.zombieMemory,serverMemo)

        elseif command == BZM_Commands.QueryClientZombies then

            local thisFrameZombies = zombieManger.QueryZombiesAgainstMemory(sharedData.thisPlayerIndex,sharedData.zombieMemory)
            SendClientCMD(sharedData.GetPlayer(),BZM_Enums.OnlineModule,BZM_Commands.ReRollZombies,thisFrameZombies)
            
        elseif command == BZM_Commands.SyncFakeDead then
            
            local myOnlineID = sharedData.GetPlayer():getOnlineID() or GetPlayer(sharedData.ThisPlayerIndex):getOnlineID()

            if myOnlineID ~= args[BZM_Enums.OnlineArgs.PlayerID] then
                fakeDeadSync.SyncFakeDeads(args[BZM_Enums.OnlineArgs.ZombieID])
            end

        elseif command == BZM_Commands.SyncServerZombiesIndividual then
            
            local myOnlineID = sharedData.GetPlayer():getOnlineID() or GetPlayer(sharedData.ThisPlayerIndex):getOnlineID()
            if myOnlineID == args[BZM_Enums.OnlineArgs.PlayerID] then

                -- server already check for us
                BZM_Utils.DebugPrintWithBanner("Get information from previous zombie memo",true)
                local serverMemo = ZombieMemory:NewFromTable(args[BZM_Enums.OnlineArgs.Memo])
                sharedData.zombieMemory:UpdateData(serverMemo)

            end
        elseif command == BZM_Commands.ResetServerMemo then
            ReQueryZombieInCell()
        elseif command == BZM_Commands.ResetClientMemo then
            
            sharedData.zombieMemory = ZombieMemory:New()
            local serverMemo = ZombieMemory:NewFromTable(args)
            sharedData.zombieMemory:UpdateData(serverMemo)

        end
    end
end


Events.OnServerCommand.Add(ServerToClient)
-- Events.OnCreatePlayer.Add(OnCreatePlayer) -- call once after player click screen

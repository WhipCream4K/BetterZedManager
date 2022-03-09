
require("BZM_ZombieMemory")

-- modules stack
local BZM_Commands      = require("BZM_Commands")
local BZM_Utils         = require("BZM_Utils")
local BZM_Enums         = require("BZM_Enums")
local regulator         = require("BZM_ZombieRegulator")
local randomzier        = require("BZM_ZombieRandomizer")
local memoReset         = require("BZM_ServerMemoReset")

-- variables stack
local serverPresistentZombieMemo = ZombieMemory:New()
local serverTempZombieMemo       = {}

-- functions stack
local SendServerCMD     = sendServerCommand

function ResetServerMemo()
    serverPresistentZombieMemo = ZombieMemory:New()
end

-- this function is trivial it can live here
local function BroadcastSyncFakeDeads(playerOnlineID,zombieArgs)

    if zombieArgs == nil then
        return
    end
    
    local onlineData = {}
    onlineData[BZM_Enums
    .OnlineArgs.PlayerID] = playerOnlineID
    onlineData[BZM_Enums.OnlineArgs.ZombieID] = zombieArgs[BZM_Enums.OnlineArgs.ZombieID]


    BZM_Utils.DebugPrintWithBanner("Please Sync this zombie: "..zombieArgs[BZM_Enums.OnlineArgs.ZombieID],false)

    SendServerCMD(BZM_Enums.OnlineModule,BZM_Commands.SyncFakeDead,onlineData)

end

local function OnClientToServer(module,command,player,args)

    if module == BZM_Enums.OnlineModule then
        
        if command == BZM_Commands.ReRollZombies then
            
            if regulator.RoundUpZombies(player:getOnlineID(),args,serverTempZombieMemo,serverPresistentZombieMemo) then
                local newRollList = randomzier.RandomAndUpdateMemory(serverTempZombieMemo,serverPresistentZombieMemo)
                if newRollList then
                    serverTempZombieMemo = {} -- reset the temp
                    -- server can't parse the lua class or I don't know how to
                    SendServerCMD(BZM_Enums.OnlineModule,BZM_Commands.UpdateZombies,newRollList:GetTable())
                end
            end

            
        elseif command == BZM_Commands.SyncServerZombiesIndividual then

            if serverPresistentZombieMemo then

                local serverZombieMemo = serverPresistentZombieMemo:GetTable()
                local onlineArgs = {}
                onlineArgs[BZM_Enums.OnlineArgs.PlayerID] = player:getOnlineID()
                onlineArgs[BZM_Enums.OnlineArgs.Memo] = serverZombieMemo
                
                -- debuging
                local counter = 0
                for _, _ in pairs(serverZombieMemo) do
                   counter = counter + 1
                --    BZM_Utils.DebugPrint("ZombieType: "..value[BZM_Enums.Memo.ZombieType].." wakeupType: "..value[BZM_Enums.Memo.WakeupType])
                end

                if counter > 0 then
                    
                    BZM_Utils.DebugPrintWithBanner("Player: "..player:getOnlineID().." requesting server's zombie memory")
                    BZM_Utils.DebugPrint("Total saved zombies: "..counter)
    
                    SendServerCMD(BZM_Enums.OnlineModule,BZM_Commands.SyncServerZombiesIndividual,onlineArgs)

                end

            end

        elseif command == BZM_Commands.SyncFakeDead then

            BroadcastSyncFakeDeads(player:getOnlineID(),args)

        elseif command == BZM_Commands.ResetServerMemo then

            local clientMemo = ZombieMemory:NewFromTable(args or {})
            if memoReset.Reset(player:getOnlineID(),serverPresistentZombieMemo,clientMemo) then
                SendServerCMD(BZM_Enums.OnlineModule,BZM_Commands.ResetClientMemo,serverPresistentZombieMemo:GetTable()) -- send raw data version of memo
            end

        end
    end

end

Events.OnClientCommand.Add(OnClientToServer)

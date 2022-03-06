
-- modules stack
local BZM_Commands      = require("BZM_Commands")
local BZM_Utils         = require("BZM_Utils")
local BZM_Enums         = require("BZM_Enums")
local regulator         = require("BZM_ZombieRegulator")
local randomzier        = require("BZM_ZombiesRandomizer")

-- variables stack
-- local serverPresistentZombieMemo = {}
local serverZombieMemo           = {}

-- functions stack
local SendServerCMD     = sendServerCommand

-- this function is trivial it can live here
local function BroadcastSyncFakeDeads(playerOnlineID,zombieArgs)

    if zombieArgs == nil then
        return
    end
    
    local onlineData = {}
    onlineData[BZM_Enums.OnlineArgs.PlayerID] = playerOnlineID
    onlineData[BZM_Enums.OnlineArgs.ZombieID] = zombieArgs[BZM_Enums.OnlineArgs.ZombieID]

    -- local posX = zombieArgs["posX"]
    -- local posY = zombieArgs["posY"]
    -- local posZ = zombieArgs["posZ"]

    BZM_Utils.DebugPrintWithBanner("Please Sync this zombie: "..zombieArgs[BZM_Enums.OnlineArgs.ZombieID],false)

    SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.SyncFakeDead,onlineData)

end

local function OnClientToServer(module,command,player,args)

    if module == BZM_Enums.BZM_OnlineModule then
        
        if command == BZM_Commands.ReRollZombies then
            
            -- serverZombieMemo = {} -- time to reset

            if regulator.RoundUpZombies(player:getOnlineID(),args,serverZombieMemo) then
                local newRollList = randomzier.Random(serverZombieMemo)

                if newRollList then
                    SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.UpdateZombies,newRollList)
                end
            end

            
        elseif command == BZM_Commands.SyncServerZombiesIndividual then

            if serverZombieMemo then

                local onlineArgs = {}
                onlineArgs[BZM_Enums.OnlineArgs.PlayerID] = player:getOnlineID()
                onlineArgs[BZM_Enums.OnlineArgs.Memo] = serverZombieMemo
                
                SendServerCMD(BZM_Enums.BZM_OnlineModule,BZM_Commands.SyncServerZombiesIndividual,onlineArgs)
            end

        elseif command == BZM_Commands.SyncFakeDead then
            
            BroadcastSyncFakeDeads(player:getOnlineID(),args)

        end
    end

end

Events.OnClientCommand.Add(OnClientToServer)

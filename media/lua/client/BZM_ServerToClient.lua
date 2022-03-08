-- handle the server command

-- modules stack
local BZM_Enums         = require("BZM_Enums")
local BZM_Commands      = require("BZM_Commands")
local BZM_Utils         = require("BZM_Utils")
local fakeDeadSync      = require("BZM_ClientFakeDeadSync")
local sharedData        = require("BZM_ClientSharedData")
local zombieQuerier     = require("BZM_ClientQueryZombie")
local zombieSync        = require("BZM_ClientZombieSync")
local sharedData2       = require("BZM_ClientSharedData2")
local zombieManger      = require("BZM_ClientZombieManager")

-- variables stack

-- function stack
local GetPlayer         = getPlayerByOnlineID
local SendClientCMD     = sendClientCommand

local function ServerToClient(module,command,args)
    
    if module == BZM_Enums.BZM_OnlineModule then
        
        if command == BZM_Commands.UpdateZombies then
            
            -- UpdateClientZombies(args)
            -- sharedData.UpdeadMemoryFirstFrame(args)
            zombieSync.UpdateClientZombies(args,sharedData.ZombieMemory)

            sharedData2.zombieMemory:UpdateData(args)
            zombieManger.UpdateClientZombies(sharedData2.zombieMemory)

        elseif command == BZM_Commands.QueryClientZombies then

            local thisFrameZombies = zombieQuerier.QueryAndUpdateZombieMemo(sharedData.ZombieMemory)
            SendClientCMD(sharedData.GetPlayer(),BZM_Enums.BZM_OnlineModule,BZM_Commands.ReRollZombies,thisFrameZombies)
            
        elseif command == BZM_Commands.SyncFakeDead then
            
            local myOnlineID = sharedData.GetPlayer():getOnlineID() or GetPlayer(sharedData.ThisPlayerIndex):getOnlineID()

            if myOnlineID ~= args[BZM_Enums.OnlineArgs.PlayerID] then
                
                fakeDeadSync.SyncFakeDeads(args[BZM_Enums.OnlineArgs.ZombieID])
                
            end

        elseif command == BZM_Commands.SyncServerZombiesIndividual then
            
            local myOnlineID = sharedData.GetPlayer():getOnlineID() or GetPlayer(sharedData.ThisPlayerIndex):getOnlineID()
            if myOnlineID == args[BZM_Enums.OnlineArgs.PlayerID] then
                
                
                local isTableValid = false
                for _, _ in pairs(args[BZM_Enums.OnlineArgs.Memo]) do
                    isTableValid = true
                    break
                end
                
                if isTableValid then

                    BZM_Utils.DebugPrintWithBanner("Get information from previous zombie memo",true)
                    sharedData.UpdeadMemoryFirstFrame(args[BZM_Enums.OnlineArgs.Memo])
            
                    -- fakeDeadSync.SyncFakeDeadsFirstFrame()
                    -- make the client update the game after the first render
                    -- Events.OnPostRender.Add(fakeDeadSync.SyncFakeDeadsFirstFrame)
                end

            end

        end
    end
end


Events.OnServerCommand.Add(ServerToClient)
-- Events.OnCreatePlayer.Add(OnCreatePlayer) -- call once after player click screen

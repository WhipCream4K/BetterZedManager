
ZombieMemory = {}
ZombieMemory.__index = ZombieMemory

-- modules stack
local BZM_Enums     = require("BZM_Enums")
local BZM_Utils     = require("BZM_Utils")

function ZombieMemory:New()
    local this = {
        data = {}
    }
    setmetatable(this,ZombieMemory)
    return this
end

function ZombieMemory:GetData(zombieID,dataType)
    local table = self.data[zombieID]
    if not table then
        return nil
    end

    return table[dataType]

end

function ZombieMemory:GetZombieType(zombieID)
    return self.GetData(zombieID,BZM_Enums.Memo.ZombieType)
end

function ZombieMemory:SetData(zombieID,dataType,value)
    local table = self.data[zombieID]

    if not table then
        return false
    end

    table[dataType] = value

    return true
end

function ZombieMemory:IsExist(zombieID)
    return self.data[zombieID] ~= nil
end

function ZombieMemory:GetDataByZombieID(zombieID)
    return self.data[zombieID]
end

function ZombieMemory:GetTable()
    return self.data
end

---update data according to another zombie memo
---@param zombieMemory table
function ZombieMemory:UpdateData(zombieMemory)
    
    local anotherZombieData = zombieMemory:GetTable()

    local zombieTypeKey =  BZM_Enums.Memo.ZombieType
    local wakeupTypeKey = BZM_Enums.Memo.WakeupType
    
    BZM_Utils.DebugPrintWithBanner("Updating ZombieMemory",true)
    for zombieID, dataTable in pairs(anotherZombieData) do
        local ourTable = self.data[zombieID]

        if not ourTable then
            self.data[zombieID] = {}
            ourTable = self.data[zombieID]
        end

        ourTable[zombieTypeKey] = dataTable[zombieTypeKey]
        ourTable[wakeupTypeKey] = dataTable[wakeupTypeKey]

    end

end

function ZombieMemory:UpdateDataPerType(zombieMemory,typesSet)

    local anotherZombieData = zombieMemory:GetTable()

    -- local zombieTypeKey =  BZM_Enums.Memo.ZombieType
    -- local wakeupTypeKey = BZM_Enums.Memo.WakeupType
    
    BZM_Utils.DebugPrintWithBanner("Updating ZombieMemory",true)
    for zombieID, dataTable in pairs(anotherZombieData) do
        local ourTable = self.data[zombieID]

        if not ourTable then
            self.data[zombieID] = {}
            ourTable = self.data[zombieID]
        end

        for _, value in pairs(typesSet) do
            ourTable[value] = dataTable[value]
        end

    end
    
end





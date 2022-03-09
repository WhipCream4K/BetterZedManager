
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

function ZombieMemory:NewFromTable(other)
    local this = {
        data = other
    }
    setmetatable(this,ZombieMemory)
    return this
end

function ZombieMemory:GetDataType(zombieID,dataType)

    local s = self.data[zombieID]

    if not s then
        return nil
    end

    return s[dataType]

end

function ZombieMemory:GetOrCreateDataByZombieID(zombieID)

    local s = self.data[zombieID]

    if not s then
        self.data[zombieID] = {}
        return self.data[zombieID]
    end

    return s

end

function ZombieMemory:GetZombieType(zombieID)
    return self:GetDataType(zombieID,BZM_Enums.Memo.ZombieType)
end

function ZombieMemory:GetZombieObj(zombieID)
    return self:GetDataType(zombieID,BZM_Enums.Memo.ZombieObj)
end

function ZombieMemory:SetData(zombieID,dataType,value)
    
    local s = self.data[zombieID]

    if not s then
        self.data[zombieID] = {}
        s = self.data[zombieID]
    end

    s[dataType] = value

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
---@param other table
function ZombieMemory:UpdateData(other)
    
    local anotherZombieData = other:GetTable()

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





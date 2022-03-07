local enums = {

    BZM_OnlineModule = "BZM_OnlineModule",

    CleanMemMethod = {
        AlwaysClean     = 1,
        NeverClean      = 2,
        CleanEveryDay   = 3
    }, -- mimic enum class lmao

    ZombieType = {
        Sprinters       = 1,
        FastShamblers   = 2,
        Shamblers       = 3,
        Crawlers        = 4,
        FakeDeads       = 5
    },

    FakeDeadWakeupType = {
        Sprinters       = 1,
        FastShamblers   = 2,
        Shamblers       = 3,
        Crawlers        = 4
    },

    Memo = {
        ZombieType = "ZombieType",
        WakeupType = "WakeupType",
        ZombieObj  = "ZombieObj",
        AwakeLater = "AwakeLater"
    },
    
    ModDataValue = {
        ZombieType      = "BZM_ZombieType",
        WakeupType      = "BZM_WakeupType",
        JustRevive      = "BZM_JustRevive",
        StartStanding   = "BZM_StartStanding",
        BZM_Data        = "BZM_Zone"
    },

    SharedData = {
        ZombieMemory = "ZombieMemory"
    },

    OnlineArgs = {
        ZombieID    = "zombieID",
        PlayerID    = "playerID",
        Memo        = "ServerMemo"
    },

    SandboxLore = {
        ZombieSpeed = "ZombieLore.Speed"
    }
}


return enums

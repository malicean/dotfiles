local BAI = BAI

local GameSetupLoad = GameSetup.load
function GameSetup:load(data, ...)
    GameSetupLoad(self, data, ...)
    LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.BAI_Q)
    BAI:LoadSync()
end
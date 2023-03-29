BAI:Hook(MenuCallbackHandler, "resume_game", function(self)
    BAI:EasterEggInit()
    if managers.hud:IsHost() then
        LuaNetworking:SendToPeersExcept(1, BAI.EE_ResetSyncMessage, "")
    end
    if BAI.Update then
        BAI.Update = false
        BAI:CallEvent(BAI.EventList.Update)
    end
end)
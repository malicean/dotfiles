local BAI = BAI
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_BAI", function(sender, id, data)
    if not managers.hud then
        return
    end
    if id == BAI.SyncMessage then
        if data == BAI.data.BAI_Q then -- Host
            LuaNetworking:SendToPeer(sender, id, BAI.data.BAI_A)
        end
        if data == BAI.data.BAI_A then -- Client
            managers.hud:SetCompatibleHost(true)
            LuaNetworking:SendToPeer(1, BAI.EE_SyncMessage, BAI.data.EE_FSS1_Q)
            --LuaNetworking:SendToPeer(1, id, BAI.data.ResendAS)
        end
        if data == BAI.data.ResendAS then -- Host
            LuaNetworking:SendToPeer(sender, BAI.ASO_SyncMessage, managers.groupai:state():GetAssaultState())
        end
        if data == BAI.data.ResendTime then -- Host
            BAI:GetAssaultTime(sender)
        end
    end
    if id == BAI.AS_SyncMessage then -- Client
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultState(data)
        end
    end
    if id == BAI.ASO_SyncMessage then -- Client
        if BAI:GetOption("show_assault_states") then
            BAI:UpdateAssaultStateOverride(data, true)
        end
    end
    if id == BAI.AAI_SyncMessage then -- Client
        managers.hud:SetTimeLeft(data)
    end
    if id == BAI.EE_SyncMessage then
        if data == BAI.data.EE_FSS1_Q then -- Host
            if BAI.EasterEgg.FSS.AIReactionTimeTooHigh then
                LuaNetworking:SendToPeer(sender, id, BAI.data.EE_FSS1_A)
            end
        end
        if data == BAI.data.EE_FSS1_A then -- Client
            BAI.EasterEgg.FSS.AIReactionTimeTooHigh = true
        end
    end
    if id == BAI.EE_ResetSyncMessage then
        BAI.EasterEgg.FSS.AIReactionTimeTooHigh = false
        LuaNetworking:SendToPeer(1, BAI.EE_SyncMessage, BAI.data.EE_FSS1_Q)
    end

    -- KineticHUD
    if id == BAI.HUD.KineticHUD.DownCounter and BAI.IsClient then
        managers.hud:SetCompatibleHost()
    end
    if id == BAI.HUD.KineticHUD.SyncAssaultPhase then
        if BAI:GetOption("show_assault_states") then
            data = utf8.to_lower(data)
            if data == "control" and BAI:GetOption("show_wave_survived") then
                return
            end
            if BAI:IsOr(data, "anticipation", "build", "regroup") then
                return
            end
            BAI:UpdateAssaultState(data)
        end
    end
    -- KineticHUD
end)

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_BAI_AssaultStates_Net", function(sender, id, data)
    if id == "AssaultStates_Net" then
        if BAI:GetOption("show_assault_states") then
            if data == "control" and not managers.hud._hud_assault_corner._assault then
                BAI:UpdateAssaultState("control")
                return
            end
            if data == "control" and BAI:GetOption("show_wave_survived") then
                return
            end
            if BAI:IsOr(data, "anticipation", "build") then
                return
            end
            BAI:UpdateAssaultState(data)
        end
    end
end)
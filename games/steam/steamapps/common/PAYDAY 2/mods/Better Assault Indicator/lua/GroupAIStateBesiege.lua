if BAI.IsHost then
    BAI:PreHook(GroupAIStateBesiege, "set_wave_mode", function(self, flag)
        if managers.hud:GetAssaultMode() ~= "phalanx" and flag == "besiege" and self._hunt_mode then
            managers.hud:SetNormalAssaultOverride()
        end
    end)
end

BAI:Hook(GroupAIStateBesiege, "set_phalanx_damage_reduction_buff", function(self, damage_reduction)
    managers.hud:SetCaptainBuff(damage_reduction or 0)
end)
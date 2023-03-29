local _f_at_exit = IngameWaitingForPlayersState.at_exit
function IngameWaitingForPlayersState:at_exit(next_state)
    _f_at_exit(self, next_state)
    if self:check_is_dropin() then -- Drop-in (will never execute on host). Probably fixes both casing and assault panel visible
        BAI:DelayCall("FixBothCasingAndAssaultPanel", 1, function()
            local assault_corner = managers.hud._hud_assault_corner
            local group_ai = managers.groupai:state()
            if assault_corner and assault_corner._casing and assault_corner._assault and group_ai and not group_ai:whisper_mode() then
                assault_corner._remove_hostage_offset = nil
                assault_corner:hide_casing()
            end
        end)
    end
end
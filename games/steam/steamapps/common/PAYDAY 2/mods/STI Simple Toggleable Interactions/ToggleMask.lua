if not _PlayerMaskOff__check_use_item then _PlayerMaskOff__check_use_item = PlayerMaskOff._check_use_item end
function PlayerMaskOff:_check_use_item( t, input )
    if STI.settings.mask then
        if input.btn_use_item_press and self._start_standard_expire_t then
            self:_interupt_action_start_standard()
            return false
        elseif input.btn_use_item_release then
            return false
        end
    end

    return _PlayerMaskOff__check_use_item(self, t, input)
end

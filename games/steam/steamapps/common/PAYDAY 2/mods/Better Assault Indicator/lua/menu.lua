function BAI:LoadLocalization(path, loc)
    loc = loc or LocalizationManager
    local language_filename = nil
    if self.settings.mod_language == 1 then
        local LanguageKey =
        {
            ["PAYDAY 2 THAI LANGUAGE Mod"] = "thai",
            ["Ultimate Localization Manager & 正體中文化"] = "tchinese",
            ["PAYDAY 2 BRAZILIAN PORTUGUESE"] = "portuguese-br",
            ["Payday 2 Korean patch"] = "korean"
        }
        for _, mod in pairs(BLT and BLT.Mods and BLT.Mods:Mods()) do
            language_filename = mod:IsEnabled() and LanguageKey[mod:GetName()] or nil
            if language_filename then
                break
            end
        end
        if not language_filename then
            for _, filename in pairs(file.GetFiles(path)) do
                local str = filename:match('^(.*).json$')
                if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
                    language_filename = str
                    break
                end
            end
        end
        if language_filename then
            self.Language = language_filename
            loc:load_localization_file(path .. language_filename .. ".json")
        end
    else
        local Languages =
        {
            [2] = "english",
            [3] = "french",
            [4] = "german",
            [5] = "italian",
            [6] = "russian",
            [7] = "thai",
            [8] = "schinese",
            [9] = "tchinese",
            [10] = "portuguese-br",
            [11] = "spanish",
            [12] = "korean",
            [13] = "japanese"
        }
        self.Language = Languages[self.settings.mod_language]
        loc:load_localization_file(path .. self.Language .. ".json")
    end
    if self.Language ~= "english" or not language_filename then
        loc:load_localization_file(path .. "english.json", false)
    end
    loc:load_localization_file(path .. "languages.json")
    loc:load_localization_file(path .. "common.json", false)
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_BAI", function(loc)
    BAI:LoadLocalization(BAI.LocPath, loc)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_BAI", function(menu_manager, nodes)
    MenuCallbackHandler.OpenBAIModOptions = function(self, item)
        BAI.Menu = BAI.Menu or BAIMenu:new()
        BAI.Menu:Open()

        Hooks:PostHook(MenuManager, "update", "update_menu_BAI", function(self, t, dt)
            if BAI.Menu and BAI.Menu.update and BAI.Menu._enabled then
                BAI.Menu:update(t, dt)
            end
        end)
    end

    local node = nodes["blt_options"]

    local item_params = {
        name = "BAI_OpenMenu",
        text_id = "bai_mod_title",
        help_id = "bai_mod_desc",
        callback = "OpenBAIModOptions",
        localize = true,
    }
    local item = node:create_item({type = "CoreMenuItem.Item"}, item_params)
    node:add_item(item)
end)
if not RequiredScript then
    return
end

--[[
    "Global.load_level" ensures this block of code will not run when "lib/managers/hudmanagerpd2" is required from the Main Menu
    Some mods (particulary More Weapon Stats) are able to do that
]]
if RequiredScript == "lib/managers/hudmanagerpd2" and Global.load_level then
    dofile(BAI.LuaPath .. "hudmanagerpd2.lua")
    dofile(BAI.LuaPath .. "menumanager.lua")
end

if RequiredScript == "core/lib/utils/coreapp" then
    if BAI then
        return
    end

    BAI = {
        --- Sync Messages; do not change them!
        SyncMessage = "BAI_Message",
        AS_SyncMessage = "BAI_AssaultState",
        ASO_SyncMessage = "BAI_AssaultStateOverride",
        AAI_SyncMessage = "BAI_AdvancedAssaultInfo_TimeLeft",
        EE_SyncMessage = "BAI_EasterEgg",
        EE_ResetSyncMessage = "BAI_EasterEgg_Reset",
        --- Sync Messages

        --- Data Sync Messages; do not change them!
        data =
        {
            BAI_Q = "BAI?";
            BAI_A = "BAI!",
            ResendAS = "RequestCurrentAssaultState",
            ResendTime = "RequestCurrentAssaultTimeLeft",
            EE_FSS1_Q = "AIReactionTimeTooHigh?",
            EE_FSS1_A = "AIReactionTimeTooHigh"
        },
        --- Data Sync Messages

        _cache = {
            client_time_left = 0,
            client_spawns_left = 0,
            client_break_time_left = 0
        },

        _hooks = {},

        --- Easter Eggs
        EasterEgg =
        {
            FSS =
            {
                AIReactionTimeTooHigh = false
            }
        },
        --- Easter Eggs

        --- HUD Synchronization
        HUD =
        {
            KineticHUD =
            {
                DownCounter = "DownCounterStandalone", -- I use this to know if the host has KineticHUD/NobleHUD active
                SyncAssaultPhase = "SyncAssaultPhase"
            }
        },
        --- HUD Synchronization

        --- Event List
        EventList =
        {
            AssaultStart = "AssaultStart",
            EndlessAssaultStart = "EndlessAssaultStart",
            AssaultStateChange = "AssaultStateChange", -- (state: string -> control or anticipation or build or sustain or fade)
            AssaultStateChangeOverride = "AssaultStateChangeOverride", -- (state: string -> control or anticipation or build or sustain or fade; override: bool -> true or false)
            Captain = "Captain", -- (active: bool -> true or false)
            AssaultEnd = "AssaultEnd",
            NoReturn = "NoReturn", -- (active: bool -> true or false)
            NormalAssaultOverride = "NormalAssaultOverride",
            Update = "Update",
            HUDAssaultCornerInit = "HUDAssaultCornerInit"
        },
        -- Devs are free to add their custom events. BAI itself does not trigger custom events. You have to trigger them manually via method BAI:CallEvent(<your event>).
        -- Custom events do not have to be in the Event List.
        --- Event List

        Enum =
        {
            TextLength =
            {
                Long = 1,
                Short = 2,
                ShortFirst = 3
            },
            LogType =
            {
                Info = 1,
                Warning = 2
            },
            AssaultType =
            {
                None = 0,
                Normal = 1,
                Captain = 2,
                Endless = 3,
                NoReturn = 4
            },
            AssaultState =
            {
                Control = "control",
                Anticipation = "anticipation",
                Build = "build",
                Sustain = "sustain",
                Fade = "Fade"
            },
            CrashType =
            {
                Unknown = 0,
                HUD = 1
            }
        },

        Events =
        {
        },

        -- Used for internal logic change when various HUDs needs a different logic behavior
        Config =
        {
            CheckCompletelyHostageVisibility = true
        },

        ModPath = ModPath,
        LocPath = ModPath .. "loc/",
        LuaPath = ModPath .. "lua/",
        MenuPath = ModPath .. "menu/",
        HostPath = ModPath .. "lua/host/",
        ClientPath = ModPath .. "lua/client/",
        HUDCompatibilityPath = ModPath .. "lua/compatibility/hud/",
        ModCompatibilityPath = ModPath .. "lua/compatibility/mod/",
        MenuCompatibilityPath = ModPath .. "menu/compatibility/",
        SettingsSaveFilePath = BLTModManager.Constants:SavesDirectory() .. "bai.json",
        Update = false,
        Language = "english",
        SaveDataVer = 6,
        ModVersion = ModInstance and tonumber(ModInstance:GetVersion()) or "N/A",

        -- Debug switch. Used for new features work in progress or to load debugging code
        debug = false
    }

    function BAI:Init()
        self.IsHost = Network:is_server()
        self.IsClient = not self.IsHost
        self._cache.mutators = nil
        self.color_type = ""
        if managers.mutators and managers.mutators:are_mutators_active() then
            self._cache.mutators = true
            self.color_type = "_mutated"
            if self.IsClient and Global.mutators.active_on_load["MutatorEndlessAssaults"] then -- Host does not need this, client side only
                self._cache.MutatorEndlessAssaults = true
            end
            if Global.mutators.active_on_load["MutatorAssaultExtender"] then
                self._cache.MutatorAssaultExtender = true
            end
        end
        self.CustomTextLength = self.Enum.TextLength.Long
        self._cache.AssaultType = self.Enum.AssaultType.None
        self._cache.Faction = tweak_data.levels:get_ai_group_type()
        self._cache.Difficulty = Global.game_settings.difficulty
        self._cache.level_id = Global.game_settings.level_id
        self._cache.AssaultType = self.Enum.AssaultType.None
        self._cache.SinglePlayer = Global.game_settings.single_player
        self._cache.Multiplayer = not self._cache.SinglePlayer
        self._cache.PlayingFromStart = true
        self:EasterEggInit()
        if self.IsClient then
            dofile(self.ClientPath .. "assault_time.lua")
            self:TryToCorrectTheDiff(self._cache.level_id)
        end
    end

    function BAI:PostInit()
        self._cache.is_crimespree = Global.game_settings.gamemode == "crime_spree"
        self._cache.is_skirmish = managers.skirmish and managers.skirmish:is_skirmish() or false
    end

    function BAI:EasterEggInit()
        self.EasterEgg.FSS.AIReactionTimeTooHigh = (self._cache.is_crimespree and managers.crime_spree:server_spree_level() >= 500) or
            (FullSpeedSwarm and (FullSpeedSwarm.settings.task_throughput ~= 60 and self.IsHost and self._cache.Difficulty == "sm_wish") or false)
    end

    function BAI:PreHook(object, func, pre_call)
        Hooks:PreHook(object, func, "BAI_Pre_" .. func, pre_call)
    end

    function BAI:Hook(object, func, post_call)
        Hooks:PostHook(object, func, "BAI_" .. func, post_call)
    end

    function BAI:Unhook(mod, id)
        Hooks:RemovePostHook((mod and (mod .. "_") or "BAI_") .. id)
    end

    function BAI:LoadHUDCompatibilityFile(hud)
        dofile(self.HUDCompatibilityPath .. hud .. ".lua")
        local _v2_corner
        if hud ~= "mui" then
            _v2_corner = managers.hud._hud_assault_corner._v2_corner
        end
        if self:IsOr(hud, "pdth_hud_reborn", "restoration_mod", "mui", "halo_reach_hud") then
            if hud == "restoration_mod" then
                self.CustomTextLength = BAI.Enum.TextLength[_v2_corner and "ShortFirst" or "Long"]
                self.FactionAssaultTextNotSupported = _v2_corner
            else
                self.CustomTextLength = BAI.Enum.TextLength.ShortFirst
                self.FactionAssaultTextNotSupported = true
            end
        end
    end

    function BAI:LoadModCompatibilityFile(mod)
        dofile(self.ModCompatibilityPath .. mod .. ".lua")
    end

    function BAI:DelayCall(name, t, func, ...)
        self._delayedcallsfix:Add(name, t, func, ...)
    end

    function BAI:RemoveDelayedCall(name)
        self._delayedcallsfix:Remove(name)
    end

    function BAI:Load()
        self:LoadDefaultValues()
        local file = io.open(self.SettingsSaveFilePath, "r")
        if file then
            local table = json.decode(file:read("*all")) or {}
            file:close()
            if table.SaveDataVer and table.SaveDataVer == self.SaveDataVer then
                self:LoadValues(self.settings, table)
            else
                self.SaveDataNotCompatible = true
                self:Save()
            end
        end
    end

    function BAI:LoadValues(bai_table, file_table)
        for k, v in pairs(file_table) do -- Load subtables in table and calls the same method to load subtables or values in that subtable
            if type(file_table[k]) == "table" and bai_table[k] then
                self:LoadValues(bai_table[k], v)
            end
        end
        for k, v in pairs(file_table) do
            if type(file_table[k]) ~= "table" then
                if bai_table and bai_table[k] ~= nil then -- Load values to the table
                    bai_table[k] = v
                end
            end
        end
    end

    function BAI:Save()
        self.settings.SaveDataVer = self.SaveDataVer
        self.settings.ModVersion = self.ModVersion
        local file = io.open(self.SettingsSaveFilePath, "w+")
        if file then
            file:write(json.encode(self.settings) or "{}")
            file:close()
        end
    end

    function BAI:LoadDefaultValues()
        local file = io.open(self.MenuPath .. "default_values.json", "r")
        if file then
            self.settings = json.decode(file:read("*all") or { mod_language = 1 })
            file:close()
        else
            self:Log("No default values were found! Game may crash unexpectedly!", self.Enum.LogType.Warning)
            self.settings = { mod_language = 1 }
        end
    end

    function BAI:GetRightColor(type)
        if not type or not self.settings.assault_panel[type] then
            return Color.white
        end
        if self:IsOr(type, "assault", "captain", "endless") then
            return self:GetColor(type .. self.color_type)
        else
            return self:GetColor(type)
        end
    end

    function BAI:GetColor(type)
        if not type or not self.settings.assault_panel[type] then
            return Color.white
        end
        return self:GetColorFromTable(self.settings.assault_panel[type])
    end

    function BAI:GetColorRestoration(type)
        if not type or not self.settings.hud.restoration_mod.assault_panel[type] then
            return Color.white
        end
        local c = self.settings.hud.restoration_mod.assault_panel[type]
        return self:GetColorFromTable(c.c1), self:GetColorFromTable(c.c2)
    end

    function BAI:GetColorFromTable(value)
        if value and value.r and value.g and value.b then
            return Color(255, value.r, value.g, value.b) / 255
        end
        return Color.white
    end

    function BAI:IsHostagePanelVisible(type)
        if self.Config.CheckCompletelyHostageVisibility and self.settings.completely_hide_hostage_panel then
            return false
        end
        if not type or not self.settings.assault_panel[type] then
            return true
        end
        return not self.settings.assault_panel[type].hide_hostage_panel -- 'hide_hostage_panel' variable is set true => Hide Hostage Panel, otherwise not
    end

    function BAI:IsHostagePanelHidden(type)
        return not self:IsHostagePanelVisible(type)
    end

    function BAI:ASEnabledAndState(state)
        return self:GetOption("show_assault_states") and self:IsStateEnabled(state)
    end

    function BAI:IsStateEnabled(state) -- Change Enabled to Visible
        if not state or not self.settings.assault_panel[state] then
            return true
        end
        return self.settings.assault_panel[state].enabled
    end

    function BAI:IsStateDisabled(state)
        return not self:IsStateEnabled(state)
    end

    function BAI:IsCustomTextEnabled(text)
        if not text or not self.settings.assault_panel[text] then
            return false
        end
        local t = self.settings.assault_panel[text]
        if self:IsOr(text, "assault", "endless") and not self.FactionAssaultTextNotSupported then
            local check = self:GetOption("faction_assault_text") and self._cache.Faction or self._cache.Difficulty
            return t[check] and (t[check] ~= "") or false
        else
            if self.CustomTextLength == self.Enum.TextLength.Long then
                return t.custom_text and t.custom_text ~= "" or false
            elseif self.CustomTextLength == self.Enum.TextLength.ShortFirst then
                return t.short_custom_text and (t.short_custom_text ~= "") or (t.custom_text and t.custom_text ~= "")
            else
                return t.short_custom_text and t.short_custom_text ~= "" or false
            end
        end
    end

    function BAI:IsCustomTextDisabled(text)
        return not self:IsCustomTextEnabled(text)
    end

    function BAI:ShowAdvancedAssaultInfo()
        return self:GetOption("show_advanced_assault_info") and (self:GetAAIOption("show_time_left") or self:GetAAIOption("show_spawns_left"))
    end

    function BAI:IsAAIEnabledAndOption(option)
        return self:GetOption("show_advanced_assault_info") and self:GetAAIOption(option)
    end

    function BAI:ShowFSSAI()
        return self.EasterEgg.FSS.AIReactionTimeTooHigh and math.random(0, 100) % 10 == 0
    end

    function BAI:GetOption(option)
        if option then
            return self.settings[option]
        end
    end

    function BAI:GetAAIOption(option)
        if option then
            return self.settings.advanced_assault_info[option]
        end
    end

    function BAI:GetChatOption(option)
        if option then
            return self.settings.chat[option]
        end
    end

    function BAI:GetHUDOption(hud, option)
        if hud and option then
            return self.settings.hud[hud][option]
        end
    end

    function BAI:GetAnimationOption(option, check_enabled)
        check_enabled = check_enabled or true
        if option then
            if check_enabled then
                if not self.settings.animation.enable_animations then
                    return false
                end
            end
            return self.settings.animation[option]
        end
    end

    function BAI:Animate(o, a, f, ...)
        o:stop()
        if self:GetAnimationOption("enable_animations", false) then
            o:animate(callback(BAIAnimation, BAIAnimation, f), ...)
        else
            o:set_alpha(a)
        end
    end

    function BAI:AnimateSafe(name, a, callback)
        if self:GetAnimationOption("enable_animations", false) then
            managers.hud:add_updator(name, callback)
        else
            if a == 0 then
                a = 1
            end
            callback(nil, a * 10) -- just in case
        end
    end

    function BAI:AddEvents(events, f, delay, priority)
        if type(events) ~= "table" then
            self:Log("Events must be a table")
            return
        end
        for _, event in pairs(events) do
            self:AddEvent(event, f, delay, priority)
        end
    end

    function BAI:AddEvent(event, f, delay, priority, id)
        if type(event) ~= "string" then
            self:Log("Passed event name is not a string")
            return
        end
        if type(f) ~= "function" then
            self:Log("Passed function is not a function")
            return
        end
        if delay and type(delay) ~= "number" then
            self:Log("Passed delay is not a number")
            return
        end
        if priority and type(priority) ~= "number" then
            self:Log("Passed priority is not a number")
            return
        end
        if id and type(id) ~= "string" then
            self:Log("Passed Event ID is not a string")
            return
        end
        self.Events[event] = self.Events[event] or {}
        local event_table = self.Events[event]
        local value = { func = f, delay = delay or 0, priority = priority or 0, id = id or "" }
        -- Binary Insert: http://lua-users.org/wiki/BinaryInsert
        -- Faster than normal insert and then sort
        local iStart, iEnd, iMid, iState = 1, #event_table, 1, 0
        while iStart <= iEnd do
            iMid = math.floor((iStart + iEnd) / 2)
            if value.priority < event_table[iMid].priority then
                iEnd, iState = iMid - 1, 0
            else
                iStart, iState = iMid + 1, 1
            end
        end
        table.insert(event_table, (iMid + iState), value)
        return true
    end

    function BAI:RemoveEvent(event_name, id)
        if type(event_name) ~= "string" then
            self:Log("Passed event name is not a string")
            return
        end
        if type(id) ~= "string" then
            self:Log("Passed event ID is not a string")
            return
        end
        local event_table = self.Events[event_name] or {}
        for k, v in ipairs(event_table) do
            if v.id == id then
                table.remove(event_table, k)
            end
        end
    end

    function BAI:CallEvent(event_name, ...)
        if type(event_name) ~= "string" then
            self:Log("Passed event name is not a string")
            return
        end
        local event_table = self.Events[event_name] or {}
        for k, v in ipairs(event_table) do
            if v.delay > 0 then
                self:DelayCall("BAI_CallEvent_" .. event_name .. "_" .. k, v.delay, v.func, ...)
            else
                v.func(...)
            end
        end
        if self.debug then
            managers.hud:DebugEvent(event_name)
        end
    end

    function BAI:IsOr(string, ...)
        for i = 1, select("#", ...) do
            if string == select(i, ...) then
                return true
            end
        end
        return false
    end

    function BAI:IsNot(string, ...)
        for i = 1, select("#", ...) do
            if string == select(i, ...) then
                return false
            end
        end
        return true
    end

    function BAI:SyncAssaultState(state, override, stealth_broken, no_as_mod)
        if self.IsClient then
            return
        end
        if state then
            if self:IsNot(state, "control", "anticipation", "build") or stealth_broken then
                LuaNetworking:SendToPeersExcept(1, self["AS" .. (override and "O" or "") .. "_SyncMessage"], state)
            end
            if not no_as_mod then
                LuaNetworking:SendToPeersExcept(1, "AssaultStates_Net", state)
                LuaNetworking:SendToPeersExcept(1, "SyncAssaultPhase", state) -- KineticHUD and NobleHUD
            end
        end
    end

    function BAI:LoadCustomText(update)
        if not (self._cache.Faction and self._cache.Difficulty) then
            return
        end
        local custom_localization = LocalizationManager._custom_localizations
        local table =
        {
            assault =
            {
                "hud_assault_assault", -- Overwrites original game string
                "hud_assault"
            },
            captain =
            {
                "hud_assault_vip", -- Overwrites original game string
                "hud_captain"
            },
            endless =
            {
                "hud_assault_endless",
                "hud_endless"
            },
            survived =
            {
                "hud_assault_survived", -- Overwrites original game string
                "hud_survived"
            },
            control = "hud_control",
            anticipation = "hud_anticipation",
            build = "hud_build",
            sustain = "hud_sustain",
            fade = "hud_fade"
        }
        local table_escape =
        {
            "hud_assault_point_no_return", -- VR
            "hud_assault_point_no_return_in",
            "hud_assault_point_no_vlad", -- VR
            "hud_assault_point_no_vlad_in"
        }
        local load_default =
        { -- BAI default strings; original default text loaded
            -- Long text
            "hud_assault_assault_gensec",
            "hud_assault_assault_zeal",
            "hud_assault_assault_fbi",
            "hud_assault_assault_murkywater",
            "hud_assault_assault_russia",
            "hud_assault_assault_zombie",
            "hud_assault_assault_federales",
            "hud_assault_endless",
            "hud_assault_endless_gensec",
            "hud_assault_endless_zeal",
            "hud_assault_endless_fbi",
            "hud_assault_endless_murkywater",
            "hud_assault_endless_russia",
            "hud_assault_endless_zombie",
            "hud_assault_endless_federales",
            -- Short text

            -- Both
            "hud_assault",
            "hud_captain",
            "hud_endless",
            "hud_survived",
            "hud_control",
            "hud_anticipation",
            "hud_build",
            "hud_sustain",
            "hud_fade"
        }
        for _, v in pairs(load_default) do
            custom_localization[v] = managers.localization:text(v .. "_default")
        end
        local restore_default =
        { -- Game default strings; nilled when restored so original text from the game will be used instead
            "hud_assault_assault",
            "hud_assault_vip",
            "hud_assault_survived",
            "hud_assault_point_no_return", -- VR
            "hud_assault_point_no_return_in",
            "hud_assault_point_no_vlad", -- VR
            "hud_assault_point_no_vlad_in"
        }
        for _, v in pairs(restore_default) do
            custom_localization[v] = nil
        end
        local text_modifier = self._cache.Difficulty
        local factions =
        { -- Factions in Vanilla game; custom factions are not supported!
            -- "swat" not included (Normal and Hard difficulty)
            fbi = true,
            gensec = true,
            zeal = true,
            russia = true,
            zombie = true,
            murkywater = true,
            federales = true
        }
        if self:GetOption("faction_assault_text") then
            text_modifier = self._cache.Faction
            if self._cache.level_id == "haunted" then -- Safehouse Nightmare
                text_modifier = "zombie"
            end
            if text_modifier == "america" then
                if self:IsOr(self._cache.Difficulty, "normal", "hard") then -- Normal, Hard
                    text_modifier = "swat"
                elseif self:IsOr(self._cache.Difficulty, "overkill", "overkill_145") then -- Very Hard, OVERKILL
                    text_modifier = "fbi"
                elseif self:IsOr(self._cache.Difficulty, "easy_wish", "overkill_290") then -- Mayhem, Death Wish
                    text_modifier = "gensec"
                else --sm_wish; Death Sentence
                    text_modifier = "zeal"
                end
            end
        end
        if self.settings.assault_panel.escape.custom_text ~= "" then
            for _, text_id in pairs(table_escape) do
                custom_localization[text_id] = self.settings.assault_panel.escape.custom_text
            end
        end
        for k, v in pairs(self.settings.assault_panel) do
            if table[k] then
                local t = table[k]
                if type(t) == "table" then
                    if type(v.custom_text) == "table" then
                        if v.custom_text[text_modifier] ~= "" then
                            custom_localization[t[1] .. (factions[text_modifier] and ("_" .. text_modifier) or "")] = v.custom_text[text_modifier]
                        end
                        if v.short_custom_text[text_modifier] ~= "" then
                            custom_localization[t[2]] = v.short_custom_text[text_modifier]
                        end
                    else
                        if v.custom_text ~= "" then
                            custom_localization[t[1]] = v.custom_text
                        end
                        if v.short_custom_text ~= "" then
                            custom_localization[t[2]] = v.short_custom_text
                        end
                    end
                else
                    if v.custom_text ~= "" then
                        custom_localization[t] = v.custom_text
                    end
                end
            end
        end
        self:Log("Custom assault text " .. (update and "updated" or "loaded"))
    end

    function BAI:SetCustomText(text_id, text)
        LocalizationManager._custom_localizations[text_id] = text
    end

    function BAI:AreAssaultStatesDisabledInTheLevel(level_id)
        level_id = level_id or self._cache.level_id
        local levels = { "Enemy_Spawner", "enemy_spawner2", "modders_devmap" }
        return table.contains(levels, level_id)
    end

    function BAI:IsPlayingHeistWithFakeEndlessAssault(level_id)
        level_id = level_id or self._cache.level_id
         -- Framing Frame Day 1, Art Gallery, Watch Dogs Day 2, Hell's Island
        local levels = { "framing_frame_1", "gallery", "watchdogs_2", "bph" }
        -- Deal Denied
        local custom_levels = { "deal_denied" }
        return table.contains(levels, level_id) or table.contains(custom_levels, level_id)
    end

    function BAI:Between(number, start_n, end_n, inclusive)
        if inclusive then
            return number >= start_n and number <= end_n
        else
            return number > start_n and number < end_n
        end
    end

    function BAI:RoundNumber(n, bracket)
        bracket = bracket or 1
        local sign = n >= 0 and 1 or -1
        return math.floor(n / bracket + sign * 0.5) * bracket
    end

    function BAI:Log(s, log_type)
        log_type = log_type or self.Enum.LogType.Info
        if log_type == self.Enum.LogType.Info then
            log("[BAI] " .. (s or "nil"))
        else
            log("[BAI Warning] " .. (s or "nil"))
        end
    end

    function BAI:CrashWithErrorHUDOption(hud, option)
        self:CrashWithError(hud .. " compatibility is selected, but option '" .. option .. "' is disabled.")
    end

    function BAI:CrashWithErrorHUD(hud)
        self:CrashWithError(hud .. " compatibility is selected, but " .. hud .. " is not installed.")
    end

    function BAI:CrashWithErrorHUDLibrary(hud, library)
        self:CrashWithError(hud .. " compatibility is selected, but " .. library .. " is not installed.")
    end

    function BAI:CrashWithError(error_message)
        assert(false, error_message and ("BAI: " .. error_message) or "Unknown BAI Crash")
    end

    function BAI:GetAssaultTime(sender)
        if self.IsHost and self._cache.AssaultType == self.Enum.AssaultType.Normal and sender then
            local tweak = tweak_data.group_ai[self._cache.is_skirmish and "skirmish" or "besiege"].assault
            local gai_state = managers.groupai:state()
            local assault_data = gai_state and gai_state._task_data.assault
            local get_value = gai_state._get_difficulty_dependent_value or function() return 0 end
            local get_mult = gai_state._get_balancing_multiplier or function() return 0 end

            if not (tweak and gai_state and assault_data and assault_data.active) then
                return
            end

            local time = assault_data.phase_end_t - gai_state._t
            local add
            if self._cache.is_crimespree or self._cache.MutatorAssaultExtender then
                local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), 0.5) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
                add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
                if add == 0 and gai_state._assault_number == 1 and assault_data.phase == "build" then
                    add = sustain_duration / 2
                end
            end
            if assault_data.phase == "build" then
                local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), 0.5) * get_mult(gai_state, tweak.sustain_duration_balance_mul)
                time = time + sustain_duration + tweak.fade_duration
                if add then
                    time = time + add
                end
            elseif assault_data.phase == "sustain" then
                time = time + tweak.fade_duration
                if add then
                    time = time + add
                end
            end
            LuaNetworking:SendToPeer(sender, self.AAI_SyncMessage, time)
        end
    end

    function BAI:SetCompatibleHost(BAIHost)
        self.BAIHost = BAIHost
        self.CompatibleHost = true
        Hooks:Remove("NetworkReceivedData_BAI_AssaultStates_Net")
    end

    function BAI:SendMessage(message)
        managers.network:session():send_to_peers_ip_verified("send_chat_message", 1, "[BAI] " .. message)
    end

    -- Functions overwritten in "assault_states.lua" file
    function BAI:UpdateAssaultState(state, stealth_broken, no_as_mod)
    end

    function BAI:UpdateAssaultState_Mod(state)
    end

    function BAI:UpdateAssaultStateOverride(state, override)
    end

    function BAI:SetAssaultStatesHook(hook)
    end
    -- End

    -- Functions overwritten in "assault_time.lua" file
    function BAI:SetTimer()
        self._cache.client_time_left = 0
        self._cache.client_spawns_left = 0
    end

    function BAI:SetBreakTimer()
        self._cache.client_break_time_left = 0
    end
    -- End

    function BAI:LoadSync()
        self:LoadDiff()
    end

    function BAI:LoadDiff()
        local level_id = self._cache.level_id
        if managers.groupai:state():whisper_mode() or true then -- Stealth
            return
        end
        local difficulty = self._cache.Difficulty
        local heist_timer = managers.game_play_central:get_heist_timer()
        local assault_number = managers.groupai:state():get_assault_number()
        if level_id == "hvh" then -- Cursed Kill Room
            return
        elseif level_id == "four_stores" then
        elseif level_id == "mallcrasher" then
        elseif level_id == "nightclub" then
        elseif level_id == "roberts" then -- GO Bank
            if assault_number <= 1 then
                self._cache.AssaultTime.difficulty = 0.5
            elseif assault_number == 2 then
                self._cache.AssaultTime.difficulty = 0.75
            else
                self._cache.AssaultTime.difficulty = 1
            end
        end
    end

    BAI:Load()
    if BAI.debug then
        BAI:Log("Debug mode active")
    end
end
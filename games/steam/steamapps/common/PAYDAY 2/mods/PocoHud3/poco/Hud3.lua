-- PocoHud3 by zenyr@zenyr.com
if not TPocoBase or Pocohud_stop then return end
--[[
    Disclamer:
    Feel free to ask me through my mail: zenyr(at)zenyr.com. But please understand that I'm quite clumsy, cannot guarantee I'll reply what you want..
]]
-- Note: Due to quirky PreCommit hook, revision number would *appear to* be 1 revision before than "released" luac files.
local _ = UNDERSCORE
local REV = 467 -- git shortlog | wc -l
local TAG = '0.35' -- git describe --tags
local string_format = string.format
local inGame = Global.load_level
local me
local buff_style
local DC
local btmO
local buffO
local popupO
local showCrits = false
local function_empty = function() end
local ShowBoost = function(peer_id, t) end
local CheckAbility = function_empty
local BulletstormPotentialResolution = 0.25 -- Default, 4 times per second
local ManiacAccumulatedStackResolution = 0.5 -- Default, twice per second
local BikerKillsGaugeResolution = 0.5 -- Default, twice per second
local PollBikerKills = function_empty
local PollUppersRange = function_empty
local UppersRangeResolution = 0.25 -- Default, 4 times per second
local PollDodgeChance = function_empty
local PollCriticalChance = function_empty
local DireNeedResolution = 0.25 -- Default, 4 times per second
local LockAndLoadResolution = 0.25 -- Default, 4 times per second
local RecomputeContourDuration = function_empty
local function AdjustPolling()
    BulletstormPotentialResolution = 1 / buffO.BulletstormPotentialResolution
    ManiacAccumulatedStackResolution = 1 / buffO.ManiacAccumulatedStacksResolution
    BikerKillsGaugeResolution = 1 / buffO.BikerKillsGaugeResolution
    UppersRangeResolution = 1 / buffO.UppersRangeResolution
    DireNeedResolution = 1 / buffO.DireNeedDurationResolution
    LockAndLoadResolution = 1 / buffO.LockAndLoadResolution
end

PocoHud3Class = nil
Poco._req ('poco/Hud3_class.lua')
if not PocoHud3Class then return end

Poco._req ('poco/Hud3_Options.lua')
if not PocoHud3Class.Option then return end

local O = PocoHud3Class.Option:new()
PocoHud3Class.O = O
local K = PocoHud3Class.Kits:new()
PocoHud3Class.K = K
local L = PocoHud3Class.Localizer:new()
PocoHud3Class.L = L

PocoLocale = nil
Poco._req ('poco/loc/Hud3_LocaleIngame'..O('root','languageIngame')..'.lua')
if not PocoLocale then
    Poco._req ('poco/loc/Hud3_LocaleIngameEN.lua')
    if not PocoLocale then return end
end

--- Options ---
local YES,NO,yes,no = true,false,true,false
local ALTFONT= PocoHud3Class.ALTFONT
local FONT= PocoHud3Class.FONT
local FONTLARGE = PocoHud3Class.FONTLARGE
local clGood= PocoHud3Class.clGood
local clBad= PocoHud3Class.clBad
local Icon= PocoHud3Class.Icon
local PocoEvent= PocoHud3Class.PocoEvent

local _BAGS = {
    ['8f59e19e1e45a05e']=PocoLocale._BAGS.ammo,
    ['43ed278b1faf89b3']=PocoLocale._BAGS.medic,
    ['a163786a6ddb0291']=PocoLocale._BAGS.body,
    ['e1474cdfd02aa274']=PocoLocale._BAGS.fak,
    ['40f36f66c018e700']=PocoLocale._BAGS.grenades
}

local _BROADCASTHDR, _BROADCASTHDR_HIDDEN = Icon.Div,Icon.Ghost
local SkillIcons = "guis/textures/pd2/skilltree/icons_atlas"
local U100SkillIcons = "guis/textures/pd2/skilltree_2/icons_atlas_2"
local DeckIcons = "guis/textures/pd2/specialization/icons_atlas"
local ManiacDeckIcons = "guis/dlcs/coco/textures/pd2/specialization/icons_atlas"
local AnarchistDeckIcons = "guis/dlcs/opera/textures/pd2/specialization/icons_atlas"
local BikerDeckIcons = "guis/dlcs/wild/textures/pd2/specialization/icons_atlas"
local KingpinDeckIcons = "guis/dlcs/chico/textures/pd2/specialization/icons_atlas"
local SicarioDeckIcons = "guis/dlcs/max/textures/pd2/specialization/icons_atlas"
local StoicDeckIcons = "guis/dlcs/myh/textures/pd2/specialization/icons_atlas"
local TagTeamDeckIcons = "guis/dlcs/ecp/textures/pd2/specialization/icons_atlas"
local HackerDeckIcons = "guis/dlcs/joy/textures/pd2/specialization/icons_atlas"
local LeechDeckIcons = "guis/dlcs/copr/textures/pd2/specialization/icons_atlas"
local CopycatDeckIcons = "guis/dlcs/mrwi/textures/pd2/specialization/icons_atlas"
local now = function (type) return type and TimerManager:game():time() or managers.player:player_timer():time() end
local _conv = {
    city_swat	=	'_mob_city_swat',
    cop	=	'_mob_cop',
    fbi	=	'_mob_fbi',
    fbi_heavy_swat	=	'_mob_fbi_heavy_swat',
    fbi_swat	=	'_mob_fbi_swat',
    gangster	=	'_mob_gangster',
    gensec	=	'_mob_gensec',
    heavy_swat	=	'_mob_heavy_swat',
    security	=	'_mob_security',
    shield	=	'_mob_shield',
    sniper	=	'_mob_sniper',
    spooc	=	'_mob_spooc',
    swat	=	'_mob_swat',
    tank	=	'_mob_tank',
    taser	=	'_mob_taser',
}
--- Class Start ---
local TPocoHud3 = class(TPocoBase)
PocoHud3Class.TPocoHud3 = TPocoHud3
TPocoHud3.className = 'Hud'
TPocoHud3.classVersion = 3
--- Inherited ---
function TPocoHud3:onInit() -- ★설정
--	Poco:LoadOptions(self:name(1),O)
    O:load()
    L:load()

    PocoLocale = nil
    Poco._req ('poco/loc/Hud3_LocaleIngame'.. O('root','languageIngame') ..'.lua')
    if not PocoLocale then
        Poco._req ('poco/loc/Hud3_LocaleIngameEN.lua')
        if not PocoLocale then return end
    end
    _BAGS = {
        ['8f59e19e1e45a05e']=PocoLocale._BAGS.ammo,
        ['43ed278b1faf89b3']=PocoLocale._BAGS.medic,
        ['a163786a6ddb0291']=PocoLocale._BAGS.body,
        ['e1474cdfd02aa274']=PocoLocale._BAGS.fak,
        ['40f36f66c018e700']=PocoLocale._BAGS.grenades
    }

    clGood = O:get('root','colorPositive')
    clBad = O:get('root','colorNegative')
    buffO = O:get("buff")
    buff_style = buffO.style
    btmO = O:get("playerBottom")
    popupO = O:get('popup')
    showCrits = popupO.myCrits
    self._ws = managers.gui_data:create_fullscreen_workspace()
    error = function(msg)
        if self.dead then
            _('ERR:',msg)
        else
            self:err(msg,1)
        end
    end
    self.pnl = {
        dbg = self._ws:panel():panel({ name = 'dbg_sheet',  layer = 50000}),
        pop = self._ws:panel():panel({ name = 'dmg_sheet',  layer = 4}),
        buff = self._ws:panel():panel({ name = 'buff_sheet',  layer = 5}),
        stat = self._ws:panel():panel({ name = 'stat_sheet',  layer = 9}),
    }

    -- 'customhud' PR #22 related
    self.custom_hud_enabled = rawget(_G,'VHUDPlus') and VHUDPlus:getSetting({"CustomHUD", "HUDTYPE"}, 2) == 3 or rawget(_G,'CustomEOStandalone') and CustomEOStandalone:getSetting({"WolfHUDCustomHUD", "ENABLED"}, true)

    self.killa = self.killa or 0
    self.stats = self.stats or {}
    self.hooks = {}
    self.pops = {}
    self.buffs = {}
    self.floats = {}
    self.sFloats = {}
    self.smokes = {}
    self.hits = {} -- to prevent HitDirection markers gc
    self._n_of_players = HUDManager and HUDManager.PLAYER_PANEL or 4
    self.gadget = self.gadget or {}
--	self.tmp = self.pnl.dbg:bitmap{name='x', blend_mode = 'add', layer=1, x=0,y=40, color=clGood, texture = 'guis/textures/hud_icons'}
    local dbgO = O:get('corner')
    self.dbgLbl = self.pnl.dbg:text{text='HUD '..(inGame and 'Ingame' or 'Outgame'), font= dbgO.defaultFont and FONTLARGE or ALTFONT, font_size = dbgO.size, color = dbgO.color:with_alpha(dbgO.opacity/100), x=0,y=self.pnl.dbg:height()-dbgO.size, layer=0, visible = false}
    self:_hook()
    self:_updateBind()

    self._special_units_id = StatisticsManager and StatisticsManager.special_unit_ids or {}

    if O:get('root','detailedModeByDefault') then
        self.verbose = true
    end

    return true
end
function TPocoHud3:onResolutionChanged()
    if alive(self._ws) then
        managers.gui_data:layout_fullscreen_workspace(self._ws)
        self.dbgLbl:set_y(self.pnl.dbg:height() - self.dbgLbl:height())
    else
        self:err('No WS to reschange')
    end
end
function TPocoHud3:import(data)
    self.killa = data.killa
    self.stats = data.stats
    self._muted = data._muted
    self._startGameT = data._startGameT
    self._floats_to_load = data.floats
end
function TPocoHud3:import_post(data)
    self._game_started = data.game_started
    if self._startGameT then
        self:SetIngame(true, true)
    end
end
function TPocoHud3:ImportFloats()
    local show_minions = O:get('float','showTargetsConvert')
    for _, data in pairs(self._floats_to_load or {}) do
        if data.category == 0 and data.tag and data.tag.minion and show_minions then
            self:MinionFloat(data.unit, 0, {minion = data.tag.minion})
        elseif data.category == 1 then
            self:Float(data.unit, 1)
        end
    end
    self._floats_to_load = nil
end
function TPocoHud3:Refresh()
    if managers.groupai and managers.groupai:state() and self._game_started then
        local ai_criminals = managers.groupai:state():all_AI_criminals()
        for _, data in pairs(ai_criminals or {}) do
            local unit = data.unit
            if unit and alive(unit) and unit:base() and unit:base().Poco_Refresh then
                unit:base():Poco_Refresh()
            end
        end
    end
end
function TPocoHud3:export()
    Poco.save[self.className] = {
        stats = self.stats,
        killa = self.killa,
        _muted = self._muted,
        _startGameT = self._startGameT,
        floats = self.floats,
        game_started = self._game_started
    }
    if TeamAIBase then
        TeamAIBase.Poco_Refresh = nil
    end
    if managers.player then
        managers.player:unregister_message(Message.OnEnemyKilled, "Poco_crew_throwable_regen")
    end
end
local _someone_joining = false
function TPocoHud3:Update(t,dt)
    if managers.vote:is_restarting() then
        return
    end
    if _someone_joining then
        return
    end
    local r,err = pcall(self._update,self,t,dt)
    if not r then _(err) end
end
function TPocoHud3:onDestroy(gameEnd)
    self:Menu(true, true) -- Force dismiss menu
    if alive(self._ws) then
        managers.gui_data:destroy_workspace(self._ws)
    end
end
function TPocoHud3:AddDmgPopByUnit(sender,unit,offset,damage,death,head,dmgType)
    if unit and alive(unit) then
        self:AddDmgPop(sender,self:_pos(unit),unit,offset,damage,death,head,dmgType)
    end
end
local _lastAttk, _lastAttkpid = 0,0
function TPocoHud3:AddDmgPop(sender, hitPos, unit, offset, damage, death, head, dmgType, isCrit)
    if type(damage) ~= 'number'  -- Dragon's breath crash
        or dmgType == 'stun'	-- Stun a convert crash with concussion grenade
        or damage == 0			-- Stun a shield crash with concussion grenade
    then
        return
    end
    if type(sender) == "function" then return end
    if self.dead then return end
    isCrit = isCrit and showCrits
    local pid = self:_pid(sender)

    local isPercent = damage < 0
    local dmgTime = popupO.damageDecay
    local rDamage = damage>=0 and damage or -damage
    if isPercent and unit and unit:character_damage() and unit:character_damage()._HEALTH_INIT then
        rDamage = math.min(unit:character_damage()._HEALTH_INIT * rDamage / 100, unit:character_damage()._health)
    end
    local isSpecial = false
    -- TODO:
    -- Get rid of this not sense and optimize minion hit spam message
    if unit then
        if not alive(sender) then return end -- If an attacker died/nonexist just before this, abandon.
        local senderTweak = sender and alive(sender) and sender:base() and sender:base()._tweak_table
        local unitTweak = unit and alive(unit) and unit:base() and unit:base()._tweak_table
        local statsTweak = unitTweak and unit:base()._stats_name or ""
        isSpecial = unitTweak and unit:base().has_tag and unit:base():has_tag("special") or self._special_units_id[statsTweak]
        for i = 1, self._n_of_players do
            local minion = self:Stat(i,'minion')
            local minion2 = self:Stat(i,'minion2')
            if unit == minion then
                local apid = self:_pid(sender)
                self:Stat(i,'minionHit',sender)
                if (rDamage or 0) > 0 and apid and apid > 0 and (apid ~= _lastAttkpid or now()-_lastAttk > 5) then
                    _lastAttk = now()
                    _lastAttkpid = apid
                    self:Chat('minionShot',L('_msg_minionShot',{self:_name(apid),i==apid and PocoLocale._convertOwn or self:_name(i)..PocoLocale._s,_.f(rDamage*10)}))
                end
            elseif unit == minion2 then
                local apid = self:_pid(senderTweak)
                self:Stat(i,'minion2Hit',senderTweak)
                if (rDamage or 0) > 0 and apid and apid > 0 and (apid ~= _lastAttkpid or now()-_lastAttk > 5) then
                    _lastAttk = now()
                    _lastAttkpid = apid
                    self:Chat('minionShot',L('_msg_minionShot',{self:_name(apid),i==apid and PocoLocale._convertOwn or self:_name(i)..PocoLocale._s,_.f(rDamage*10)}))
                end
            end
        end
    end
    local color = self:_color(sender,cl.White):with_alpha(death and 1 or 0.5)
    local texts = {}
    local n = 1
    if isCrit then
        texts[n] = {'',cl.Red}
        n = n + 1
    end
    if rDamage>0 then
        texts[n] = {_.f(rDamage*10), isCrit and cl.Yellow or color}
        n = n + 1
    end
    if head then
        texts[n] = {'!',color:with_red(1)}
        n = n + 1
    end
    if death or isCrit then
        texts[n] = {'',isCrit and cl.Red or isSpecial and cl.Yellow or color}
        n = n + 1
    end

    local pos = Vector3()
    mvector3.set(pos,hitPos)
    mvector3.set_z(pos,pos.z + offset)
    local r,err = pcall(function()
        if sender then
            if self:Stat(pid,'time') == 0 then
                self:Stat(pid,'time',now())
            end

            if dmgType ~= 'fire'
                and dmgType ~= 'he'
                and dmgType ~= 'dot'
                and dmgType ~= 'melee'
                and dmgType ~= 'poison'
            then
                self:Stat(pid,'hit',1,true)
                --if (sender.character_damage and sender:character_damage().swansong) then
                    --self:Stat(pid,'shot',1,true)
                --end
            end

            self:Stat(pid,'dmg',rDamage*10,true)

            if head then
                self:Stat(pid,'head',1,true)
            end
            if death then
                self.killa = self.killa +1
                self:Stat(pid,'kill',1,true)
                if isSpecial then
                    self:Stat(pid,'killS',1,true)
                end
                local mA = O:get('chat','midstatAnnounce') or 0
                if mA > 0 and Network:is_server() and (self.killa % (mA*50) == 0) then
                    self:AnnounceStat(true)
                end
            end
        end
        if pid == self.pid and not popupO.myDamage then return
        elseif pid == 0 and not popupO.AiDamage then return
        elseif not popupO.crewDamage then
            if pid > 0 and pid ~= self.pid then
                return
            end
        end
        self:Popup( {pos=pos, text=texts,
                        stay=false, crit=isCrit,
                        et=now()+(isCrit and dmgTime*1.2 or dmgTime)
                    })
    end)
    if not r then _(err) end
end
--- Internal functions ---
function TPocoHud3:pidToPeer(pid)
    local session = managers.network:session()
    return session and session:peer(pid)
end

function TPocoHud3:say(line,sync)
    if line then
        --[[local cs = _.g('managers.player:player_unit():movement()._current_state')
        if cs then
            cs._intimidate_t = now()
            pcall(self.Buff,self,({
                key='interact', good=false,
                icon=SkillIcons,
                iconRect = { 2*64, 8*64, 64,64 },
                st=now(), et=now()+tweak_data.player.movement_state.interaction_delay
            }) )
        end]]
        --[[
        if _.g('managers.groupai:state()') then
            managers.groupai:state():teammate_comment(_.g('managers.player:player_unit()'), line, nil, false, nil, false)
            return true
        end]]
        local sound = _.g('managers.player:player_unit():sound()')
        if not sound then return end
        return sound:say(line,true,sync)
    end
end

function TPocoHud3:toggleRose2(show)
    self:toggleRose(show, false)
end
function TPocoHud3:toggleRose(show, rose2)
    if self._noRose then return end
    local C = PocoHud3Class
    local canOpen = self.inGameDeep and (not self._lastSay or now()-self._lastSay > tweak_data.player.movement_state.interaction_delay / 2)
    local r,err = pcall(function()
        local menu = self.menuGui
        if menu and not self._guiFading then -- hide
            self.menuGui = nil
            self._guiFading = true
            if self._say then
                if self:say(self._say,true) then
                    self._lastSay = now()
                end
                self._say = nil
            end
            menu:fadeOut(function()
                self._guiFading = nil
                menu:destroy()
            end)
        elseif canOpen and show and not self._guiFading then -- create
            local gui = C.PocoMenu:new(self._ws,true)
            self.menuGui = gui
            gui:fadeIn()
            local tab = gui:add('Rose')
            C._drawRose(tab, rose2 or false)
        elseif not canOpen and show then
            -- managers.menu:post_event('menu_error')
        end
    end)
    if not r then
        self:err(_.s('ToggleRose',err))
    end
end

function TPocoHud3:Menu(dismiss, skipAnim)
    local C = PocoHud3Class
    local _drawUpgrades = C._drawUpgrades

    local r,err = pcall(function()
        local menu = self.menuGui
        if menu then -- Remove
            self:_updateBind()
            if not self._stringFocused or (now()-self._stringFocused > 0.1) then
                self.menuGui = nil
                self._noRose = nil
                self._guiFading = true
                if self.onMenuDismiss then
                    local cbk = self.onMenuDismiss
                    self.onMenuDismiss = nil
                    cbk()
                end
                if not self:say('g92',true) then
                    managers.menu_component:post_event('menu_exit')
                end

                if skipAnim then
                    menu:destroy()
                    self._guiFading = nil
                else
                    menu:fadeOut(function()
                        self._guiFading = nil
                        menu:destroy()
                    end)
                end
            end
        elseif not dismiss and not self._guiFading and not managers.system_menu:is_active() then -- Show
            if not self:say('a01x_any',true) then
                managers.menu_component:post_event('menu_enter')
            end
            local gui = C.PocoMenu:new(self._ws)
            self.menuGui = gui
            self._noRose = true
            gui:fadeIn()
            --- Install tabs Begin --- ===================================
            local tab = gui:add(L('_tab_about'))
            C._drawAbout(tab,REV,TAG)

            local tab = gui:add(L('_tab_options'))
            C._drawOptions(tab)

            local y = 0
            tab = gui:add(L('_tab_statistics'))
            do
                local oTabs = C.PocoTabs:new(self._ws,{name = 'stats',x = 10, y = 10, w = 1220, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
                local oTab = oTabs:add(L('_tab_heistStatus'))
                local r,err = pcall(C._drawHeistStats,oTab) -- yeaaaah just in case. I know. I'm cheap
                if not r then me:err('DHS:'..tostring(err) ) end

                oTab = oTabs:add(L('_tab_upgradeSkills'))
                if inGame then
                    for pid,upg in pairs(_.g('Global.player_manager.synced_team_upgrades',{})) do
                        if upg then
                            y = _drawUpgrades(oTab,upg,true,L('_upgr_crewBonusFrom',{self:_name(pid)}), y)
                        end
                    end
                end
                y = _drawUpgrades(oTab,_.g('Global.player_manager.team_upgrades'),true,L('_line_youAndCrewsPerks'),y)
                y = _drawUpgrades(oTab,_.g('Global.player_manager.upgrades'),false,L('_line_yourPerks'),y)
            end

            tab = gui:add(L('_tab_tools'))
            do
                local oTabs = C.PocoTabs:new(self._ws,{name = 'tools',x = 10, y = 10, w = 970, th = 30, fontSize = 18, h = tab.pnl:height()-20, pTab = tab})
                local oTab = oTabs:add(L('_tab_kitProfiler'))
                PocoHud3Class._drawKit(oTab)

                local oTab = oTabs:add(L('_tab_jukebox'))
                PocoHud3Class._drawJukebox(oTab)
            end
        end
    end)
    if not r then _('MenuCallErr',err) end
end
function TPocoHud3:AnnounceStat(midgame)
    local txt = {}
    table.insert(txt,Icon.LC..'PocoHud³ r'..REV.. ' '.. Icon.RC..' '..L('_stat_crewKills',{Icon.Skull,self.killa}))
    for pid = 0, 4 do
        local kill = self:Stat(pid,'kill')
        local killS = self:Stat(pid,'killS')
        local head = self:Stat(pid,'head')
        if kill > 0 then
            local dt = now()-self:Stat(pid,'time')
            local dps = _.f(self:Stat(pid,'dmg')/dt or 0)
            local hit = math.max(self:Stat(pid,'hit'),1)
            local shot = math.max(self:Stat(pid,'shot'),1)
            local accuracy = _.f(hit/shot*100,0)..'%'
            local kpm = _.f(60*kill/dt)
            local downs = self:Stat(pid,'downAll')
            local downsIncap = self:Stat(pid,'downIncap')
            if midgame then
                table.insert(txt,
                    _.s(Icon.LC..self:_name(pid)..Icon.RC,
                        kill..Icon.Skull..(killS>0 and ', '..killS..' Sp' or '')..(head>0 and ', '..head..' Hs' or ''),

                        ((downs>0 or downsIncap>0) and downs..'|'..downsIncap..Icon.Ghost or nil)
                    )
                )
            else
                table.insert(txt,
                    _.s(Icon.LC..self:_name(pid)..Icon.RC,
                        kill..Icon.Skull..(killS>0 and ', '..killS..' Sp' or '')..(head>0 and ', '..head..' Hs' or ''),'|',
                        'DPS:'..dps,'|',
                        'KPM:'..kpm,'|',
                        'Acc:'..(pid==0 and 'N/A' or accuracy),
                        ((downs>0 or downsIncap>0) and downs..'|'..downsIncap..Icon.Ghost or nil)
                    )
                )
            end
        end
    end
    if #txt > 3 then
        for ___,tx in ipairs(txt) do
        self:Chat(midgame and 'midStat' or 'endStat',tx)
        end
    else
        self:Chat(midgame and 'midStat' or 'endStat',table.concat(txt,'\n'))
    end
end
function TPocoHud3:SetIngame(ingame, override)
    if self.inGameDeep == ingame and not override then
        return
    end
    if ingame then
        self._startGameT = now()
        if managers.crime_spree.is_active()
            and managers.job:is_level_ghostable(managers.job:current_level_id())
            and not override then
            for k,v in pairs(tweak_data.player.alarm_pager.bluff_success_chance) do
                if v <= 0 then
                    self:Chat('havePagers',L('_msg_havePagers',{k-1}))
                end
            end
            for k,v in pairs(managers.crime_spree._modifiers or {}) do
                if v._type == 'ModifierCivilianAlarm' then
                    self:Chat('haveCivilians',L('_msg_haveCivilians',{v:value()}))
                end
            end
        end
        RecomputeContourDuration()
        AdjustPolling()
        -- Ensure the polling functions run at least once
        PollBikerKills()
        PollUppersRange()
        PollDodgeChance()
        PollCriticalChance()
        CheckAbility()
    else
        self._endGameT = now()
    end
    self.inGameDeep = ingame
end
local lastSlowT = 0
function TPocoHud3:_slowUpdate(t, dt)
    self.ww = self.pnl.dbg:w()
    self.hh = self.pnl.dbg:h()
    if inGame then
        local peers = _.g('managers.network:session():peers()',{})
        for pid, peer in pairs(peers) do
            if peer and peer:rpc() then
                self:Stat(pid,'ping',math.floor(Network:qos(peer:rpc()).ping))
            end
        end
        self.pid = _.g('managers.network:session():local_peer():id()')
    end
end
function TPocoHud3:_update(t,dt)
    if not (PocoHud3Class and not self.dead) then return end
    self:_upd_dbgLbl(t,dt)
    self.cam = managers.viewport:get_current_camera()
    if not self.cam then return end
    self.rot = self.cam:rotation()
    self.camPos = self.cam:position()
    self.nl_cam_forward = self.rot:y()
    if t - lastSlowT > 5 then -- SlowUpdate
        lastSlowT = t
        self:_slowUpdate(t,dt)
    end

    if inGame and Global.game_settings.is_playing then
        self:_updateItems(t,dt)
    end
    if self.menuGui then
        self.menuGui:update(t,dt)
    end
    local location = PocoHud3Class.PocoLocation
    location:update(t,dt)
    if self.inGameDeep and now() - (self._lastRoom or 0) > 1 then
        self._lastRoom = now()
        local room = _.g('Poco.room')
        local session = managers.network:session()
        if session then
            for pid=1,4 do
                local unit = self:Stat(pid,'custody') == 0 and room and session:peer(pid) and session:peer(pid):unit()
                if unit and alive(unit) then
                    self:Stat(pid,'room',room:get(unit:movement():m_pos(),true))
                end
            end
        end
    end
end

function TPocoHud3:HitDirection(col_ray,data)
    local mobPos
    if self._lastAttkUnit and alive(self._lastAttkUnit) then
        mobPos = self._lastAttkUnit:position()
        self._lastAttkUnit = nil
    elseif col_ray and col_ray.position and col_ray.distance then
        mobPos = col_ray.position - (col_ray.ray*(col_ray.distance or 0))
    end
    if not mobPos then -- still nothing? now we search data
        local mobUnit = data.weapon_unit or data.attacker_unit
        if mobUnit and alive(mobUnit) then
            mobPos = mobUnit:position()
        else
            mobPos = data.hit_pos or data.position
        end
    end
    if not mobPos then -- still no?... set to player position
        mobPos = _.g('managers.player:player_unit():position()')
    end
    if mobPos then
        table.insert(self.hits, PocoHud3Class.THitDirection:new(self,{mobPos=mobPos,shield=data.shield,dmg=data.dmg,time=data.time,rate=data.rate}))
    end
end
function TPocoHud3:Minion(pid, unit, silent)
    local m = {}
    m[1] = self:Stat(pid,'minion')
    m[2] = self:Stat(pid,'minion2')

    if m[1] ~= 0 and m[1] == unit and not alive(unit) then
        self:Stat(pid,'minion',0)
        return
    end
    if m[2] ~= 0 and m[2] == unit and not alive(unit)  then
        self:Stat(pid,'minion2',0)
        return
    end
    local slot = m[1] == 0 and 1 or (m[2] == 0 and 2 or 0)
    if alive(unit) then
        if slot == 0 then
            slot = alive(m[1]) and 2 or 1
        end

        self:Stat(pid,'minion'..(slot > 1 and slot or ''),unit)
        if not silent then
            self:Chat('converted',L('_msg_converted',{self:_name(pid),self:_name(unit),O:get('chat','includeLocation') and self:_name(pid,true) or ''}))
        end
        return slot
    end
end
function TPocoHud3:MinionKilled(params, unit)
    local callback_key = "PocoConvert"
    unit:character_damage():remove_listener(callback_key)
    unit:base():remove_destroy_listener(callback_key)
    self:KillFloat(unit, params.key)
    if params.slot then
        local slot = params.slot
        local stat = "minion" .. (slot > 1 and slot or "")
        self:Stat(params.peer_id, stat, 0)
    end
    if self._endGameT then
        return
    end
    local minionLocName = unit.position and self:_name(unit:position(),true) or nil
    self:Chat('minionLost',L('_msg_minionLost',{self:_name(params.peer_id or 0),self:_name(unit),(O:get('chat','includeLocation') and minionLocName) and ', '..minionLocName or ''}))
end
function TPocoHud3:MinionTraded(unit)
    for i = 1, self._n_of_players, 1 do
        local minion = self:Stat(i,'minion')
        local minion2 = self:Stat(i,'minion2')
        if minion == unit then
            self:MinionKilled({ peer_id = i, slot = 1 }, unit)
            return
        elseif minion2 == unit then
            self:MinionKilled({ peer_id = i, slot = 2 }, unit)
            return
        end
    end
end
function TPocoHud3:Chat(category,text,system)
    local catInd = O:get('chat',category) or -1
    local forceSend = catInd >= 5
    if not O:get('chat','enable') then return end
    if self._muted and not forceSend then return _('Muted:',text) end
    local canRead = catInd >= 1
    local isFullGame = not managers.statistics:is_dropin()
    local canSend = catInd >= (Network:is_server() and 2 or isFullGame and 3 or 4)
    if catInd >= 3 and not canSend and not O:get('chat','fallbackToMe')then
        canRead = false
    end
    local tStr = _.g('managers.hud._hud_heist_timer._timer_text:text()', '')
    if canRead or canSend then
        _.c(tStr..(canSend and '' or _BROADCASTHDR_HIDDEN), text,  canSend and self:_color(self.pid) or nil)
        if canSend then
            managers.network:session():send_to_peers_ip_verified('send_chat_message', system and 8 or 1, tStr.._BROADCASTHDR.._.s(text))
        end
    end
end
function TPocoHud3:Float(unit, category, temp, tag)
    local key = unit.key and unit:key()
    if not key then return end
    if not O:get('float','enable') then return end
    local float = self.floats[key]
    if float then
        float:renew({tag=tag,temp=temp})
    else
        if category == 1 and not O:get('float','showDrills') then
            --
        else
            self.floats[key] = PocoHud3Class.TFloat:new(self,{category=category,key=key,unit=unit,temp=temp, tag=tag})
        end
    end
end
function TPocoHud3:MinionFloat(unit, category, tag)
    local key = unit.key and unit:key()
    if not key then return end
    if not O:get('float','enable') then return end
    local float = self.floats[key]
    if float then
        float:destroy(1)
        self.floats[key] = PocoHud3Class.TMinionFloat:new(self,{category=category,key=key,unit=unit,temp=false, tag=tag})
    elseif category == 0 then
        self.floats[key] = PocoHud3Class.TMinionFloat:new(self,{category=category,key=key,unit=unit,temp=false, tag=tag})
    end
end
function TPocoHud3:KillFloat(unit, key)
    key = key or unit.key and unit:key()
    if not key then return end
    local float = self.floats[key]
    if float then
        float:SetDead()
    end
end
function TPocoHud3:Buff(data) -- {key='',icon=''||{},text={{},{}},st,et}
    if not O:get('buff','enable') then return end
    if not O:get('buff','show'.. (data.key:gsub('^%l', string.upper))) then return end
    local buff = self.buffs[data.key]
    if buff and not data.t and (buff.data.et ~= data.et or buff.data.good ~= data.good) then
        buff:destroy(1)
        buff = nil
    end
    if not buff then
        buff = PocoHud3Class.TBuff:new(self,data)
        self.buffs[data.key] = buff
    else
        buff:set(data)
    end
end
-- Same function as TPocoHud3:Buff(), but without skill check. The check is performed before this function is called
function TPocoHud3:Buff2(data) -- {key='',icon=''||{},text={{},{}},st,et}
    if not O:get('buff','enable') then return end
    local buff = self.buffs[data.key]
    if buff and not data.t and (buff.data.et ~= data.et or buff.data.good ~= data.good) then
        buff:destroy(1)
        buff = nil
    end
    if not buff then
        buff = PocoHud3Class.TBuff:new(self,data)
        self.buffs[data.key] = buff
    else
        buff:set(data)
    end
end
-- Same function as TPocoHud3:Buff() and TPocoHud3:Buff2(), but without skill and buff enabled check. The checks are performed before this function is called
function TPocoHud3:Buff3(data)
    local buff = self.buffs[data.key]
    if buff and not data.t and (buff.data.et ~= data.et or buff.data.good ~= data.good) then
        buff:destroy(1)
        buff = nil
    end
    if not buff then
        buff = PocoHud3Class.TBuff:new(self,data)
        self.buffs[data.key] = buff
    else
        buff:set(data)
    end
end
-- Same function as TPocoHud3:Buff(), but without buff enabled check. The check is performed before this function is called
function TPocoHud3:Buff4(data)
    if not O:get('buff','show'.. (data.key:gsub('^%l', string.upper))) then return end
    local buff = self.buffs[data.key]
    if buff and not data.t and (buff.data.et ~= data.et or buff.data.good ~= data.good) then
        buff:destroy(1)
        buff = nil
    end
    if not buff then
        buff = PocoHud3Class.TBuff:new(self,data)
        self.buffs[data.key] = buff
    else
        buff:set(data)
    end
end
function TPocoHud3:GaugeBuff(data) -- {key='',icon=''||{},text={{},{}},st}
    if not O:get('buff','enable') then return end
    if not O:get('buff','show'.. (data.key:gsub('^%l', string.upper))) then return end
    local buff = self.buffs[data.key]
    if buff and buff.data.good ~= data.good then
        buff:destroy(1)
        buff = nil
    end
    if not buff then
        buff = PocoHud3Class.TGaugeBuff:new(self,data)
        self.buffs[data.key] = buff
    else
        buff:set(data)
    end
end
-- Same function as TPocoHud3:GaugeBuff(), but without skill check. The check is performed before this function is called
function TPocoHud3:GaugeBuff2(data)
    if not O:get('buff','enable') then return end
    local buff = self.buffs[data.key]
    if buff and buff.data.good ~= data.good then
        buff:destroy(1)
        buff = nil
    end
    if not buff then
        buff = PocoHud3Class.TGaugeBuff:new(self,data)
        self.buffs[data.key] = buff
    else
        buff:set(data)
    end
end
-- Same function as TPocoHud3:GaugeBuff() and TPocoHud3:GaugeBuff2(), but without skill and buff enabled check. The checks are performed before this function is called
function TPocoHud3:GaugeBuff3(data)
    local buff = self.buffs[data.key]
    if buff and buff.data.good ~= data.good then
        buff:destroy(1)
        buff = nil
    end
    if not buff then
        buff = PocoHud3Class.TGaugeBuff:new(self,data)
        self.buffs[data.key] = buff
    else
        buff:set(data)
    end
end

function TPocoHud3:SimpleFloat(data) -- {key,x,y,time,text,size,val,anim,offset,icon,rect}
    local key = data.key
    if key and self.sFloats[key] then
        self.sFloats[key]:hide()
        self.sFloats[key] = nil
    end
    local pnl = self.pnl.dbg:panel{x = data.x, y = data.y, w=500, h=100}
    if key then
        self.sFloats[key] = pnl
    end
    pnl:rect{color=cl.Black,layer=-1,alpha=data.rect or 0.9}
    local offset = data.offset or {0,0}
    local anim = data.anim
    local __, lbl = _.l({pnl=pnl,x=5,y=5, font=FONT, color=cl.White, font_size=data.size},data.text,true)
    if data.icon then
        local icon,rect = unpack(data.icon)
        local bmp = pnl:bitmap{
            name = 'icon',
            texture = icon,
            texture_rect = rect,
            x = 5, y = 5
        }
        bmp:set_center_y(5 + data.size/2)

        lbl:set_x(bmp:width()+10)
    end
    pnl:set_size(lbl:right()+5,lbl:bottom()+5)
    pnl:stop()
    local t = now()
    pnl:animate(function(p)
        while alive(p) and p:visible() do
            local dt = now() - t
            local r = dt / data.time
            if r > 1 then break end
            if anim == 1 then
                r = math.pow(r,0.5)
                local rr = math.min(r,1-r)
                p:set_alpha(math.pow(rr,0.4))
            end
            local dx,dy = offset[1] * r, offset[2] * r
            p:set_position(math.floor(data.x + dx),math.floor(data.y + dy))
            coroutine.yield()
        end
        if alive(p) then
            if p:visible() then
                self.sFloats[key] = nil
            end
            p:parent():remove(p)
        end
    end)
end

function TPocoHud3:Popup(data) -- {pos=pos,text={{},{}},stay=true,st,et}
    table.insert(self.pops, PocoHud3Class.TPop:new(self, data))
end

function TPocoHud3:_updateBind()
    Poco:UnBind(self)
    local verboseKey = O:get('root','detailedModeKey')
    if verboseKey then
        if O:get('root','detailedModeToggle') then
            Poco:Bind(self,verboseKey,callback(self,self,'toggleVerbose','toggle'))
        else
            Poco:Bind(self,verboseKey,callback(self,self,'toggleVerbose',true),callback(self,self,'toggleVerbose',false))
        end
    end
    local pocoRoseKey = O:get('root','pocoRoseKey')
    Poco:Bind(self,pocoRoseKey,callback(self,self,'toggleRose',true,false),callback(self,self,'toggleRose',false,false))
    local pocoRose2Key = O:get('root','pocoRoseKey2')
    Poco:Bind(self,pocoRose2Key,callback(self,self,'toggleRose2',true,false),callback(self,self,'toggleRose2',false,false))

    Poco:Bind(self,O:get('root','optionsMenuKey'),function()
        self:Menu(false,false)
    end)
    local keys = K:keys()
    for key,index in pairs(keys) do
        Poco:Bind(self,key,function()
            if not self.inGameDeep and ctrl() and alt() and not managers.system_menu:is_active() then
                K:equip(index,not O:get('root','silentKitShortcut'))
                managers.menu:post_event('finalize_mask')
            end
        end)
    end
end

function TPocoHud3:_checkBuff(t)
    -- Check Another Buffs
    -- Berserker
    if managers.player:upgrade_value( 'player', 'melee_damage_health_ratio_multiplier', 0 ) > 0 then
        local health_ratio = _.g('managers.player:player_unit():character_damage():health_ratio()')
        if (health_ratio and health_ratio <= tweak_data.upgrades.player_damage_health_ratio_threshold ) then
            local damage_ratio = 1 - (health_ratio / math.max(0.01, tweak_data.upgrades.player_damage_health_ratio_threshold))
            local mMul = 1 + managers.player:upgrade_value('player', 'melee_damage_health_ratio_multiplier', 0) * damage_ratio
            local rMul = 1 + managers.player:upgrade_value('player', 'damage_health_ratio_multiplier', 0) * damage_ratio
            if mMul*rMul > 1 then
                local text = {{(mMul>1 and _.f(mMul)..'x' or '')..(rMul>1 and ' '.._.f(rMul)..'x' or ''),clBad}}
                self:Buff({
                    key= 'berserker', good=true,
                    icon=SkillIcons,
                    iconRect = { 2*64, 2*64,64,64 },
                    text=text,
                    color=cl.Red,
                    st=O:get('buff','style')==2 and damage_ratio or 1-damage_ratio, et=1
                })
            end
        else
            self:RemoveBuff('berserker')
        end
    end

    -- Stamina
    local movement = _.g('managers.player:player_unit():movement()')
    if movement then
        local currSt = movement._stamina
        local maxSt = movement:_max_stamina()
        local thrSt = movement:is_above_stamina_threshold()
        if currSt < maxSt then
            self:Buff({
                key= 'stamina', good=false,
                icon=SkillIcons,
                iconRect = { 7*64, 3*64,64,64 },
                text=thrSt and '' or L('_buff_exhausted'),
                st=(currSt/maxSt), et=1
            })
        else
            self:RemoveBuff('stamina')
        end
    end
    local t = Application:time()
    -- Suppression
    local supp = _.g('managers.player:player_unit():character_damage():effective_suppression_ratio()')
    if supp and supp > 0 then
        -- Not in effect as of now : local supp2 = math.lerp( 1, tweak_data.player.suppression.spread_mul, supp )
        self:Buff({
            key= 'suppressed', good=false,
            icon=SkillIcons,
            iconRect = { 7*64, 0*64,64,64 },
            text='', --_.f(supp2)..'x',
            st=supp, et=1
        })
    else
        self:RemoveBuff('suppressed')
    end

    local melee = self.state and self.state._state_data.meleeing and self.state:_get_melee_charge_lerp_value( t ) or 0
    if melee > 0 then
        self:Buff({
            key= 'charge', good=true,
            icon=SkillIcons,
            iconRect = { 4*64, 12*64,64,64 },
            text='',
            st=melee, et=1
        })
    else
        self:RemoveBuff('charge')
    end
end

function TPocoHud3:_BottomPanel(name, isFlt, o, onlyMe, isMe)
    local thr = o['show'..name] or 0
    local ind = self.verbose and 1 or 2
    if onlyMe and thr==2 and not isFlt then
        return isMe
    end
    return thr >= ind
end

function TPocoHud3:_updatePlayers(t)
    if t-(self._lastUP or 0) > 0.05 and self.inGameDeep then
        self._lastUP = t
    else
        return
    end

    local onlyMe = btmO.onlyMe and not self.verbose
    local m = managers
    local teammate_panels = m.hud._teammate_panels
    local criminals = m.criminals
    for i = 1, 4 do
        local name = self:_name(i)
        name = name ~= self:_name(-1) and name
        local nData = m.hud:_name_label_by_peer_id(i)
        local isMe = i == self.pid
        local playtime = me:Stat(i,'playtime')
        local pnl = self['pnl_'..i]
        pnl = pnl ~= 0 and pnl or nil

        local TPoco3_updPlayers_wp

        if pnl and (not name or not btmO.enable) then -- or self:Stat(i,'_refreshBtm') ~= 0 then
            -- killPnl
            self.pnl.stat:remove(pnl)
            self['pnl_'..i] = nil
            self:Stat(i,'_refreshBtm',0)
        elseif not pnl and name and (isMe or nData) and me:Stat(i,'noPanel') == 0 then
            -- makePnl
            local _, err = pcall(function()
                    if not self.custom_hud_enabled and btmO.enable and criminals:character_unit_by_name(criminals:character_name_by_peer_id(i)) then
                        local cdata = criminals:character_data_by_peer_id(i) or {}
                        local bPnl = teammate_panels[isMe and 4 or cdata.panel_id or -1]
                        if bPnl and not (not isMe and bPnl == teammate_panels[4]) then
                            local peer = self:_peer(i)
                            if peer and alive(peer:unit()) then
                                if btmO.showRank then
                                    local rank = ''
                                    local lvl = ''
                                    if not isMe and btmO.rankToPlaytime and playtime > 0 then
                                        rank = playtime..PocoLocale._hours..' '
                                        lvl = ''
                                    else
                                        rank = isMe and managers.experience:current_rank() or (peer and peer:rank())
                                        rank = rank and (rank > 0) and ('['..managers.experience:rank_string(rank)..'] ') or ''
                                        lvl = isMe and managers.experience:current_level() or peer and peer:level() or ''
                                        lvl = rank == '' and (lvl..' ') or lvl
                                    end
                                    local defaultLbl = bPnl._panel:child('name')
                                    local nameBg =  bPnl._panel:child('name_bg')
                                    local nameTxt = self:_name(i)
                                    if btmO.uppercaseNames then
                                        nameTxt = utf8.to_upper(nameTxt)
                                    end
                                    self:_lbl(defaultLbl,{{lvl,cl.White:with_alpha(0.8)},{rank,cl.White},{nameTxt,self:_color(i)}})
                                    local txtRect = {defaultLbl:text_rect()}
                                    defaultLbl:set_size(txtRect[3],txtRect[4])
                                    local shape = {defaultLbl:shape()}
                                    nameBg:set_shape(shape[1]-3,shape[2],shape[3]+6,shape[4])
                                end

                                pnl = self.pnl.stat:panel{x = 0,y=0, w=240,h=btmO.size*2+1}
                                local wp = {bPnl._player_panel:world_position()}
                                TPoco3_updPlayers_wp = wp

                                local fontSize = btmO.size
                                --self['pnl_blur'..i] = pnl:bitmap( { name='blur', texture='guis/textures/test_blur_df', render_template='VertexColorTexturedBlur3D', layer=-1, x=0,y=0 } )
                                self['pnl_lbl'..i] = pnl:text{rotation=360,name='lbl',align='right', text='-', font=FONT, font_size = fontSize, color = cl.Red, x=1,y=0, layer=2, blend_mode = 'normal'}
                                self['pnl_lblA'..i] = pnl:text{name='lblA',align='right', text='-', font=FONT, font_size = fontSize, color = cl.Black:with_alpha(0.4), x=0,y=1, layer=1, blend_mode = 'normal'}
                                self['pnl_lblB'..i] = pnl:text{name='lblB',align='right', text='-', font=FONT, font_size = fontSize, color = cl.Black:with_alpha(0.4), x=2,y=1, layer=1, blend_mode = 'normal'}
                                self['pnl_'..i] = pnl

                                -- install arrow
                                local hPnl = bPnl._player_panel:child('radial_health_panel')
                                if hPnl:child('arrow') then
                                    hPnl:remove(hPnl:child('arrow'))
                                end
                                if btmO.showArrow then
                                    local arrow = hPnl:bitmap{
                                        name= 'arrow',
                                        texture= 'guis/textures/pd2/scrollbar_arrows',
                                        texture_rect = {0,0,12,12},
                                        layer= 10,
                                        color= self:_color(i):with_alpha(0.7),
                                        blend_mode= 'add',
                                        x= 0, y=0,
                                        w= 20,
                                        h= 10,
                                        rotation = 360,
                                    }
                                    local currAngle = 360
                                    local tAngle = 360
                                    local lastT = 0
                                    local unit = isMe and self:Stat(i,'minion') or nData and nData.movement._unit
                                    local mcos,msin = math.cos,math.sin
                                    local w,h = hPnl:w(),hPnl:h()
                                    local r = (isMe and 64 or 48) / 2 +4
                                    hPnl:stop()
                                    hPnl:animate(function(p,t)
                                        while alive(p) and arrow and alive(arrow) do
                                            local nowT = now()
                                            if nowT - lastT > 0.1 then
                                                if isMe then
                                                    unit = self:Stat(i,'minion')
                                                end
                                                lastT = nowT
                                                tAngle = self:_getAngle(unit)
                                            end
                                            if self.dead then break end
                                            arrow:set_visible(tAngle ~= 360)
                                            if tAngle then
                                                if math.abs(tAngle-currAngle) > 180 then
                                                    currAngle = currAngle + (tAngle>currAngle and 360 or -360)
                                                end
                                                currAngle = currAngle + (tAngle - currAngle)/5
                                                if currAngle == 0 then
                                                    currAngle = 360
                                                end
                                                arrow:set_rotation(currAngle)
                                                arrow:set_center(w/2 + r*msin(currAngle),h/2 - r*mcos(currAngle))
                                            end
                                            coroutine.yield()
                                        end
                                    end)

                                    self['pnl_arrow'..i] = arrow
                                end
                                -- arrow end
                            end
                        end
                    end
            end)
        end

        -- playerBottom
        local color = self:_color(i)
        local txts = {}
        if not self.custom_hud_enabled and pnl and (nData or isMe) and not self.dead then
            local lbl = self['pnl_lbl'..i]
            local cdata = criminals:character_data_by_peer_id(i) or {}
            local pInd = isMe and 4 or cdata.panel_id
            local bPnl = teammate_panels[pInd]
            local equip = (bPnl and #bPnl._special_equipment > 0)
            local interText = nData and nData.interact:visible() and nData.panel:child('action') and nData.panel:child('action'):text()
            if isMe then
                interText = m.hud._progress_timer
                    and m.hud._progress_timer._hud_panel:child('progress_timer_text'):visible()
                    and m.hud._progress_timer._hud_panel:child('progress_timer_text'):text()
            end
            local unit = nData and nData.movement._unit
            local hit = math.max(self:Stat(i,'hit'),1)
            local shot = math.max(self:Stat(i,'shot'),1)
            local accuracy = _.f(hit/shot*100,0)
            local accColor = math.lerp(cl.Red,cl.Green,hit/shot)
            local boost = self:Stat(i,'boost') > now()
            local unitPos = unit and alive(unit) and unit:position()
            local distance = unitPos and mvector3.distance(unitPos,self.camPos) or 0
            local interT = self:Stat(i,'interactET')
            local room = self:Stat(i,'room')
            if btmO.underneath then
                txts[#txts+1]={'\n'}
            end
            if interT>0 and self:_BottomPanel('InteractionTime', nil, btmO, onlyMe, isMe) then
                local st,et = self:Stat(i,'interactST'), interT
                local t,tt = now()-st,et-st
                local r,rt = t/math.max(0.01,tt), tt-t
                local c = math.lerp(cl.Aqua,cl.Lime,r)
                txts[#txts+1]={' '.._.f(rt),c}
                if rt < 0 then
                    self:Stat(i,'interactET',0)
                end
            end
            if interText and self:_BottomPanel('Interaction', nil, btmO, onlyMe, isMe) then
                txts[#txts+1]={' '..interText,cl.White}
            end
            if room and room ~= 0 and self:_BottomPanel('Position', nil, btmO, onlyMe, isMe) then
                txts[#txts+1]={' '..utf8.to_upper(room),cl.White:with_alpha(0.5)}
            end
            if not btmO.underneath then
                txts[#txts+1]={'\n'}
            end
            if self:_BottomPanel('DetectionRisk', nil, btmO, onlyMe, isMe) then
                local suspicion
                local blackmarket = m.blackmarket
                if isMe then
                    suspicion = blackmarket:get_suspicion_offset_of_local(75)
                else
                    local peer = self:_peer(i)
                    if peer and alive(peer:unit()) then
                        suspicion = blackmarket:get_suspicion_offset_of_peer(peer, 75)
                    end
                end
                if suspicion then
                    txts[#txts+1]={' '..Icon.Ghost..string_format("%.0f%%", suspicion),cl.CornFlowerBlue}
                end
            end

            if self:_BottomPanel('Kill', nil, btmO, onlyMe, isMe) then
                local kill = self:Stat(i,'kill')
                txts[#txts+1]={' '..Icon.Skull..kill,color}
            end
            if self:_BottomPanel('Special', nil, btmO, onlyMe, isMe) then
                local killS = self:Stat(i,'killS')
                txts[#txts+1]={' '..Icon.Skull..killS,cl.Yellow:with_alpha(0.8)}
            end
            if self:_BottomPanel('Head', nil, btmO, onlyMe, isMe) then
                local head = self:Stat(i,'head')
                txts[#txts+1]={' '..Icon.Skull..head,cl.Orange:with_alpha(1)}
            end
            if self:_BottomPanel('AverageDamage', nil, btmO, onlyMe, isMe) then
                local dmg = self:Stat(i,'dmg')
                local avgDmg = _.f(dmg/hit,1)
                txts[#txts+1]={' ±'..avgDmg,color:with_alpha(0.8)}
            end

            if self:_BottomPanel('ConvertedEnemy', nil, btmO, onlyMe, isMe) then
                local minion = self:Stat(i,'minion')
                local minion2 = self:Stat(i,'minion2')
                minion2 = (minion2 ~= 0 and alive(minion2)) and minion2 or nil
                if minion ~= 0 and alive(minion) then
                    local cd = minion:character_damage()
                    local c = cd._health
                    local f = cd._health_max or cd._HEALTH_INIT
                    if f then
                        txts[#txts+1]={' '..math.floor(c/f*100)..(minion2~=nil and '' or '%'),math.lerp( cl.OrangeRed, color, c/f ):with_alpha(0.5)}
                    end
                else
                    minion = nil
                end
                if minion2 then
                    local cd = minion2:character_damage()
                    local c = cd._health
                    local f = cd._health_max or cd._HEALTH_INIT
                    if f then
                        txts[#txts+1]={(minion~=nil and '|' or ' '), cl.Gray}
                        txts[#txts+1]={math.floor(c/f*100)..'%',math.lerp( cl.OrangeRed, color, c/f ):with_alpha(0.5)}
                    end
                end
                if not(minion or minion2) then
                    txts[#txts+1]={' '..Icon.Times,cl.OrangeRed:with_alpha(0.5)}
                end
            end

            if self:_BottomPanel('Accuracy', nil, btmO, onlyMe, isMe) then
                --txts[#txts+1]={' !',color:with_red(1)}
                --txts[#txts+1]={_.f(head/hit*100,1)..'%',color:with_red(1)}
                --txts[#txts+1]={Icon.Times..accuracy..'%',accColor}
                txts[#txts+1]={' '..accuracy..'%',accColor}
            end

            if boost and self:_BottomPanel('Inspire', nil, btmO, onlyMe, isMe) then
                txts[#txts+1]={' '..Icon.Start or '',clGood:with_alpha(0.5)}
            end
            if distance > 0 and self:_BottomPanel('Distance', nil, btmO, onlyMe, isMe) then
                local dist_sq = unitPos and mvector3.distance_sq(unitPos,self.camPos) or 0
                local rally_skill_data = _.g('managers.player:player_unit():movement():rally_skill_data()')
                local canBoost = rally_skill_data and rally_skill_data.long_dis_revive and rally_skill_data.range_sq > dist_sq
                txts[#txts+1]={' '..math.ceil(distance/100)..'m',(canBoost and clGood or clBad):with_alpha(0.8)}
            end
            if self:_BottomPanel('Ping', nil, btmO, onlyMe, isMe) then
                local ping = self:Stat(i,'ping')>0 and ' '..self:Stat(i,'ping')..'ms' or ''
                txts[#txts+1]={ping,cl.White:with_alpha(0.5)}
            end
            if isMe and self:_BottomPanel('Hostages', nil, btmO, onlyMe, isMe) then
                txts[#txts+1]={' '..(self._nr_hostages or 0),cl.White:with_alpha(0.8)}
            end
            if self:_BottomPanel('Downs', nil, btmO, onlyMe, isMe) then
                local downs = self:Stat(i, "down")
                txts[#txts+1]={' ' .. Icon.Ghost .. downs, downs == 0 and Color.red or clGood}
            end
            if self:_BottomPanel('Incapacitations', nil, btmO, onlyMe, isMe) then
                local downsIncap = self:Stat(i,'downIncap')
                txts[#txts+1]={'|', cl.Gray}
                txts[#txts+1]={''..downsIncap, cl.Gray:with_alpha(0.8)}
            end

            if not isMe and self:_BottomPanel('Playtime', nil, btmO, onlyMe, isMe) and playtime > 0 then
                txts[#txts+1]={' '..playtime..PocoLocale._hours,Color.white}
            end

            if isMe and self:_BottomPanel('Clock', nil, btmO, onlyMe, isMe) then
                if O:get('root', '24HourClock') then
                    txts[#txts+1]={os.date(' %X'),Color.white}
                else
                    txts[#txts+1]={os.date(' %I:%M:%S%p'),Color.white}
                end
            end

            if isMe and self:_BottomPanel('FpsBottom', nil, btmO, onlyMe, isMe) and self.fps then
                txts[#txts+1]={' '..self.fps..' FPS',Color.white}
            end

            txts[#txts+1] = {' ',cl.White}

            if alive(lbl) and self['pnl_txt'..i]~=_.l(nil,txts) and self.hh then
                local txt = _.l(lbl,txts)
                self['pnl_txt'..i]=txt
                self['pnl_lblA'..i]:set_text(txt)
                self['pnl_lblB'..i]:set_text(txt)
                local tr = {lbl:text_rect()}
                lbl:set_size(pnl:w(),tr[4])
                self['pnl_lblA'..i]:set_size(pnl:w(),tr[4])
                self['pnl_lblB'..i]:set_size(pnl:w(),tr[4])
            end
            if TPoco3_updPlayers_wp then
                if alive(pnl) and not isMe then -- other player bottom infobar offset
                    pnl:set_world_position(TPoco3_updPlayers_wp[1] + (btmO.offsetX or 0)  + O:get('playerBottom','offsetXTeam'), TPoco3_updPlayers_wp[2]-pnl:h())
                else
                    pnl:set_world_position(TPoco3_updPlayers_wp[1] + (btmO.offsetX or 0), TPoco3_updPlayers_wp[2]-pnl:h())
                end
            end
            local btm = (self.hh or 0) - (btmO.underneath and 1 or ( (equip and 140 or 115) - (isMe and 0 or 38)) ) + (btmO.offset or 0)
            if alive(pnl) then
                pnl:set_bottom(btm)
            end
        end
    end
end
function TPocoHud3:_processMsg(channel,name,message,color)
    -- ToDo : better priority balancing, transmit more info etc
    local pid = 0
    for i = 1,4 do
        if color == self:_color(i) then
            pid = i
        end
    end
    local isMine = pid == self.pid
    local isPrioritized = pid < (self.pid or 0)
    local isPoco = channel == 8
    if not self._muted and isPrioritized and message and tostring(message):find(_BROADCASTHDR) then
        _.c(_BROADCASTHDR_HIDDEN,'PocoHud broadcast Muted.')
        self._muted = true
    end
end
function TPocoHud3:_isSimple(key)
    return buffO.simpleBusyIndicator and (key == 'transition' or key == 'reload' or key == 'charge')
end
local _mask = World:make_slot_mask(1, 8, 11, 12, 14, 16, 18, 21, 22, 24, 25, 26, 33, 34, 35)
function TPocoHud3:_updateItems(t,dt)
    if self.dead then
        return
    end

    self.state = self.state or _.g('managers.player:player_unit():movement():current_state()')
    self.ADS= self.state and self.state._state_data.in_steelsight
    self:_scanSmoke(t)
    self:_updatePlayers(t)
    -- ScanFloat
    --if O:get('float','showTargets') then
        local r = _.r(_mask)
        if r and r.unit then
            local unit = r.unit
            if unit and unit:in_slot(8) and alive(unit:parent()) then -- shield
                unit = unit:parent()
            end
            unit = unit and (unit:movement() or unit:carry_data()) and unit
            local isBag = unit and unit:carry_data()
            if unit then
                local cHealth = unit:character_damage() and unit:character_damage()._health or false
                if not isBag and cHealth and cHealth > 0 then
                    self:Float(unit,0,true) -- unit
                elseif isBag and unit:interaction()._active and O:get('float','showBags') then
                    self:Float(unit,0,true)	-- lootbag
                end
            end
        end
    --end
    -- ScanBuff
    self:_checkBuff(t)
    if t - (self._lastBuff or 0) >= 1/buffO.maxFPS then
        self._lastBuff = t
        local vanilla = buff_style == 2
        local align = buffO.justify
        local size = (vanilla and 40 or buffO.buffSize) + buffO.gap
        local count = 0
        for key,buff in pairs(self.buffs) do
            if not (buff.dead or buff.dying or self:_isSimple(key)) then
                count = count + 1
            end
        end
        local x,y,move = self._ws:size()
        x = x * buffO.xPosition/100 - size/2
        y = y * buffO.yPosition/100 - size/2
        local oX,oY = x,y
        if align == 1 then
            move = size
        elseif align == 2 then
            move = size
            if vanilla then
                y = y - count * size / 2
            else
                x = x - count * size / 2
            end
        else
            move = -size
        end
        for key,buff in _.p(self.buffs) do
            if not (buff.dead or buff.dying) then
                if self:_isSimple(key) then
                    -- do not move
                elseif vanilla then
                    y = y + move
                else
                    x = x + move
                end
                buff:draw(t,x,y)
            elseif not buff.dying then
                buff:destroy()
            end
        end
    end

    -- ProcessPops&Floats
    for key,pop in pairs(self.pops) do
        if pop.dead then
            pop:destroy(key)
        else
            pop:draw(t)
        end
    end
    for _, float in pairs(self.floats) do
        float:draw(t)
    end
end
function TPocoHud3:RemoveBuff(key,skipAnim)
    local buff = self.buffs[key]
    if buff and not buff.dying then
        buff.dead = true
        buff:destroy(skipAnim)
    end
end

function TPocoHud3:_upd_dbgLbl(t, dt)
    if self.dead then return end
    local dO = O:get('corner')
    self._dbgTxt = _.s("", self:lastError())
    self.fps = math.floor(1 / dt)
    local txt = ""
    if dO.showFPS then
        txt = self.fps .. " FPS "
    end
    if (self.inGameDeep and dO.showClockIngame) or (dO.showClockOutgame and not self.inGameDeep) then
        if O:get('root','24HourClock') then
            txt = txt .. os.date('%X')
        else
            txt = txt .. os.date('%I:%M:%S%p')
        end
    end
    txt = txt .. self._dbgTxt
    if t-(self._last_upd_dbgLbl or 0) > 0.5 or self._dbgTxt ~= self.__dbgTxt then
        self.__dbgTxt = self._dbgTxt
        self.dbgLbl:set_text(string.upper(txt))
        self._last_upd_dbgLbl = t
    end
end

local smoke_slot_mask = World:make_slot_mask(14)
function TPocoHud3:_scanSmoke(t)
    local smokeDecay = 3
    if O:get('float','showTargetsDeployables') then
        local units = World:find_units_quick('all', smoke_slot_mask)
        for i,smoke in pairs(units or {}) do
            if smoke:name():key() == '465d8f5aafa10ce5' then
                self.smokes[tostring(smoke:position())] = {smoke:position(),t}
            else
                local name = smoke:name():key()
                local per = 0

                name = _BAGS[name] or false

                if name then
                    --[[if smoke:base().take_ammo then
                        per = smoke:base()._ammo_amount / smoke:base()._max_ammo_amount
                    end]]
                    local sBase = smoke:base() or {}
                    if sBase._damage_reduction_upgrade
                        or (sBase._bullet_storm_level and 0 < sBase._bullet_storm_level)
                    then
                        name = name..'+'
                    end

                    if sBase._min_distance and sBase._min_distance > 10 then
                        name = name..'^'
                    end

                    local amount = sBase._ammo_amount
                                    or sBase._amount
                                    or sBase._bodybag_amount
                                    or sBase._grenade_amount
                                    or nil

                    if not sBase._unit or sBase._unit:interaction():active() then
                        name = name..(amount and Icon.Times or '').._.s(amount or '')
                        self:Float(smoke,2,1,{text=name})
                    end
                end
            end
        end
    end
    for id,smoke in pairs(clone(self.smokes)) do
        if t-smoke[2] > smokeDecay then
            self.smokes[id] = nil
        end
    end
end
function Poco:StatStatic(...)
    return(me:Stat(...))
end
function TPocoHud3:Stat(pid,key,data,add)
    if self.dead then return 0 end
    if pid then
        local stat = self.stats[pid] or {}
        if not self.stats[pid] then
            self.stats[pid] = stat
        end
        if not stat[key] and data == nil then
            return 0
        end
        if data then
            if add then
                stat[key] = (stat[key] or 0) + data
            else
                stat[key] = data
            end
        end
        return stat[key] or 0
    end
    return 0
end
function TPocoHud3:_pos(something,head)
    local t, unit = type(something)
    if t == 'number' and managers.network and managers.network:session() then
        local peer = managers.network:session():peer(something)
        unit = peer and peer:unit() or nil
    else
        unit = something
    end
    if not (unit and alive(unit)) then return Vector3() end
    local pos = Vector3()
    mvector3.set(pos,unit:position())
    if head and unit.movement and unit:movement() and unit:movement():m_head_pos() then
        mvector3.set_z(pos,unit:movement():m_head_pos().z+(type(head)=='number' and head or 0))
    end
    return pos
end
function TPocoHud3:_peer(something)
    local t = type(something)
    if t == 'userdata' then
        return alive(something) and something:network() and something:network():peer()
    end
    if t == 'number' then
        return self:pidToPeer(something)
    end
    if t == 'string' then
        return self:_peer(managers.criminals:character_peer_id_by_name( something ))
    end
end
function TPocoHud3:_pid(something)
    local peer = self:_peer(something)
    return peer and peer:id() or 0
end
function TPocoHud3:_color(something,fbk)
    local fallback = fbk or cl.Purple
    if type(something) == 'number' then
        return tweak_data.chat_colors[something] or fallback
    elseif type(something) == 'userdata' then
        local pid = self:_pid(something)
        return pid ~= 0 and self:_color(pid) or fallback
    else
        return fallback
    end
end

function TPocoHud3:_name(something, asRoom)
    local str = type_name(something)
    if asRoom and str == 'number' and something > 0 then
        return self:_name(self:_pos(something), asRoom)
    elseif str == 'Vector3' then
        if Poco.room and Poco.room:get(something) then
            return Poco.room:get(something,true)
        end
        if asRoom then
            return -- requested room, nothing found
        end
        local peers = _.g('managers.network:session():peers()',{})
        local pid, closest = nil, 999999999
        for __, peer in pairs( peers ) do
            local unit = peer:unit()
            if unit and alive(unit) then
                local d = mvector3.distance_sq(something,unit:position())
                if d < closest then
                    pid = peer:id()
                    closest = d
                end
            end
        end
        local myunit = managers.player:player_unit()
        local mypos = (myunit and alive(myunit)) and myunit:position() or nil
        if mypos then
            local d = mvector3.distance_sq(something,mypos)
            pid = d > closest and pid or self.pid
        end
        return L('_msg_around',{self:_name(pid or self.pid)})
    elseif str == 'Unit' then
        if something and something:base() and something:base()._tweak_table then
            return self:_name(something:base() and something:base()._tweak_table)
        end
        return '?'
    elseif str == 'string' then -- tweak_table name
        local pName = managers.criminals:character_peer_id_by_name(something)
        if pName then
            return self:_name(pName)
        else
            local conv = _conv
            return L(conv[something]) or 'AI'
        end
    end
    local peer = self:_peer(something)
    local name = peer and peer:name() or PocoLocale._Someone or 'Someone'
    name = name:gsub('{','['):gsub('}',']')
    local hDot,fDot
    local truncated = name:gsub('^%b[]',''):gsub('^%b==',''):gsub('^%s*(.-)%s*$','%1')
    if O:get('game','truncateTags') and utf8.len(truncated) > 0 and name ~= truncated then
        name = truncated
        hDot = true
    end
    local tLen = O:get('game','truncateNames')
    if tLen > 1 then
        tLen = (tLen - 1) * 3
        if tLen < utf8.len(name) then
            name = utf8.sub(name,1,tLen)
            fDot = true
        end
    end
    return (hDot and Icon.Dot or '')..name..(fDot and Icon.Dot or '')
end
function TPocoHud3:_time(sec)
    if type(sec) ~= "number" then
        sec = tonumber(sec) or 0
    end
    local t = math.floor(sec * 10) / 10
    if t < 0 then
        return string.format("%d", 0)
    elseif t < 1 then
        return string.format("%.2f", sec)
    elseif t < 10 then
        return string.format("%.1f", t)
    elseif t < 60 then
        return string.format("%d", t)
    else
        return string.format("%d:%02d", t / 60, t % 60)
    end
end
function TPocoHud3:_visibility(uPos)
    local result = 1-math.min(0.9,managers.environment_controller._current_flashbang or 1)
    if not uPos or self.dead then
        return result
    end
    local minDis = 9999
    local sRad = 300
    for i,obj in pairs(self.smokes) do
        local sPos = obj[1]
        local cPos = self.camPos
        local disR, dotR = 1,1
        local sDir = sPos - cPos
        local uDir = uPos - cPos
        local xDir = sPos - uPos
        minDis = math.min(sDir:length(),xDir:length())
        if minDis <= sRad then
            disR = math.pow(minDis/sRad,3)
        elseif sDir:length() < uDir:length() then
            mvector3.normalize(sDir)
            mvector3.normalize(uDir)
            local dot = mvector3.dot(sDir, uDir)
            dotR= 1-math.pow(dot,3)
        end
        result = math.min(result, math.min(disR, dotR))
    end

--	_.d(now(),result*100,'%')
        -- 1. Inside smoke
        -- 2. Through smoke
    return result
end
function TPocoHud3:_show(state,isEndgame)
    if self.dead then return end
    if isEndgame and not state then
        self:AnnounceStat(false)
    end
    for k,pnl in pairs(self.pnl) do
        if not (isEndgame and pnl == self.pnl.dbg) then
            pnl:set_visible(state)
        end
    end
end
function TPocoHud3:_hook()
    local Run = function(key, ...)
        if self.hooks[key] then
            return self.hooks[key][2](...)
        end
    end
    local hook = function(Obj, key, newFunc)
        local realKey = key:gsub('%*%a*','')
        if Obj and not self.hooks[key] then
            self.hooks[key] = {Obj,Obj[realKey]}
            Obj[realKey] = function(...)
                if (me and me.dead) or not me then
                    return Run(key,...)
                else
                    return newFunc(...)
                end
            end
        else
            _('!!Hook Failed:'..key)
        end
    end
    --
    if inGame then
        -- Kill PocoHud on restart
        hook(GamePlayCentralManager, 'restart_the_game', function(...)
            Pocohud_stop = true
            me:onDestroy(gameEnd)
            me.Toggle()
            Run('restart_the_game', ...)
            PocoHud3 = nil
        end)

        --PlayerStandard
        hook(PlayerStandard, '_get_input', function(self, ...)
            return me.menuGui and {} or Run('_get_input', self, ...)
        end)
        if O:get('root','pocoRoseHalt') then
            hook(PlayerStandard, '_determine_move_direction', function(self, ...)
                Run('_determine_move_direction', self, ...)
                if me.menuGui then
                    self._move_dir = nil
                    self._normal_move_dir = nil
                end
            end)
        end

        --[[hook(PlayerStandard, '_update_check_actions', function(self, ...)
            if not me.menuGui then
                Run('_update_check_actions', self,... )
            end
        end)]]

        local _tempStanceDisable
        local _matchStance = function(tempDisable)
            local r,err = pcall(function()
                _tempStanceDisable = tempDisable
                local crook = O:get('game','cantedSightCrook') or 0
                local state = _.g('managers.player:player_unit():movement():current_state()')
                if crook>1 and state and state._stance_entered then
                    state:_stance_entered()
                end
                _tempStanceDisable = nil
            end)
            if not r then me:err(_.s('MatchStance:',err)) end
        end

        hook(PlayerAction.TriggerHappy, 'Function*TrgHpy', function(player_manager, damage_bonus, max_stacks, max_time)
            -- feeds in TriggerHappy max-time
            me.__triggerHappyMaxTime = max_time
            return Run('Function*TrgHpy', player_manager, damage_bonus, max_stacks, max_time)
        end)

        hook(FPCameraPlayerBase, 'clbk_stance_entered', function(...)
            local self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration = unpack{...}
            local r,err = pcall(function()
                local crook = O:get('game','cantedSightCrook') or 0
                if crook > 1 and not _tempStanceDisable then
                    local state = managers.player:player_unit():movement():current_state()
                    local wb = state._equipped_unit and state._equipped_unit:base()
                    local second_sight_on = wb and wb.is_second_sight_on and wb:is_second_sight_on()

                    local wtd = wb:weapon_tweak_data()
                    local is_snp = false
                    for i=1,#wtd.categories do
                        if wtd.categories[i] == 'snp' then
                            is_snp = true
                            break
                        end
                    end

                    if second_sight_on and not (state:_is_meleeing() or state:in_steelsight()) and is_snp then
                        local sMod = wb.stance_mod and wb:stance_mod()
                        if crook == 2 then
                            stance_mod.rotation = Rotation(0,0,-7)
                        elseif crook == 3 then
                            stance_mod.rotation = Rotation(0,0,-15)
                        elseif crook == 4 and sMod then
                            local translation = stance_mod.translation or Vector3()
                            local rotation = stance_mod.rotation or Rotation()
                            mvector3.add(translation, sMod.translation)
                            mvector3.add(translation, Vector3(-10,2,0))
                            mrotation.multiply(rotation, sMod.rotation)
                            stance_mod.translation = translation
                            stance_mod.rotation = rotation
                        end
                    end
                end
            end)
            if not r then
                me:err(_.s('CBSE',err))
            end
            Run('clbk_stance_entered', self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
        end)

        hook(PlayerStandard, '_interupt_action_interact', function(self, t, input, complete, ...)
            -- StickyInteraction Execution
            local lastInteractionStart, lastClick = me._lastInteractStart or 0, me._lastClick or 0
            if not t and O:get('game','interactionClickStick') and not complete and (lastInteractionStart < lastClick) then
                local caller = debug.getinfo(2,'n')
                caller = caller and caller.name

                if caller == '_check_action_interact' then
                    -- _update_check_actions
                    return -- ignore interruption
                end
            end
            Run('_interupt_action_interact', self, t, input, complete, ...)
            local et = self._equip_weapon_expire_t
            if et then
                me:RemoveBuff('interaction')
                pcall(me.Buff,me,({
                    key='transition', good=false,
                    icon=SkillIcons,
                    iconRect = {4 * 64, 3 * 64, 64, 64},
                    text='',
                    st=now(), et=et
                }) )
            end
        end)

        hook(PlayerStandard, '_end_action_running', function(self, ...)
            if self._running and not self._end_running_expire_t and not self.RUN_AND_SHOOT then
                _matchStance()
            end
            Run('_end_action_running', self, ...)
            local et = self._end_running_expire_t
            if not (self.RUN_AND_SHOOT or O:get('buff','noSprintDelay')) and et then
                pcall(me.Buff,me,({
                    key='transition', good=false,
                    icon=SkillIcons,
                    iconRect = { 0, 9*64,64,64 },
                    text='',
                    st=now(), et=et
                }) )
            end
        end)

        hook(PlayerStandard, '_start_action_interact', function(self, t, ...)
            Run('_start_action_interact', self, t, ...)
            me._lastInteractStart = t
            local et = self._interact_expire_t < t and self._interact_expire_t + t or self._interact_expire_t
            if et then
                pcall(me.Buff,me,({
                    key='interaction', good=true,
                    icon = 'guis/textures/pd2/pd2_waypoints',
                    iconRect = {224, 32, 32, 32},
                    --icon = 'guis/textures/hud_icons',
                    --iconRect = { 96, 144, 48, 48 },
                    text='',
                    st=t, et=et
                }) )
            end
        end)

        hook(PlayerStandard, '_start_action_reload', function(self, t)
            Run('_start_action_reload', self, t)
            _matchStance(true)
            local et = O:get('buff','showReload') and self._state_data.reload_expire_t
            if et then
                pcall(me.Buff2,me,({
                    key='reload',
                    good=false,
                    icon=SkillIcons,
                    iconRect = {0, 9 * 64, 64, 64},
                    text='',
                    st=t, et=et
                }) )
            end
        end)

        hook(PlayerStandard, '_update_reload_timers', function(self, t, ...)
            Run('_update_reload_timers', self, t, ...)
            local et = self._state_data.reload_exit_expire_t
            if et and et > 0 and me.buffs.reload then
                me:RemoveBuff('reload')
            end
        end)

        hook(PlayerStandard, '_interupt_action_reload', function(self, t)
            if self:_is_reloading() then
                me:RemoveBuff('reload')
                _matchStance()
            end
            Run('_interupt_action_reload', self, t)
        end)

        hook(StatisticsManager, 'reloaded', function(...)
            -- To restore stance once reload is done, without too much work
            Run('reloaded', ...)
            _matchStance()
        end)

        --PlayerMovement
        hook(PlayerMovement, 'on_morale_boost', function(self, benefactor_unit)
            local r = Run('on_morale_boost',  self, benefactor_unit)
            if self._morale_boost then
                local t = now()
                local et = t + tweak_data.upgrades.morale_boost_time
                pcall(me.Buff,me,({
                    key='boost', good=true,
                    icon=SkillIcons,
                    iconRect = { 4*64, 9*64, 64,64 },
                    st=t, et=et
                }) )
            end
            return r
        end)

        hook(PlayerDamage, '_look_for_friendly_fire', function(self, attacker_unit)
            me._lastAttkUnit = attacker_unit
            return Run('_look_for_friendly_fire', self, attacker_unit)
        end)

        local GainIndicator = O:get('hit','gainIndicator') or 0
        hook(PlayerDamage, 'change_health', function(self, ...)
            local before = self:get_real_health()
            Run('change_health', self, ...)
            if O:get('hit','enable') and GainIndicator > 1 then
                -- Skill-originated Health regen
                local after = self:get_real_health()
                local delta = after - before
                if delta > 0 then
                    if GainIndicator > 2 then
                        managers.menu_component:post_event("menu_skill_investment")
                    end
                    me:SimpleFloat{key='health',x=(me.ww or 800)/5*2,y=(me.hh or 600)/4*3,time=3,anim=1,offset={0,-1 * (me.hh or 600)/2},
                        text={{'+',cl.White:with_alpha(0.6)},{_.f(delta*10),clGood}},
                        size=18, rect=0.5
                    }
                end
            end
        end)
        hook(PlayerDamage, 'restore_armor', function(self, ...)
            local before = self:get_real_armor()
            -- Disregarding validity checks present in the original function because the buff must appear even if no armor was actually
            -- restored (since the game itself doesn't care and forces a cooldown anyway, see the on_damage() closure in
            -- PlayerDamage:init())
            if self._damage_to_armor and self._damage_to_armor.elapsed and self._damage_to_armor.target_tick then
                local t = Application:time()
                -- Yes, there is a chance that the time might have changed by the time this function gets called (especially on slow
                -- systems)
                if self._damage_to_armor.elapsed == t then
                    local playertime = managers.player:player_timer():time()
                    me:Buff({
                        key = "AnarchistDamageCooldown",
                        good = false,
                        icon = AnarchistDeckIcons,
                        iconRect = {0, 64, 64, 64},
                        text = L("_buff_cooldown"),
                        st = playertime,
                        et = playertime + self._damage_to_armor.target_tick
                    })
                end
            end
            Run('restore_armor', self, ...)
            if O:get('hit','enable') and GainIndicator > 1 then
                -- Skill-originated Shield regen
                local after = self:get_real_armor()
                local delta = after - before
                if delta > 0 then
                    if GainIndicator > 2 then
                        managers.menu_component:post_event("menu_skill_investment")
                    end
                    me:SimpleFloat{key='armor',x=(me.ww or 800)/5*3,y=(me.hh or 600)/4*3,time=3,anim=1,offset={0,-1 * (me.hh or 600)/2},
                        text={{'+',cl.White:with_alpha(0.6)},{_.f(delta*10),clGood}},
                        size=18, rect=0.5
                    }
                end
            end
        end)

        if O:get('hit','enable') then
            local _hitDirection = function(self,result,data,shield,rate)
                local sd = self._supperssion_data and self._supperssion_data.decay_start_t
                if sd then
                    sd = math.max(0,sd-now())
                end
                local et = (self._regenerate_timer or 0)+(sd or 0)
                if et == 0 then
                    et = 2 -- Failsafe
                end
                me:HitDirection(data.col_ray,{dmg=result,shield=shield,time=et,rate=rate})
            end
            hook(PlayerDamage, '_calc_armor_damage', function(self, attack_data, ...)
                local valid = self:get_real_armor() > 0
                local result = Run('_calc_armor_damage', self, attack_data, ...)
                if valid then
                    _hitDirection(self,result,attack_data,true,self:get_real_armor() / self:_max_armor())
                end
                return result
            end)
            hook(PlayerDamage, '_calc_health_damage', function(self, attack_data)
                local result = Run('_calc_health_damage', self, attack_data)
                if result > 0 then
                    _hitDirection(self,result,attack_data,false,self:health_ratio())
                end
                return result
            end)
        end

        hook(PlayerManager, 'use_messiah_charge', function(...)
            Run('use_messiah_charge', ...)
            me:Chat('messiah',L('_msg_usedPistolMessiah'))
        end)

        --UnitNetwork
        hook(UnitNetworkHandler, 'long_dis_interaction', function(...)
            local self, target_unit, amount, aggressor_unit  = unpack{...}
            local pid = me:_pid(target_unit)
            local pidA = me:_pid(aggressor_unit)
            if amount == 1 and pid and pid > 0 then -- 3rd Person to me.
                me:Stat(pid,'boost',now() + tweak_data.upgrades.morale_boost_time)
            end
            return Run('long_dis_interaction', ...)
        end)
        hook(BaseNetworkSession, 'send_to_peer', function(...) -- To capture boost
            local self, peer, fname, target_unit, amount, aggressor_unit = unpack{...}
            if fname == 'long_dis_interaction' and amount == 1 then
                local pid = me:_pid(target_unit)
                if pid then -- 3rd Person to Someone
                    local t = tweak_data.upgrades.morale_boost_time
                    me:Stat(pid,'boost',now() + t)
                    ShowBoost(pid, t)
                end
            end
            return Run('send_to_peer', ...)
        end)

        if true then
            hook(UnitNetworkHandler, 'damage_bullet', function(...)
                local self, subject_unit, attacker_unit, damage, i_body, height_offset, variant, death, sender = unpack{...}
                local head = i_body and subject_unit and alive(subject_unit) and subject_unit:character_damage() and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
                if not (damage == 1 and i_body == 1 and height_offset == 1) then -- Filter Drama event
                    if attacker_unit and alive(attacker_unit)
                        and attacker_unit:base()
                        and attacker_unit:base().sentry_gun
                    then
                        attacker_unit = attacker_unit:base():get_owner()
                    end
                    me:AddDmgPopByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head,'bullet')
                end
                return Run('damage_bullet', ...)
            end)
            hook(UnitNetworkHandler, 'damage_explosion_fire', function(...)
                local self, subject_unit, attacker_unit, damage, i_attack_variant, death, direction, weapon_unit, sender = unpack{...}

                local realAttacker = attacker_unit
                if realAttacker and alive(realAttacker) and realAttacker:base() and realAttacker:base()._thrower_unit then
                    realAttacker = realAttacker:base()._thrower_unit
                end

                me:AddDmgPopByUnit(realAttacker,subject_unit,0,damage*-0.1953125,death,false,'bullet')
                return Run('damage_explosion_fire', ...)
            end)

            hook(UnitNetworkHandler, 'damage_dot', function(...)
                local self, subject_unit, attacker_unit, damage, death, variant, hurt_animation, weapon_id, sender = unpack{...}

                local realAttacker = attacker_unit
                if realAttacker and alive(realAttacker) and realAttacker:base() and realAttacker:base()._thrower_unit then
                    realAttacker = realAttacker:base()._thrower_unit
                end

                me:AddDmgPopByUnit(realAttacker,subject_unit,0,damage*-0.1953125,death,false,'dot') --'explosion')
                return Run('damage_dot', ... )
            end)
            hook(UnitNetworkHandler, 'damage_fire', function(...)
                local self, subject_unit, attacker_unit, damage, start_dot_dance_antimation, death, direction, weapon_type, weapon_unit, healed, sender = unpack{...}
                local realAttacker = attacker_unit
                if realAttacker and alive(realAttacker) and realAttacker:base() and realAttacker:base()._thrower_unit then
                    realAttacker = realAttacker:base()._thrower_unit
                end

                me:AddDmgPopByUnit(realAttacker,subject_unit,0,damage*-0.1953125,death,false,'fire') --'explosion')
                return Run('damage_fire', ...)
            end)

            hook(UnitNetworkHandler, 'damage_melee', function(...)
                local self, subject_unit, attacker_unit, damage, damage_effect, i_body, height_offset, variant, death, sender  = unpack{...}
                local head = i_body and subject_unit and alive(subject_unit) and subject_unit:character_damage() and subject_unit:character_damage().is_head and subject_unit:character_damage():is_head(subject_unit:body(i_body))
                me:AddDmgPopByUnit(attacker_unit,subject_unit,height_offset,damage*-0.1953125,death,head,'melee')
                return Run('damage_melee',...)
            end)

            --CopDamage
            hook(CopDamage, '_on_damage_received', function(self, info, ...)
                local result = Run('_on_damage_received',self, info, ...)
                if info.col_ray or info.variant == 'poison' or info.variant == 'graze' then
                    local hitPos = Vector3()
                    local col_ray = info.col_ray or {}
                    mvector3.set(hitPos,col_ray.position or info.pos or col_ray.hit_position or me:_pos(self._unit))
                    if hitPos then
                        local head = self._unit:character_damage():is_head(col_ray.body)
                        local realAttacker = info.attacker_unit
                        if alive(realAttacker) then
                            if realAttacker:base()
                                and realAttacker:base().thrower_unit --_thrower_unit
                            then
                                realAttacker = realAttacker:base().thrower_unit --_thrower_unit
                            elseif realAttacker:base() and realAttacker:base().sentry_gun then
                                realAttacker = realAttacker:base():get_owner()
                            end
                        end
                        me:AddDmgPop(realAttacker, hitPos, self._unit, 0, info.damage, self._dead, head, info.variant, info.critical_hit) --info.variant ~= 'explosion' and info.variant or 'he')
                    end
                end
                return result
            end)
            hook(CopDamage, 'roll_critical_hit', function(self, attack_data, ...)
                local critical_hit, crit_damage = Run('roll_critical_hit', self, attack_data, ...)
                if attack_data.variant == "fire" then
                    if not attack_data.result then
                        -- Fire can crit twice, but the second crit is discarded and can override crit visibility
                        -- This is here to ensure ONLY THE FIRST crit check shows properly, the second one does nothing, the crit damage is not saved back to "attack_data.damage"
                        attack_data.critical_hit = critical_hit
                    end
                else
                    attack_data.critical_hit = critical_hit
                end
                return critical_hit, crit_damage
            end)
            --CopMovement
            -- TODO:
            -- Optimize this
            local dmgTime = O:get('popup','damageDecay')
            local HandsUp = O:get('popup','handsUp')
            local Dominated = O:get('popup','dominated')
            hook(CopMovement, 'action_request', function(self, action_desc, ...)
                if action_desc.variant == 'hands_up' and HandsUp then
                    me:Popup({pos=me:_pos(self._unit),text={{PocoLocale._handsUp,cl.White}},stay=false,et=now()+dmgTime})
                elseif action_desc.variant == 'tied' then
                    if not managers.enemy:is_civilian(self._unit) then
                        if Dominated then
                            me:Popup({pos=me:_pos(self._unit),text={{PocoLocale._Intimidated,cl.White}},stay=false,et=now()+dmgTime})
                        end
                        me:Chat('dominated',L('_msg_captured',{me:_name(self._unit),me:_name(me:_pos(self._unit))}))
                    end
                end
                --if action_desc.type=='act' and action_desc.variant then
                    --me:Popup({pos=me:_pos(self._unit),text={{action_desc.variant,Color.white}},stay=true,et=now()+dmgTime})
                --end
                return Run('action_request', self, action_desc, ...)
            end)
        end
        
        hook(FireManager, '_add_doted_enemy', function(...)
            local self, enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov = unpack{...}
            --[[local contains = false
            if self._doted_enemies and is_molotov then
                for _, dot_info in ipairs(self._doted_enemies) do
                    if dot_info.enemy_unit == enemy_unit then
                        dot_info.fire_damage_received_time = fire_damage_received_time
                        contains = true
                    end
                end
                if not contains then
                    me:Stat(me:_pid(user_unit),'hit',1,true)
                end
            else
                me:Stat(me:_pid(user_unit),'hit',1,true)
            end]]

            if not is_molotov then
                me:Stat(me:_pid(user_unit),'hit',1,true)
            end

            return Run('_add_doted_enemy', ...)
        end)

        --ETC
        hook(HUDManager, 'show_endscreen_hud', function(...)
            Run('show_endscreen_hud', ...)
            me:_show(false, true)
        end)
        hook(HUDManager, 'set_disabled', function(...)
            Run('set_disabled', ...)
            me:_show(false)
        end)
        hook(HUDManager, 'set_enabled', function(...)
            Run('set_enabled', ...)
            me:_show(true)
        end)

        hook(ECMJammerBase, 'set_active', function(self, active, ...)
            Run('set_active', self, active, ...)
            local et = self:battery_life() + now()
            if active and (me._lastECM or 0 < et) then
                me._lastECM = et
                me._lastECMJammer = self._unit
                pcall(me.Buff,me,({
                    key='ECM', good=true,
                    icon=SkillIcons,
                    iconRect = {1*64,4*64,64,64},
                    text='',
                    st=now(), et=et
                }) )
            end
        end)
        hook(ECMJammerBase, 'set_feedback_active', function(self, ...)
            Run('set_feedback_active', self, ...)
            local et = self._feedback_duration
            if et then
                me._lastECMFeedback = self._unit
                pcall(me.Buff,me,({
                    key='feedback', good=true,
                    icon=SkillIcons,
                    iconRect = { 6*64, 2*64, 64, 64},
                    text='',
                    st=now(), et=et+now()
                }) )
            end
        end)
        hook(ECMJammerBase, 'destroy', function(self, ...)
            Run('destroy', self, ...)
            if me._lastECMJammer == self._unit then
                me:RemoveBuff("ECM")
            end
            if me._lastECMFeedback == self._unit then
                me:RemoveBuff("feedback")
            end
        end)
        hook(SecurityCamera, '_start_tape_loop', function(self, tape_loop_t, ...)
            Run('_start_tape_loop', self, tape_loop_t, ...)
            local et = tape_loop_t + 5
            if et then
                local t = now()
                pcall(me.Buff,me,({
                    key='tapeLoop',
                    good=true,
                    icon=SkillIcons,
                    iconRect = {4 * 64, 2 * 64, 64, 64},
                    text='',
                    st= t,
                    et= et + t
                }))
            end
        end)
        hook(SecurityCamera, "_deactivate_tape_loop", function(...)
            Run("_deactivate_tape_loop", ...)
            me:RemoveBuff("tapeLoop")
        end)
        -- MinionHooks
        local function AddMinionHookListener(unit, peer_id, slot)
            if not unit.key then
                return
            end
            local unit_key = tostring(unit:key())
            local callback_key = "PocoConvert"
            local clbk = callback(self, self, "MinionKilled", { key = unit_key, peer_id = peer_id, slot = slot })
            unit:base():add_destroy_listener(callback_key, clbk)
            unit:character_damage():add_listener(callback_key, { "death" }, clbk)
            if O:get('float','showTargetsConvert') then
                me:MinionFloat(unit, 0, { minion = peer_id })
            end
            if peer_id and O:get('float','showConvertedEnemy') then
                local clr = me:_color(peer_id)
                local contourext = unit.contour and unit:contour()
                if clr and contourext then
                    contourext:change_color("friendly", clr)
                end
            end
        end
        hook(GroupAIStateBase, 'convert_hostage_to_criminal', function(self, unit, peer_unit, ...)
            Run('convert_hostage_to_criminal', self, unit, peer_unit, ...)
            if unit:brain()._logic_data.is_converted then
                peer_unit = peer_unit or managers.player:player_unit()
                local peerId = me:_pid(peer_unit)
                local slot = me:Minion(peerId, unit)
                AddMinionHookListener(unit, peerId, slot)
            end
        end)
        hook(GroupAIStateBase, "sync_converted_enemy", function(self, converted_enemy, owner_peer_id, ...)
            if self._police[converted_enemy:key()] then
                local slot = nil
                if owner_peer_id then
                    slot = me:Minion(owner_peer_id, converted_enemy)
                end
                AddMinionHookListener(converted_enemy, owner_peer_id, slot)
            end
            Run("sync_converted_enemy", self, converted_enemy, owner_peer_id, ...)
        end)
        hook(CopLogicTrade, "hostage_trade", function(unit, enable, trade_success, ...)
            Run("hostage_trade", unit, enable, trade_success, ...)
            if trade_success and not enable and CopDamage.is_cop(unit:base()._tweak_table) then -- Unit traded
                me:MinionTraded(unit)
            end
        end)

        hook(ChatManager, '_receive_message', function(self, ...)
            local channel_id, name, message, color, icon = unpack{...}
            me:_processMsg(channel_id, name, message, color)
            return Run('_receive_message', self, ...)
        end)

        hook(HUDManager, 'add_teammate_panel', function(self, ...)
            local character_name, player_name, ai, peer_id = unpack{...}
            if peer_id then
                if me:Stat(peer_id,'name') ~= player_name then
                    me:Stat(peer_id,'name',player_name)
                    me:Stat(peer_id,'time',now())
                    me:Stat(peer_id,'hit',0)
                    me:Stat(peer_id,'head',0)
                    me:Stat(peer_id,'dmg',0)
                    me:Stat(peer_id,'shot',0)
                    me:Stat(peer_id,'kill',0)
                    me:Stat(peer_id,'killS',0)
                    do
                        local unit = me:pidToPeer(peer_id):unit()
                        local downs = 0
                        if unit then
                            downs = unit:character_damage():get_revives() - 1
                        end
                        me:Stat(peer_id,"down",downs)
                    end
                    me:Stat(peer_id,'downAll',0)
                    me:Stat(peer_id,'downIncap',0)
                    me:Stat(peer_id,'auto_fire_st',-1)
                    me:Stat(peer_id,'custody',0)
                    me:Stat(peer_id,'playtime', 0)

                    if O:get('playerBottom','rankToPlaytime') then
                        me:Stat(peer_id,'noPanel', 1)
                    end

                    Steam:http_request(
                    'http://steamcommunity.com/profiles/'..me:_peer(peer_id):user_id()..'/games/?tab=recent',
                        function(success, body)
                            if success then
                                local s1, e1 = string.find(body, 'PAYDAY 2')
                                if e1 then
                                    local s2, e2 = string.find(body, 'hours_forever', e1)
                                    if e2 then
                                        local hours = ''
                                        local i = e2+4
                                        while true do
                                            local ch = string.sub(body, i, i)
                                            if tonumber(ch) then
                                                hours = hours..ch
                                                i = i + 1
                                            elseif ch == ',' then
                                                i = i + 1
                                            else
                                                break
                                            end
                                        end
                                        local hrs = tonumber(hours)
                                        if hrs and hrs > 0 then
                                            me:Stat(peer_id,'playtime', hrs)
                                            --me:Stat(pid,'_refreshBtm',1)
                                        end
                                    end
                                end
                            end
                            me:Stat(peer_id,'noPanel', 0)
                        end
                    )
                end
            end
            return Run('add_teammate_panel', self, ...)
        end)

        local onReplenish = function(pid, noReset, fak)
            if (now()-(self._startGameT or now()) < 1) then return end
            local down = 0
            if not noReset then
                local previous = self:Stat(pid, "downPrevious")
                if previous then
                    local current = self:Stat(pid, "down")
                    down = math.max(current - previous + 1, 0)
                end
            end
            local name = self:_name(pid)
            local str = down == 1 and "_msg_used_doctorbag_down" or "_msg_used_doctorbag_downs"
            local msg = fak and L("_msg_used_fak", {name}) or L("_msg_used_doctorbag", {name, down, L(str)})
            local chat_category = fak and "replenishedFAK" or "replenished"
            self:Chat(chat_category, msg)
        end

        -- Stop update() when someone is joining to prevent them from crashing
        hook(BaseNetworkSession, 'on_drop_in_pause_request_received', function(self, peer_id, nickname, state, ...)
            _someone_joining = state
            return Run('on_drop_in_pause_request_received', self, peer_id, nickname, state, ...)
        end)

        hook(PlayerInventory, 'get_jammer_time', function(self, ...)
            local upg_name = 'pocket_ecm_jammer_base'

            if self._unit:base():upgrade_value('player', upg_name) then
                local dur = Run('get_jammer_time', self, ...)
                if dur then return dur end
            end

            local td = tweak_data.upgrades.values.player[upg_name]
            return (td and td[1] and td[1].duration) and td[1].duration or 6
        end)

        -- 1. Kit
        hook(FirstAidKitBase, 'take', function(self, ...)
            onReplenish(me.pid, true, true)
            return Run('take', self, ...)
        end)
        hook(FirstAidKitBase, 'sync_net_event', function(self, ...)
            local event_id, peer = unpack{...}
            if event_id == 2 and peer then
                onReplenish(peer:id(), true, true)
            end
            return Run('sync_net_event', self, ...)
        end)

        -- 2. Med
        hook(DoctorBagBase, 'take*', function(self, ...)
            local result = Run('take*', self, ...)
            onReplenish(me.pid)
            return result
        end)
        hook(UnitNetworkHandler, 'sync_doctor_bag_taken', function(self, unit, amount, sender, ...)
            local peer = self._verify_sender(sender)
            local pid = peer and peer:id()
            if pid then
                onReplenish(pid)
            end
            return Run('sync_doctor_bag_taken', self, unit, amount, sender, ...)
        end)

        hook(PlayerIncapacitated, 'enter', function(...)
            me:Stat(me.pid, 'downIncap', 1, true)
            return Run('enter', ...)
        end)

        hook(UnitNetworkHandler, '_sync_movement_state_incapacitated', function(self, unit, ...)
            Run('sync_player_movement_state', self, unit, ...)
            local pid = me:_pid(unit)
            if pid and pid ~= me.pid then
                me:Stat(pid, 'downIncap', 1, true)
            end
        end)
        local OnCriminalDowned = function(pid, downs)
            local previous = math.max(self:Stat(pid, "down") or 0, 0)
            downs = math.max(downs, 0)
            if previous == downs then
                return
            end
            self:Stat(pid, "downPrevious", previous)
            self:Stat(pid, "down", downs)
            self:Stat(pid, "downAll", 1, true)
            if downs == 0 then
                self:Chat('downedWarning',L('_msg_downedWarning',{me:_name(pid)}))
            else
                self:Chat('downed',L('_msg_downed',{me:_name(pid)}))
            end
        end
        hook(PlayerBleedOut, '_enter', function(self, ...)
            OnCriminalDowned(me.pid, self._unit:character_damage():get_revives() - 1)
            return Run('_enter', self, ...)
        end)
        hook(PlayerDamage, "init", function(self, ...)
            Run("init", self, ...)
            me:Stat(me.pid, "down", self:get_revives() - 1)
        end)
        hook(PlayerDamage, "_send_set_revives", function(self, is_max, ...)
            Run("_send_set_revives", self, is_max, ...)
            if is_max then
                me:Stat(me.pid, "down", self:get_revives() - 1)
            end
        end)
        hook(HuskPlayerDamage, "sync_set_revives", function(self, amount, is_max, ...)
            Run("sync_set_revives", self, amount, is_max, ...)
            local pid = me:_pid(self._unit)
            if not pid or pid == me.pid then
                return
            end
            if is_max then
                me:Stat(pid, "down", amount - 1)
            else
                OnCriminalDowned(pid, amount - 1)
            end
        end)

        hook(getmetatable(managers.subtitle.__presenter), 'show_text', function(self, text, ...)
            local label = self.__subtitle_panel:child('label')
            local shadow = self.__subtitle_panel:child('shadow')
            local gameO = O:get('game')
            local apply = function()
                self._fontSize = gameO.subtitleFontSize
                self._fontColor = gameO.subtitleFontColor:with_alpha(gameO.subtitleOpacity/100)
            end
            if label then
                if self._fontSize ~= gameO.subtitleFontSize then
                    apply()
                    label:set_font_size(self._fontSize)
                    shadow:set_font_size(self._fontSize)
                end
                if self._fontColor ~= gameO.subtitleFontColor then
                    apply()
                    label:set_color(self._fontColor)
                end
            else
                apply()
                label = self.__subtitle_panel:text({
                    name = 'label',
                    x = 1,
                    y = 1,
                    font = self.__font_name,
                    font_size = self._fontSize,
                    color = self._fontColor,
                    align = 'center',
                    vertical = 'bottom',
                    layer = 1,
                    wrap = true,
                    word_wrap = true
                })
                shadow = self.__subtitle_panel:text({
                    name = 'shadow',
                    x = 2,
                    y = 2,
                    font = self.__font_name,
                    font_size = self._fontSize,
                    color = cl.Black:with_alpha(0.008*gameO.subtitleOpacity),
                    align = 'center',
                    vertical = 'bottom',
                    layer = 0,
                    wrap = true,
                    word_wrap = true
                })
            end
            label:set_text(text)
            shadow:set_text(text)
        end)

        -- Criminal Custody
        local OnCriminalCustody = function(criminal_name)
            local pid
            for __, data in pairs(managers.criminals._characters) do
                if data.taken and data.name == criminal_name then
                    pid = data.peer_id
                end
            end
            if pid and self:Stat(pid,'custody') == 0 then
                self:Stat(pid,"down",0)
                self:Stat(pid,'custody',1)
                self:Stat(pid,'room','')
                self:Chat('custody',managers.localization:text('hint_teammate_dead',{TEAMMATE=self:_name(pid)}))
            end
        end
        hook(TradeManager, 'on_player_criminal_death', function(self, criminal_name, ...)
            OnCriminalCustody(criminal_name)
            return Run('on_player_criminal_death', self, criminal_name, ...)
        end)
        -- TimerGui
        hook(Drill, "on_autorepair", function(self, ...)
            Run("on_autorepair", self, ...)
            self._autorepair_client = true
        end)
        hook(TimerGui, "_start", function(self, ...)
            Run("_start", self, ...)
            me:Float(self._unit, 1)
        end)
        hook(TimerGui, "set_visible", function(self, visible, ...)
            if not visible then
                me:KillFloat(self._unit)
            elseif self._started then
                me:Float(self._unit, 1)
            end
            Run("set_visible", self, visible, ...)
        end)
        -- DigitalGui
        hook(DigitalGui, "timer_start_count_up", function(self, ...)
            me:Float(self._unit, 1)
            Run("timer_start_count_up", self, ...)
        end)
        hook(DigitalGui, "timer_start_count_down", function(self, ...)
            me:Float(self._unit, 1)
            Run("timer_start_count_down", self, ...)
        end)
        -- SecurityLockGui
        hook(SecurityLockGui, "_start*", function(self, ...)
            Run("_start*", self, ...)
            me:Float(self._unit, 1)
        end)
        -- Spot
        hook(ContourExt, 'add', function(...)
            local self, type, sync, multiplier = unpack{...}
            local result = Run('add', ...)
            if O:get('float','showHighlighted') and not (type == 'teammate') then
                local unit = self._unit -- TODO: compare this to filter Floats as Config
                local tweak = unit and unit:interaction() and unit:interaction().tweak_data
                local isPager = tweak == 'corpse_alarm_pager'
                me:Float(unit,0,result and result.fadeout_t or now()+(isPager and 12 or 4))
            end
            return result
        end)
        -- Pager
        hook(CopBrain, 'clbk_alarm_pager', function(self, ...)
            Run('clbk_alarm_pager', self, ...)
            if self._unit:interaction().tweak_data == 'corpse_alarm_pager' and self._unit:interaction()._active then
                local pagerData = self._alarm_pager_data
                if pagerData and pagerData.nr_calls_made == 1 then
                    local cbkID = pagerData.pager_clbk_id
                    local t, cbk = me:_getDelayedCbk(cbkID)
                    self._unit:interaction()._pagerT = (t or 0)*2
                    self._unit:interaction()._pager = now()
                end
            end
        end)
        -- Ragdoll length
        local corpseRagdollTimeout = O:get('game','corpseRagdollTimeout') or 3
        hook(EnemyManager, 'add_delayed_clbk', function(...)
            local self, id, clbk, execute_t = unpack{...}
            local isWhisper = managers.groupai:state():whisper_mode()
            if id and id:find('freeze_rag') and not isWhisper then
                local t = corpseRagdollTimeout - 3
                execute_t = execute_t + t
            end
            return Run('add_delayed_clbk', self, id, clbk, execute_t)
        end)
        -- Ammo Usage
        hook(HUDTeammate, 'set_ammo_amount_by_type', function(...)
            local self, type, max_clip, current_clip, current_left, max = unpack{...}
            local result = Run('set_ammo_amount_by_type', ...)
            --local out_of_ammo_clip = current_clip <= 0
            local pid = self:peer_id() or me.pid
            local lc = self['_last_clip_'..type] or 0
            if current_left < lc then
                me:Stat(pid,'shot',lc - current_left,true)
            end
            self['_last_clip_'..type] = current_left
            return result
        end)

        -- Interaction timers
        hook(HUDInteraction, 'set_interaction_bar_width', function(...) -- Local
            local self, current, total = unpack{...}
            if me:Stat(me.pid,'interactET') == 0 then
                me:Stat(me.pid,'interactST',now())
                me:Stat(me.pid,'interactET',now()+total)
            end
            local lastInteractionStart, lastClick = me._lastInteractStart or 0, me._lastClick or 0
            local sticky = O:get('game','interactionClickStick') and (lastInteractionStart < lastClick)
            if self._interact_circle and self.__lastSticky ~= sticky then
                local img = sticky and 'guis/textures/pd2/hud_progress_invalid' or 'guis/textures/pd2/hud_progress_bg'

                local anim_func = function(o)
                    while alive(o) and sticky do
                        over(0.75, function(p)
                            o:set_alpha(math.sin(p * 180) * 0.5)
                        end)
                    end
                end

                local bg = self._interact_circle._bg_circle
                if bg and alive(bg) then
                    bg:stop()
                    bg:animate(anim_func)
                    bg:set_image(img)
                end

                self.__lastSticky = sticky
            end

            Run('set_interaction_bar_width',...)
        end)
        hook(HUDInteraction, 'hide_interaction_bar', function(...) -- Local
            me:Stat(me.pid, 'interactST', 0)
            me:Stat(me.pid, 'interactET', 0)
            Run('hide_interaction_bar', ...)
        end)

        hook(HUDManager, 'teammate_progress', function(...) -- Remote
            local self, peer_id, type_index, enabled, tweak_data_id, timer, success = unpack{...}
            if enabled then
                local t = now()
                me:Stat(peer_id, 'interactST', t)
                me:Stat(peer_id, 'interactET', t + timer)
            else
                me:Stat(peer_id, 'interactST', 0)
                me:Stat(peer_id, 'interactET', 0)
            end
            return Run('teammate_progress', ...)
        end)

        -- Joining
        if O:get("game", "ingameJoinRemaining") then
            hook(MenuManager, 'show_person_joining', function(...)
                local self, id, nick = unpack{...}
                self['_joinT_'..id] = os.clock()
                local result = Run('show_person_joining', ...)
                local peer = managers.network:session():peer(id)
                if peer then
                    local rank = peer:rank()
                    if rank and rank > 0 then
                        managers.hud:post_event('infamous_player_join_stinger')
                    end
                    local dlg = managers.system_menu:get_dialog('user_dropin' .. id)
                    if dlg then
                        local level_string = managers.experience:gui_string(peer:level() or "?", rank)
                        level_string = level_string .. " " .. string.upper(nick)
                        dlg:set_title(_.s(
                            managers.localization:text('dialog_dropin_title', {	USER = level_string	})
                            ))
                    end
                end
                return result
            end)
            hook(MenuManager, 'update_person_joining', function(...)
                local self, id, progress_percentage = unpack{...}
                local joinT = self['_joinT_'..id] or os.clock()
                local dT,per = os.clock()-joinT, math.max(1,progress_percentage)
                local tT = dT/per*100
                Run('update_person_joining', ...)
                local dlg = managers.system_menu:get_dialog('user_dropin' .. id)
                if dlg then
                    dlg:set_text(_.s(
                        managers.localization:text('dialog_wait'), progress_percentage..'%',
                        tT-dT,'s left'
                        ))
                end
            end)
        end
        -- Hide interaction circle
        if O:get('buff','hideInteractionCircle') then
            hook(HUDInteraction, 'show_interaction_bar', function(self, ...)
                Run('show_interaction_bar', self, ...)
                self._interact_circle:set_visible(false)
            end)
            hook(HUDInteraction, '_animate_interaction_complete', function(...)
                local self, bitmap, circle  = unpack{...}
                bitmap:parent():remove( bitmap )
                circle:remove()
                --Run('_animate_interaction_complete', ...)
            end)
        end

        hook(TangoManager, 'award', function(...)
            me:Chat('specOps',L('_msg_specOps'))
            Run('award', ...)
        end)

        --[[-- Corpse limit
        hook(EnemyManager, '_upd_corpse_disposal', function(self, ...)
            Run('_upd_corpse_disposal', self, ...)
            -- Clean up shields. :p
            local corpses,cnt = self._enemy_data.corpses, 0
            for i,corpse in pairs(corpses or {}) do
                local unit = corpse.unit
                if alive(unit) and unit:base() and unit:base()._tweak_table == 'shield' then
                    cnt = cnt + 0
                    if cnt > 2 or (now() - corpse.death_t > 10) then
                        unit:base():set_slot(unit, 0)
                    end
                end
            end
            --
        end)]]

        -- hostage counter
        hook(HUDAssaultCorner, 'set_control_info', function(self, data, ...)
            Run('set_control_info', self, data, ...)
            if data and data.nr_hostages then
                me._nr_hostages = data.nr_hostages
            end
        end)

        hook(IngameWaitingForPlayersState, "at_enter*", function(...)
            Run("at_enter*", ...)
            local dO = O:get("corner")
            self.dbgLbl:set_visible(dO.showClockOutgame or dO.showFPS)
            self._game_started = true
        end)

        hook(IngameWaitingForPlayersState, 'update***', function(self, ...)
            Run('update***', self, ...)
            if self._skip_data then
                self._skip_data.total = 0.2
            end
        end)

        hook(IngameWaitingForPlayersState, "at_exit", function(self, next_state, ...)
            Run("at_exit", self, next_state, ...)
            local dO = O:get("corner")
            me.dbgLbl:set_visible(dO.showClockIngame or dO.showFPS)
            if game_state_machine:verify_game_state(GameStateFilters.any_ingame, next_state:name()) then
                me:SetIngame(true)
            end
        end)

        hook(MissionEndState, "at_enter**", function(self, old_state, ...)
            if game_state_machine:verify_game_state(GameStateFilters.any_ingame, old_state:name()) then
                me:SetIngame(false)
            end
            Run("at_enter**", self, old_state, ...)
            local dO = O:get("corner")
            me.dbgLbl:set_visible(dO.showClockOutgame or dO.showFPS)
        end)

        hook(PlayerStandard, '_check_action_primary_attack', function(self, t, ...)
            local input = unpack{...}

            -- StickyInteraction trigger
            local lastInteractionStart, lastClick = me._lastInteractStart or 0, me._lastClick or 0
            if input.btn_steelsight_press and self:_interacting() and O:get('game','interactionClickStick') then
                if lastInteractionStart < lastClick then
                    me._lastClick = 0
                    self:_interupt_action_interact()
                else
                    me._lastClick = t
                end
                input.btn_steelsight_press = false
            end

            local result = Run('_check_action_primary_attack', self, t, ...)
            -- capture TriggerHappy
            local weap_base = self._equipped_unit:base()

            local wtd = weap_base:weapon_tweak_data()
            local weapon_category = nil
            for i=1,#wtd.categories do
                if managers.player:has_category_upgrade(wtd.categories[i], "stacking_hit_damage_multiplier") then
                    weapon_category = wtd.categories[i]
                    break
                end
            end

            if weapon_category then
                local stack = self._state_data and self._state_data.stacking_dmg_mul and self._state_data.stacking_dmg_mul[weapon_category]
                local thMaxTime = (me.__triggerHappyMaxTime or (stack and stack[1]) or 0)
                if thMaxTime and (t < thMaxTime) then
                    local mul = managers.player:get_property("trigger_happy", 1)
                    me:Buff({
                        key='triggerHappy', good=true,
                        icon=SkillIcons, iconRect = {7 * 64, 11 * 64, 64, 64},
                        text=_.f(mul)..'x',
                        st=t, et=me.__triggerHappyMaxTime or stack[1]
                    })
                end
            end
            return result
        end)

        hook(HUDManager, "_add_name_label", function(self, data, ...)
            local id = Run("_add_name_label", self, data, ...)
            local label = self:_get_name_label(id)
            if label and data.unit and data.unit:base() and data.unit:base().is_husk_player then
                local color_id = managers.criminals:character_color_id_by_unit(data.unit)
                local crim_color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
                local panel = label.panel
                local infamy = panel:child("infamy")
                if not panel:child("boost") then
                    local boost = panel:text({
                        name = "boost",
                        align = "center",
                        layer = -1,
                        text = Icon.Start,
                        font = tweak_data.hud.medium_font,
                        font_size = tweak_data.hud.name_label_font_size * O:get("name_label", "boostScale"),
                        color = (crim_color * 1.1):with_alpha(1),
                        alpha = O:get("name_label", "showBoost") and 1 or 0,
                        visible = false
                    })
                    self:make_fine_text(boost)
                    if infamy then
                        boost:set_left(infamy:right())
                    else
                        boost:set_top(panel:child("text"):bottom())
                    end
                end
                if infamy and not O:get("name_label", "showInfamyIcon") then
                    infamy:set_visible(false)
                end
                if not O:get("name_label", "showLevelAndInfamy") then
                    local text = panel:child("text")
                    if text then
                        text:set_text(label.character_name)
                        self:align_teammate_name_label(panel, label.interact)
                    end
                end
            end
            return id
        end)
        hook(HUDManager, "update_name_label_by_peer", function(...)
            if not O:get("name_label", "showLevelAndInfamy") then
                return
            end
            Run("update_name_label_by_peer", ...)
        end)

        ShowBoost = function(peer_id, t)
            local label = managers.hud:_name_label_by_peer_id(peer_id)
            if label then
                local boost = label.panel:child("boost")
                if not boost then
                    return
                end
                if t then -- Show Boost
                    boost:set_visible(true)
                    DC:Add("ShowBoost_Hide" .. peer_id, t, ShowBoost, peer_id)
                else -- Hide Boost
                    boost:set_visible(false)
                end
            end
        end

        if buffO.enable then
            if buffO.transition then
                hook(PlayerStandard, '_start_action_unequip_weapon', function(self, t, data)
                    Run('_start_action_unequip_weapon', self, t, data)
                    local alt = self._ext_inventory:equipped_unit()
                    for k,sel in pairs(self._ext_inventory._available_selections) do
                        if sel.unit ~= alt then
                            alt = sel.unit
                            break
                        end
                    end
                    local altTD = alt:base():weapon_tweak_data()
                    local multiplier = 1
                    multiplier = multiplier * managers.player:upgrade_value("weapon", "swap_speed_multiplier", 1)
                        * managers.player:upgrade_value("weapon", "passive_swap_speed_multiplier", 1)
                        * managers.player:upgrade_value(altTD["category"], "swap_speed_multiplier", 1)

                    local altT = (altTD.timers.equip or 0.7) / multiplier

                    local et = (self._unequip_weapon_expire_t or 0) + altT
                    if et then
                        me:Buff3({
                            key='transition',
                            good=false,
                            icon=SkillIcons,
                            iconRect = {0, 9 * 64, 64, 64},
                            text='',
                            st=t,
                            et=et
                        })
                    end
                end)

                hook(PlayerStandard, '_interupt_action_use_item', function(self, t, input, complete)
                    Run('_interupt_action_use_item', self, t, input, complete)
                    local et = self._equip_weapon_expire_t
                    if et then
                        me:Buff3({
                            key='transition',
                            good=false,
                            icon=SkillIcons,
                            iconRect = {4 * 64, 3 * 64, 64, 64},
                            text='',
                            st=now(),
                            et=et
                        })
                    end
                end)

                hook(PlayerStandard, '_do_action_melee', function(self,t, input)
                    Run('_do_action_melee', self, t, input)
                    local et = self._state_data.melee_expire_t
                    if et then
                        me:Buff3({
                            key='transition',
                            good=false,
                            icon=SkillIcons,
                            iconRect = {1 * 64, 3 * 64, 64, 64},
                            text='',
                            st=t,
                            et=et
                        })
                    end
                end)
            end

            hook(PlayerStandard, '_do_melee_damage', function(self, t, ...)
                local result = Run('_do_melee_damage', self, t, ...)

                -- capture Close Combat
                if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
                    local stack = self._state_data.stacking_dmg_mul.melee
                    if stack and stack[1] and t < stack[1] then
                        local mul = 1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier") * stack[2]
                        me:Buff4({
                            key='triggerHappy', good=true,
                            icon=SkillIcons, iconRect = {4*64, 0*64, 64, 64},
                            text=_.f(mul)..'x',
                            st=t, et=stack[1]
                        })
                    else
                        me:RemoveBuff('triggerHappy')
                    end
                end
                return result
            end)

             -- PlayerManager
            if buffO.showCarryDrop then
                hook(PlayerManager, 'drop_carry', function(self, ...)
                    Run('drop_carry', self, ...)
                    pcall(me.Buff3,me,({
                        key='carryDrop', good=false,
                        icon=SkillIcons, iconRect = {6*64, 0*64, 64, 64},
                        text='',
                        st=Application:time(), et=managers.player._carry_blocked_cooldown_t
                    }) )
                end)
            end

            --[[
                TODO:
                Fix this mess
            ]]
            local rectDict = {}
            --                                1          2             3          4          5            6           7
            -- rectDict.inner-skill-name = {Label, {iconX,iconY}, isDeckIcon, isDebuff, isU100Skill, DLCDeckIcon, Function }
            rectDict.combat_medic_damage_multiplier = {L('_buff_combatMedicDamageShort'), { 5, 7 }}
            rectDict.berserker_damage_multiplier = {L('_buff_swanSongShort'),{ 5, 12 }}

            rectDict.dmg_multiplier_outnumbered = {L('_buff_underdogShort'),{2,1}}
            rectDict.dmg_dampener_outnumbered = ''-- {'Def+',{2,1}} -- Dupe
            rectDict.dmg_dampener_outnumbered_strong = ''-- {'Def+',{2,1}} -- Dupe
            rectDict.overkill_damage_multiplier = {L('_buff_overkillShort'),{3,2}}

            rectDict.first_aid_damage_reduction = {L('_buff_first_aid_damage_reduction_upgrade'),{1,11}}
            rectDict.melee_life_leech = {L('_buff_lifeLeechShort'),{7,4},true,true}
            rectDict.dmg_dampener_close_contact = {L('_buff_first_aid_damage_reduction_upgrade'),{5,4},true}
            rectDict.loose_ammo_give_team = {L('_buff_gambler_ammo'),{5,5},true,true}
            rectDict.loose_ammo_restore_health = {L('_buff_gambler_health'),{4,5},true,true}

            rectDict.damage_speed_multiplier = { L('_buff_second_wind'), {10, 9}, nil, nil, true, nil}

            rectDict.revived_damage_resist = { L("_buff_up_you_go_duration"), {11, 4}, nil, nil, true}
            rectDict.swap_weapon_faster = { L("_buff_running_from_death_weapon_duration"), {11, 3}, nil, nil, true}
            rectDict.reload_weapon_faster = rectDict.swap_weapon_faster
            rectDict.increased_movement_speed = { L("_buff_running_from_death_movement_duration"), {11, 3}, nil, nil, true}
            rectDict.unseen_strike = { L("_buff_unseen_strike_critical_boost_duration"), {10, 11}, [5] = true, [7] = function(et)
                -- This is done to ensure the critical hit chance gauge updates timely to reflect the skill's expiry, instead of being
                -- late by a full second. + 0.05 delay because of the brain-dead use of coroutines to implement the skill when :update()
                -- functions exist. Congrats, OVK, you just proved that race conditions can occur within a single-threaded program, I
                -- sure hope you're utterly elated with what you've pulled off
                DC:Add("TriggerCritPoll", et + 0.05, PollCriticalChance)
            end}

            rectDict.armor_break_invulnerable = { L('_buff_cooldown'), {6, 1}, true, true }
            rectDict.single_shot_fast_reload = { L('_buff_aggressive_reload_duration'), {8, 3}, nil, nil, true}

            rectDict.chico_injector = { L('_buff_kingpin_injector'), { 0, 0 }, true, nil, nil, KingpinDeckIcons}

            rectDict.pocket_ecm_kill_dodge = { L('_buff_hacker_temporary_dodge'), {3, 0}, true, nil, nil, HackerDeckIcons}
            rectDict.copr_ability = { L('_buff_leech_ampule'), { 0, 0 }, true, nil, nil, LeechDeckIcons}
            rectDict.mrwi_health_invulnerable = { L("_buff_immunity"), { 3, 0 }, true, nil, nil, CopycatDeckIcons }

            local _keys = { -- Better names for Option pnls
                BerserkerDamageMultiplier = 'SwanSong',
                FirstAidDamageReduction = 'FirstAid',
                DmgMultiplierOutnumbered = 'Underdog',
                CombatMedicDamageMultiplier = 'CombatMedic',
                OverkillDamageMultiplier = 'Overkill',
                MeleeLifeLeech = 'LifeLeech',
                DmgDampenerCloseContact = 'CloseCombat', -- Infiltrator
                LooseAmmoRestoreHealth = 'GamblerAmmo',
                LooseAmmoGiveTeam = 'GamblerHealth',
                DamageSpeedMultiplier = "SecondWind",
                ArmorBreakInvulnerable = "ArmorerInvulnerabilityCooldown",
                SingleShotFastReload = "AggressiveReloadDuration",
                RevivedDamageResist = "UpYouGoDuration",
                SwapWeaponFaster = "RunningFromDeathWeaponDuration",
                ReloadWeaponFaster = "RunningFromDeathWeaponDuration",
                IncreasedMovementSpeed = "RunningFromDeathMovementDuration",
                UnseenStrike = "UnseenStrikeCriticalBoostDuration",

                ChicoInjector = "KingpinInjector",

                PocketEcmKillDodge = "HackerTemporaryDodge",
                CoprAbility = "LeechAmpule",
                MrwiHealthInvulnerable = "CopycatGracePeriod"
            }
            hook(PlayerManager, 'activate_temporary_upgrade', function(self, category, upgrade)
                Run('activate_temporary_upgrade', self, category, upgrade)
                local et = _.g('managers.player._temporary_upgrades.' .. category .. '.' .. upgrade .. '.expire_time')
                if not et then
                    return
                end
                local rect = rectDict[upgrade]
                if rect and rect ~= '' then
                    if rect[7] then
                        rect[7](et)
                    end
                    local key = ('_'..upgrade):gsub('_(%U)',function(a) return a:upper() end)
                    key = _keys[key] or key
                    local buff = me.buffs[key]
                    if buff and not buff.dying then
                        buff:Extend(now(), et)
                    else
                        if not O:get('buff','show'.. (key:gsub('^%l', string.upper))) then
                            return
                        end
                        local rect2
                        if rect[5] then -- U100 icons are bigger, but they appear smaller with 80x80
                            rect2 = rect and ({(80*rect[2][1])+8,(80*rect[2][2])+8,64,64})
                        else
                            rect2 = rect and ({64*rect[2][1],64*rect[2][2],64,64})
                        end
                        me:Buff3({
                            key=key,
                            good=not rect[4],
                            icon= rect[5] and U100SkillIcons or (rect2 and (rect[3] and (rect[6] or DeckIcons) or SkillIcons)) or 'guis/textures/pd2/lock_incompatible',
                            iconRect = rect2,
                            text=rect and rect[1] or upgrade,
                            st=now(),
                            et=et
                        })
                    end
                end
            end)

            hook(PlayerManager, 'activate_temporary_upgrade_by_level', function(self, category, upgrade, level)
                Run('activate_temporary_upgrade_by_level', self, category, upgrade, level)
                local et = _.g('managers.player._temporary_upgrades.'..category ..'.'..upgrade..'.expire_time')
                if not et then return end
                local rect = rectDict[upgrade]
                if rect ~= '' then
                    local rect2 = rect and ({64*rect[2][1],64*rect[2][2],64,64})
                    local key = ('_'..upgrade):gsub('_(%U)',function(a) return a:upper() end)
                    key = _keys[key] or key
                    pcall(me.Buff,me,({
                        key=key, good=true,
                        icon=rect2 and SkillIcons or 'guis/textures/pd2/lock_incompatible', iconRect = rect2,
                        text=rect and rect[1] or upgrade,
                        st=now(), et=et
                    }) )
                end
            end)

            hook(PlayerManager, "activate_temporary_property", function(self, name, time, ...)
                Run("activate_temporary_property", self, name, time, ...)
                if name == "revived_damage_reduction" then
                    local buff = me.buffs.Painkiller
                    if not buff or buff.dying then
                        me:Buff4({
                            key = "Painkiller",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {10, (10 * 80) + 4, 64, 64},
                            text = L('_buff_painkillers'),
                            t = time,
                        })
                    else
                        buff:Extend(time)
                    end
                elseif name == "mrwi_health_invulnerable" then
                    local buff = me.buffs.CopycatGracePeriodCooldown
                    if not buff or buff.dying then
                        me:Buff4({
                            key = "CopycatGracePeriodCooldown",
                            good = false,
                            icon = CopycatDeckIcons,
                            iconRect = {3 * 64, 0, 64, 64},
                            text = L("_buff_cooldown"),
                            t = time
                        })
                    else
                        buff:Extend(time)
                    end
                end
            end)

            if buffO.showSecondWind then
                hook(PlayerManager, "activate_synced_temporary_team_upgrade", function(self, peer_id, category, upgrade, ...)
                    Run("activate_synced_temporary_team_upgrade", self, peer_id, category, upgrade, ...)
                    if category ~= "temporary" or upgrade ~= "team_damage_speed_multiplier_received" then
                        return
                    end

                    local upgrade_value = self:upgrade_value(category, upgrade)
                    if upgrade_value == 0 then
                        -- Eh, even after the game's code has handled it? Still?!
                        return
                    end

                    local buff = me.buffs.SecondWind
                    if buff and not buff.dying then
                        buff:Extend(upgrade_value[2])
                    else
                        me:Buff3({
                            key = "SecondWind",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {(10 * 80) + 8, (9 * 80) + 8, 64, 64},
                            text = L("_buff_second_wind"),
                            t = upgrade_value[2]
                        })
                    end
                end)
            end

            --////////////////////--
            --//  (AI) Inspire  //--
            --////////////////////--
            local function CreateBuffInspireCooldownAI(duration)
                local playertime = now()
                me:Buff4({
                    key = "AIReviveCooldown",
                    good = false,
                    icon = U100SkillIcons,
                    iconRect = {328, 728, 64, 64}, -- Inspire icon
                    text = L("_buff_AIReviveCooldown"),
                    st = playertime,
                    et = playertime + duration
                })
            end

            -- Abilities
            local AbilityKey = nil
            local AbilityIcon = nil
            local AbilityIconRect = {0, 0, 64, 64}
            local AbilitySpeedUp = nil -- Unregister Vanilla speed up function when the cooldown ends, not applicable to some. They will get registered again after player uses them again
            local StoicIconRect = {0, 0, 64, 64}
            local StoicAutoShrug = nil
            hook(PlayerManager, "start_timer", function(self, key, duration, ...)
                if key == "replenish_grenades" and AbilityKey then
                    local buff = me.buffs[AbilityKey]
                    if buff and not buff.dying then
                        buff:Extend(duration)
                    else
                        me:Buff4({
                            key = AbilityKey,
                            good = false,
                            icon = AbilityIcon,
                            iconRect = AbilityIconRect,
                            text = L("_buff_cooldown"),
                            t = duration
                        })
                    end
                elseif key == "team_crew_inspire" then
                    CreateBuffInspireCooldownAI(duration)
                    LuaNetworking:SendToPeers("Poco_AIReviveCooldown", duration)
                end
                Run("start_timer", self, key, duration, ...)
            end)

            hook(PlayerManager, "speed_up_grenade_cooldown", function(self, time, ...)
                if not self._timers.replenish_grenades then
                    return
                end
                if not AbilityKey then
                    return Run("speed_up_grenade_cooldown", self, time, ...)
                end
                local buff = me.buffs[AbilityKey]
                if buff and not buff.dying then
                    buff:D(time)
                end
                Run("speed_up_grenade_cooldown", self, time, ...)
            end)

            hook(PlayerManager, "_on_grenade_cooldown_end", function(self, ...)
                Run("_on_grenade_cooldown_end", self, ...)
                if self:has_active_timer("replenish_grenades") then
                    return
                end
                if AbilitySpeedUp then
                    self:unregister_message(Message.OnEnemyKilled, AbilitySpeedUp)
                end
            end)

            CheckAbility = function() -- Cache the ability, if selected
                local grenade = managers.blackmarket:equipped_grenade()
                if grenade == "chico_injector" then -- Kingpin
                    AbilityKey = "KingpinInjectorCooldown"
                    AbilityIcon = KingpinDeckIcons
                    AbilitySpeedUp = "speed_up_chico_injector"
                elseif grenade == "smoke_screen_grenade" then -- Sicario
                    AbilityKey = "SicarioSmokeGrenadeCooldown"
                    AbilityIcon = SicarioDeckIcons
                elseif grenade == "damage_control" then -- Stoic
                    AbilityKey = "StoicHipFlaskCooldown"
                    AbilityIcon = StoicDeckIcons
                    AbilityIconRect[2] = 64
                    if managers.player:has_category_upgrade("player", "damage_control_auto_shrug") then
                        StoicIconRect[1] = 128
                        StoicAutoShrug = managers.player:upgrade_value("player", "damage_control_auto_shrug")
                    end
                    -- Re-register the message if the options were changed mid-game
                    managers.player:unregister_message("ability_activated", "PocoHud3_Stoic_Ability_Activated")
                    managers.player:register_message("ability_activated", "PocoHud3_Stoic_Ability_Activated", function(ability_name)
                        if ability_name == "damage_control" then
                            me:RemoveBuff("StoicDelayDamage")
                        end
                    end)
                elseif grenade == "tag_team" then -- Tag Team
                    AbilityKey = "TagTeamCooldown"
                    AbilityIcon = TagTeamDeckIcons
                elseif grenade == "pocket_ecm_jammer" then -- Hacker
                    AbilityKey = "HackerPocketECMJammerCooldown"
                    AbilityIcon = HackerDeckIcons
                    AbilitySpeedUp = "speed_up_pocket_ecm_jammer"
                elseif grenade == "copr_ability" then -- Leech
                    AbilityKey = "LeechAmpuleCooldown"
                    AbilityIcon = LeechDeckIcons
                    AbilitySpeedUp = "speed_up_copr_ability"
                end
            end

            -- Ability cooldown is purged when the player is taken to custody,
            -- but this is not propagated to Poco, so do it here
            hook(IngameWaitingForRespawnState, "at_enter", function(...)
                if AbilityKey then
                    me:RemoveBuff(AbilityKey)
                end
                Run("at_enter", ...)
            end)
            -- End of abilities

            --/////////////////--
            --//  Anarchist  //--
            --/////////////////--
            -- This is necessary because of the incredibly awkward way OVK implemented this skill. It does not begin ticking until the very
            -- first time the player takes damage, after which it ticks forever - even when the player's armor is already at its maximum
            -- It does, however, get paused when the player is in bleedout, and is resumed the first time they take damage after they are
            -- revived (and not immediately upon revive)
            local TrackAnarchistRegenTick = O:get("buff", "showAnarchistRegenTick")
            local showPersistentAnarchistRegenTick = O:get("buff", "showPersistentAnarchistRegenTick")
            hook(PlayerDamage, "_on_damage_armor_grinding", function(self, ...)
                local should_show = nil
                if TrackAnarchistRegenTick then
                    should_show = self._current_state == nil or self._current_state ~= self._update_armor_grinding
                    if should_show == false and not showPersistentAnarchistRegenTick then
                        -- Do not add the buff again if it is already visible (otherwise it will flicker)
                        local buff = me.buffs.AnarchistRegenTick
                        if not buff or buff.dying then
                            should_show = self:get_real_armor() < self:_max_armor()
                        end
                    end
                end
                Run("_on_damage_armor_grinding", self, ...)
                if should_show and self._current_state == self._update_armor_grinding then
                    -- Getting downed or entering swan song pauses the timer, getting revived resumes the timer (as opposed to resetting it)
                    local playertime = managers.player:player_timer():time()
                    me:Buff3({
                        key = "AnarchistRegenTick",
                        good = true,
                        icon = AnarchistDeckIcons,
                        iconRect = {0, 0, 64, 64},
                        text = L("_buff_regen"),
                        st = playertime - self._armor_grinding.elapsed,
                        et = playertime + (self._armor_grinding.target_tick - self._armor_grinding.elapsed)
                    })
                end
            end)
            hook(PlayerDamage, "_remove_on_damage_event", function(...)
                Run("_remove_on_damage_event", ...)
                -- Getting downed or entering swan song pauses the timer, reflect this
                me:RemoveBuff("AnarchistRegenTick")
            end)
            local showAnarchistRegenGain = buffO.showAnarchistRegenGain
            hook(PlayerDamage, "_update_armor_grinding", function(self, t, ...)
                local before = self:get_real_armor()
                Run("_update_armor_grinding", self, t, ...)
                -- This can only occur once every several seconds so it doesn't need to be optimized as aggressively
                if self._armor_grinding.elapsed == 0 then
                    local after = self:get_real_armor()
                    local delta = after - before
                    if TrackAnarchistRegenTick and (delta > 0 or showPersistentAnarchistRegenTick) then
                        local endtime = t + self._armor_grinding.target_tick
                        -- Don't flicker
                        local buff = me.buffs.AnarchistRegenTick
                        if buff and not buff.dying then
                            buff.data.st = t
                            buff.data.et = endtime
                        end
                        me:Buff3({
                            key = "AnarchistRegenTick",
                            good = true,
                            icon = AnarchistDeckIcons,
                            iconRect = {0, 0, 64, 64},
                            text = L("_buff_regen"),
                            st = t,
                            et = endtime
                        })
                    end
                    if showAnarchistRegenGain then
                        local option = O:get("hit", "gainIndicator") or 0
                        if O:get("hit", "enable") and option > 1 then
                            if delta > 0 then
                                if option > 2 then
                                    managers.menu_component:post_event("menu_skill_investment")
                                end
                                me:SimpleFloat({
                                    key = "armor",
                                    x = (me.ww or 800) / 5 * 3,
                                    y = (me.hh or 600) / 4 * 3,
                                    time = 3,
                                    anim = 1,
                                    offset = {
                                        0,
                                        -1 * (me.hh or 600) / 2
                                    },
                                    text = {
                                        {
                                            '+',
                                            cl.White:with_alpha(0.6)
                                        },
                                        {
                                            _.f(delta * 10),
                                            clGood
                                        }
                                    },
                                    size = 18,
                                    rect = 0.5
                                })
                            end
                        end
                    end
                end
            end)

            --///////////////////////////--
            --//  Armorer / Anarchist  //--
            --///////////////////////////--
            hook(PlayerDamage, "_calc_armor_damage*", function(self, ...)
                local previous = self._can_take_dmg_timer
                local result = Run("_calc_armor_damage*", self, ...)
                if self._can_take_dmg_timer > previous then
                    local playertime = managers.player:player_timer():time()
                    me:Buff4({
                        key = "Immunity",
                        good = true,
                        icon = DeckIcons,
                        iconRect = {6 * 64, 64, 64, 64},
                        text = L("_buff_immunity"),
                        st = playertime,
                        et = playertime + self._can_take_dmg_timer
                    })
                end
                return result
            end)

            --/////////////--
            --//  Biker  //--
            --/////////////--
            local DoNotTrackBikerCooldown = not O:get("buff", "showBikerCooldown")
            local function ShowBikerCooldown()
                if DoNotTrackBikerCooldown then
                    return
                end

                local playermanager = managers.player
                if playermanager == nil then
                    return
                end

                -- Purge expired kills. This is necessary to ensure proper functionality even when the kill count gauge is disabled
                local t = Application:time()
                while playermanager._wild_kill_triggers[1] and t >= playermanager._wild_kill_triggers[1] do
                    table.remove(playermanager._wild_kill_triggers, 1)
                end

                local newkills = #playermanager._wild_kill_triggers
                if newkills < 1 then
                    return
                end
                local maxkills = tweak_data.upgrades.wild_max_triggers_per_time or 10
                local t_now = Application:time()
                local good = true
                local cooldown = nil
                if newkills < maxkills then
                    cooldown = playermanager._wild_kill_triggers[newkills] - t_now
                else
                    cooldown = playermanager._wild_kill_triggers[1] - t_now
                    good = false
                    -- Add a delayed call to show the longest cooldown again when this one expires
                    DC:Add("ShowBikerCooldown", cooldown, ShowBikerCooldown)
                end

                local buff = me.buffs.BikerCooldown
                if not buff or buff.dying or buff.data.good ~= good then
                    me:Buff3({
                        key = "BikerCooldown",
                        good = good,
                        icon = BikerDeckIcons,
                        iconRect = {0, 0, 64, 64},
                        text = L("_buff_cooldown"),
                        t = cooldown
                    })
                else
                    buff:Extend(cooldown)
                end

                -- Colorize the buff for the 'Vanilla' style since it does not permit any additional text
                if not good and buff_style == 2 then
                    local buff = me.buffs.BikerCooldown
                    if buff then
                        if not buff.created then
                            buff:_make()
                        end
                        local color = clBad or Color(1, 0.84, 0)
                        if alive(buff.bmp) then
                            buff.bmp:set_color(color)
                        end
                        if alive(buff.bg) then
                            local children = buff.bg:children()
                            if children ~= nil then
                                for __, panel in ipairs(children) do
                                    if alive(panel) and panel.type_name == "Bitmap" then
                                        panel:set_color(color)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            hook(PlayerManager, "chk_wild_kill_counter", function(self, killed_unit, ...)
                local player_unit = self:player_unit()
                if not player_unit then
                    return Run("chk_wild_kill_counter", self, killed_unit, ...)
                end
                if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
                    return Run("chk_wild_kill_counter", self, killed_unit, ...)
                end
                local damage_ext = player_unit:character_damage()
                if not damage_ext or (not self:has_category_upgrade("player", "wild_health_amount") and not self:has_category_upgrade("player", "wild_armor_amount")) then
                    return Run("chk_wild_kill_counter", self, killed_unit, ...)
                end

                Run("chk_wild_kill_counter", self, killed_unit, ...)

                -- Update the kills gauge immediately
                PollBikerKills()

                ShowBikerCooldown()
            end)

            local biker_kills_text_tbl = {{}, {}}
            local biker_kills_previous = 0
            -- This ensures that HideBikerKillsGauge() only gets scheduled once - upon depletion - rather than recurringly while zero
            local biker_kills_latch = nil

            local function HideBikerKillsGauge()
                local playermanager = managers.player
                if playermanager == nil then
                    return
                end

                local newkills = 0
                if playermanager._wild_kill_triggers then
                    -- Purge expired kills
                    local t = Application:time()
                    while playermanager._wild_kill_triggers[1] and t >= playermanager._wild_kill_triggers[1] do
                        table.remove(playermanager._wild_kill_triggers, 1)
                    end

                    newkills = #playermanager._wild_kill_triggers
                end

                if newkills > 0 then
                    return
                end

                me:RemoveBuff("BikerKillsGauge")
            end

            local DoNotTrackBikerKillsGauge = not O:get("buff", "showBikerKillsGauge")
            PollBikerKills = function()
                if DoNotTrackBikerKillsGauge then
                    return
                end

                local playermanager = managers.player

                if playermanager == nil then
                    return
                end

                if not playermanager:has_category_upgrade("player", "wild_health_amount") and not playermanager:has_category_upgrade("player", "wild_armor_amount") then
                    return
                end

                if playermanager._wild_kill_triggers ~= nil then
                    -- Purge expired kills
                    local t = Application:time()
                    while playermanager._wild_kill_triggers[1] and t >= playermanager._wild_kill_triggers[1] do
                        table.remove(playermanager._wild_kill_triggers, 1)
                    end

                    local newkills = #playermanager._wild_kill_triggers
                    local maxkills = tweak_data.upgrades.wild_max_triggers_per_time or 10
                    if newkills > maxkills then
                        newkills = maxkills
                    end
                    local ratio = newkills / maxkills
                    local good = ratio < 1
                    local text = nil
                    -- The buff title must not be specified for the 'Vanilla' style when et is 1
                    if buff_style ~= 2 then
                        -- Recycling tables to prevent memory wastage since this code runs frequently
                        text = biker_kills_text_tbl
                        text[1][1] = L("_buff_biker_kills_gauge")
                        text[2][1] = string_format(" %s", tostring(newkills))
                        text[2][2] = good and clGood or clBad
                    else
                        text = string_format("%s", tostring(newkills))
                    end
                    if biker_kills_previous > 0 or biker_kills_previous < newkills then
                        me:Buff3({
                            key = "BikerKillsGauge",
                            good = good,
                            icon = BikerDeckIcons,
                            iconRect = {0, 0, 64, 64},
                            text = text,
                            st = buff_style == 2 and ratio or 1 - ratio,
                            et = 1
                        })

                        -- Colorize the buff for the 'Vanilla' style since it does not permit any additional text
                        if not good and buff_style == 2 then
                            local buff = me.buffs.BikerKillsGauge
                            if buff then
                                if not buff.created then
                                    buff:_make()
                                end
                                local color = clBad or Color(1, 0.84, 0)
                                if alive(buff.bmp) then
                                    buff.bmp:set_color(color)
                                end
                                if alive(buff.bg) then
                                    local children = buff.bg:children()
                                    if children ~= nil then
                                        for __, panel in ipairs(children) do
                                            if alive(panel) and panel.type_name == "Bitmap" then
                                                panel:set_color(color)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        -- Disarm the latch whenever the buff is shown (so that HideBikerKillsGauge() can be scheduled again)
                        biker_kills_latch = true
                    end
                    biker_kills_previous = newkills
                    -- Allow the player one second to visually confirm that their kills have reduced to 0 before hiding the gauge
                    if newkills < 1 and biker_kills_latch then
                        biker_kills_latch = false
                        DC:Add("HideBikerKillsGauge", 1, HideBikerKillsGauge)
                    end
                end
                DC:Add("PollBikerKills", BikerKillsGaugeResolution, PollBikerKills)
            end

            --///////////////--
            --//  Sicario  //--
            --///////////////--
            hook(PlayerManager, "spawn_smoke_screen", function(self, position, normal, grenade_unit, ...)
                Run("spawn_smoke_screen", self, position, normal, grenade_unit, ...)
                if grenade_unit and grenade_unit:base() and alive(grenade_unit:base():thrower_unit()) and grenade_unit:base():thrower_unit() == self:player_unit() then
                    local player_time = self:player_timer():time()
                    me:Buff4({
                        key = "SicarioSmokeGrenade",
                        good = true,
                        icon = SicarioDeckIcons,
                        iconRect = {0, 0, 64, 64},
                        text = L("_buff_sicario_smoke_screen_grenade"),
                        st = player_time,
                        et = player_time + tweak_data.projectiles.smoke_screen_grenade.duration
                    })
                end
            end)

            local twitch_gauge_previous = 0
            local twitch_gauge_latch = false
            local twitch_range_text_tbl = {{}, {}}
            local function SicarioTwitchRemoval()
                local mp = managers.player
                local dodge_value = mp._dodge_shot_gain_value or 0
                if dodge_value == 0 then
                    me:RemoveBuff("SicarioTwitchGauge")
                end
            end

            hook(PlayerManager, "_dodge_shot_gain", function(self, gain_value, ...)
                local dodge_value = gain_value or self._dodge_shot_gain_value or 0
                if twitch_gauge_previous ~= dodge_value then
                    twitch_gauge_previous = dodge_value
                    local text = nil
                    -- The buff title must not be specified for the 'Vanilla' style when et is 1
                    if buff_style ~= 2 then
                        -- Recycling tables to prevent memory wastage
                        text = twitch_range_text_tbl
                        text[1][1] = L("_buff_sicario_twitch_gauge")
                        text[2][1] = string_format(" %s%%", tostring(_.f(dodge_value * 100, 1)))
                        text[2][2] = clGood
                    else
                        text = string_format("%s%%", tostring(_.f(dodge_value * 100, 1)))
                    end
                    me:Buff4({
                        key = "SicarioTwitchGauge",
                        good = true,
                        icon = SicarioDeckIcons,
                        iconRect = {64, 0, 64, 64},
                        text = text,
                        st = buff_style == 2 and dodge_value or 1 - dodge_value,
                        et = 1
                    })
                    twitch_gauge_latch = true
                end
                if dodge_value <= 0 and twitch_gauge_latch then
                    twitch_gauge_latch = false
                    DC:Add("SicarioTwitchRemoval", 1.5, SicarioTwitchRemoval)
                end
                if dodge_value > 0 and dodge_value ~= self._dodge_shot_gain_value then
                    local et = tweak_data.upgrades.values.player.dodge_shot_gain[1][2]
                    local buff = me.buffs.SicarioTwitchCooldown
                    if buff and not buff.dying then
                        buff:Extend(et)
                    else
                        me:Buff4({
                            key = "SicarioTwitchCooldown",
                            good = false,
                            icon = SicarioDeckIcons,
                            iconRect = {64, 0, 64, 64},
                            text = L("_buff_cooldown"),
                            t = et
                        })
                    end
                end
                return Run("_dodge_shot_gain", self, gain_value, ...)
            end)

            --/////////////--
            --//  Stoic  //--
            --/////////////--
            hook(PlayerDamage, "delay_damage", function(self, damage, seconds, ...)
                local buff = me.buffs.StoicDelayDamage
                if buff and not buff.dying then
                    buff:Extend(StoicAutoShrug or seconds)
                else
                    me:Buff4({
                        key = "StoicDelayDamage",
                        good = false,
                        icon = StoicDeckIcons,
                        iconRect = StoicIconRect,
                        text = L("_buff_stoic_delay_damage"),
                        t = StoicAutoShrug or seconds
                    })
                end
                Run("delay_damage", self, damage, seconds, ...)
            end)
            hook(PlayerDamage, "clear_delayed_damage", function(...)
                me:RemoveBuff("StoicDelayDamage")
                return Run("clear_delayed_damage", ...)
            end)

            --////////////////--
            --//  Tag Team  //--
            --////////////////--
            local function IncreaseTagTeamTime(BuffKey, st, et)
                local buff = me.buffs[BuffKey]
                if buff and not buff.dying then
                    buff.data.st = st
                    buff.data.et = et
                end
            end
            local TagTeam =
            {
                Effect =
                {
                    Priority = 1,
                    Function = function(tagged, owner)
                        local base_values = managers.player:upgrade_value("player", "tag_team_base")
                        local timer = TimerManager:game()
                        local end_time = timer:time() + base_values.duration
                        local function on_damage(damage_info)
                            local was_killed = damage_info.result.type == "death"
                            local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
                            if was_killed and valid_player then
                                end_time = math.min(end_time + base_values.kill_extension, timer:time() + base_values.duration)
                                IncreaseTagTeamTime("TagTeamEffect", timer:time(), end_time)
                            end
                        end
                        local on_damage_key = "TagTeam_Poco_on_damage"
                        CopDamage.register_listener(on_damage_key, { "on_damage" }, on_damage)
                        while alive(owner) and timer:time() < end_time do
                            coroutine.yield()
                        end
                        CopDamage.unregister_listener(on_damage_key)
                    end
                },
                Tagged =
                {
                    Priority = 1,
                    Function = function (tagged, owner, BuffKey)
                        local base_values = owner:base():upgrade_value("player", "tag_team_base")
                        local timer = TimerManager:game()
                        local end_time = timer:time() + base_values.duration
                        local on_damage_key = "on_damage_" .. BuffKey .. "_Poco"
                        local function on_damage(damage_info)
                            local was_killed = damage_info.result.type == "death"
                            local valid_player = damage_info.attacker_unit == owner or damage_info.attacker_unit == tagged
                            if was_killed and valid_player then
                                end_time = math.min(end_time + base_values.kill_extension, timer:time() + base_values.duration)
                                IncreaseTagTeamTime(BuffKey, timer:time(), end_time)
                            end
                        end
                        CopDamage.register_listener(on_damage_key, { "on_damage" }, on_damage)
                        local ended_by_owner = false
                        local on_end_key = "on_end_tag_" .. BuffKey .. "_Poco"
                        local function on_action_end(end_tagged, end_owner)
                            local tagged_match = tagged == end_tagged
                            local owner_match = owner == end_owner
                            ended_by_owner = tagged_match and owner_match
                            if ended_by_owner then
                                me:RemoveBuff(BuffKey)
                            end
                        end
                        managers.player:add_listener(on_end_key, { "tag_team_end" }, on_action_end)
                        while not ended_by_owner and alive(tagged) and (alive(owner) or timer:time() < end_time) do
                            coroutine.yield()
                        end
                        CopDamage.unregister_listener(on_damage_key)
                        managers.player:remove_listener(on_end_key)
                    end
                }
            }
            hook(PlayerManager, "_attempt_tag_team", function(self, ...)
                local result = Run("_attempt_tag_team", self, ...)
                if result and buffO.showTagTeamEffect then
                    local duration = self:upgrade_value("player", "tag_team_base", {}).duration
                    if not duration then -- No duration ? How ?
                        return
                    end
                    local time = now()
                    me:Buff3({
                        key = "TagTeamEffect",
                        good = true,
                        icon = TagTeamDeckIcons,
                        iconRect = {0, 64, 64, 64},
                        text = L("_buff_tag_team_effect"),
                        st = time,
                        et = time + duration
                    })
                    local args = self._coroutine_mgr._buffer.tag_team.arg
                    local tagged, owner = unpack(args)
                    self:add_coroutine("tag_team_poco", TagTeam.Effect, tagged, owner)
                end
                return result
            end)
            hook(PlayerManager, "sync_tag_team", function(self, tagged, owner, end_time, ...)
                -- "end_time" is never passed, it is always nil
                Run("sync_tag_team", self, tagged, owner, end_time, ...)
                if tagged == self:local_player() and buffO.showTagTeamTagged then
                    local base_values = owner:base():upgrade_value("player", "tag_team_base") or {}
                    local duration = base_values.duration
                    if not duration then -- No duration ? Is the owner running a rebalance or cheating ?
                        -- Other possible explanation is that the local player is running a rebalance,
                        -- making synced upgrades from client marked as invalid
                        -- End the execution here because the vanilla coroutine will crash too
                        return
                    end
                    local tagged_id = managers.network:session():peer_by_unit(tagged):id()
                    local owner_id = managers.network:session():peer_by_unit(owner):id()
                    local coroutine_key = "TagTeam_" .. tagged_id .. owner_id .. "_Tagged"
                    local player_time = self:player_timer():time()
                    me:Buff3({
                        key = coroutine_key,
                        good = true,
                        icon = TagTeamDeckIcons,
                        iconRect = {0, 64, 64, 64},
                        text = L("_buff_tag_team_tagged"),
                        st = player_time,
                        et = player_time + duration
                    })
                    self:add_coroutine(coroutine_key, TagTeam.Tagged, tagged, owner, coroutine_key)
                end
            end)

            --//////////////--
            --//  Hacker  //--
            --//////////////--
            hook(PlayerInventory, "_start_jammer_effect", function(self, end_time, ...)
                local result = Run("_start_jammer_effect", self, end_time, ...)
                end_time = end_time or self:get_jammer_time()
                if end_time ~= 0 and managers.player:player_unit() == self._unit and result then
                    local time = now()
                    me:Buff4({
                        key = "HackerPocketECMJammerJammerEffect",
                        good = true,
                        icon = SkillIcons,
                        iconRect = {384, 192, 64, 64},
                        text = "",
                        st = time,
                        et = time + end_time
                    })
                end
                return result
            end)
            hook(PlayerInventory, "_start_feedback_effect", function(self, end_time, ...)
                local result = Run("_start_feedback_effect", self, end_time, ...)
                end_time = end_time or self:get_jammer_time()
                if end_time ~= 0 and managers.player:player_unit() == self._unit and result then
                    local time = now()
                    me:Buff4({
                        key = "HackerPocketECMJammerFeedbackEffect",
                        good = true,
                        icon = SkillIcons,
                        iconRect = {384, 128, 64, 64},
                        text = "",
                        st = time,
                        et = time + end_time
                    })
                end
                return result
            end)

            --/////////////--
            --//  Leech  //--
            --/////////////--
            hook(PlayerDamage, "on_copr_ability_activated", function(...)
                Run("on_copr_ability_activated", ...)
                me:RemoveBuff("shield")
            end)
            hook(PlayerManager, "force_end_copr_ability", function(...)
                Run("force_end_copr_ability", ...)
                me:RemoveBuff("LeechAmpule")
            end)
            if buffO.showLeechImmunityDuration then
                hook(PlayerDamage, "on_copr_killshot", function(self, ...)
                    Run("on_copr_killshot", self, ...)
                    local buff = me.buffs.LeechImmunityDuration
                    local t = managers.player:player_timer():time()
                    local et = Application:digest_value(self._next_allowed_dmg_t, false)
                    if not buff or buff.dying then
                        me:Buff3({
                            key = "LeechImmunityDuration",
                            good = true,
                            icon = DeckIcons,
                            iconRect = {6 * 64, 64, 64, 64},
                            text = L("_buff_immunity"),
                            st = t,
                            et = et
                        })
                    else
                        buff.data.st = t
                        buff.data.et = et
                    end
                end)
            end

            if buffO.showReplenishThrowableAI then
                local lbl = {{ [1] = L("_buff_regen") }, { [2] = clGood }}
                local value = tweak_data.upgrades.values.team.crew_throwable_regen
                local max = (value and value[1] or 35) + 1
                local progress = 0
                local function IncreaseProgress(...)
                    progress = progress + 1
                    if progress == max then
                        progress = 0
                    end
                    local buff = me.buffs.ReplenishThrowableAI
                    if buff and not buff.dying then
                        local ratio = progress / max
                        local text = nil
                        local remaining = max - progress
                        if buff_style ~= 2 then
                            text = lbl
                            text[2][1] = string_format(" %s", tostring(remaining))
                        else
                            text = string_format("%s", tostring(remaining))
                        end
                        buff:Extend(buff_style == 2 and ratio or 1 - ratio, text)
                    end
                end
                function TeamAIBase:Poco_Refresh(loadout)
                    loadout = loadout or self._loadout
                    if not loadout then
                        return
                    end
                    if loadout.skill == "crew_generous" then
                        local buff = me.buffs.ReplenishThrowableAI
                        if not buff or buff.dying then
                            progress = managers.player._throw_regen_kills or 0
                            local ratio = progress / max
                            local text = nil
                            local remaining = max - progress
                            if buff_style ~= 2 then
                                text = lbl
                                text[2][1] = string_format(" %s", tostring(remaining))
                            else
                                text = string_format("%s", tostring(remaining))
                            end
                            me:GaugeBuff3({
                                key = "ReplenishThrowableAI",
                                good = true,
                                icon = tweak_data.hud_icons.skill_7.texture,
                                iconRect = tweak_data.hud_icons.skill_7.texture_rect,
                                text = text,
                                st = buff_style == 2 and ratio or 1 - ratio
                            })
                            managers.player:register_message(Message.OnEnemyKilled, "Poco_crew_throwable_regen", IncreaseProgress)
                        end
                    end
                end
                hook(TeamAIBase, "set_loadout", function(self, loadout, ...)
                    Run("set_loadout", self, loadout, ...)
                    self:Poco_Refresh(loadout)
                end)
                hook(TeamAIBase, "remove_upgrades", function(self, ...)
                    if not self._loadout then
                        Run("remove_upgrades", self, ...)
                        return
                    end
                    if self._loadout.skill == "crew_generous" then
                        me:RemoveBuff("ReplenishThrowableAI")
                        managers.player:unregister_message(Message.OnEnemyKilled, "Poco_crew_throwable_regen")
                    end
                    Run("remove_upgrades", self, ...)
                end)
            end

            --///////////////////--
            --//  Uppers Aced  //--
            --///////////////////--
            local uppers_range_text_tbl = {{ [1] = L("_buff_uppers_range") }, { [2] = clGood }}
            -- Based on FirstAidKitBase.GetFirstAidKit(). As with the game's own version, this function does not guarantee that the returned
            -- unit is the /closest/ one. Instead, it just returns the first instance it finds that satisfies the distance criterion, even if
            -- there may be another unit that is closer to the player. There is no point in fixing this behavior until OVK does so themselves
            -- since the game itself will just consume the first instance anyway
            local function GetFirstApplicableFAK(pos)
                if pos and FirstAidKitBase.List then
                    local distance_sq = mvector3.distance_sq
                    local cached_limit_sq = nil
                    for i, o in pairs(FirstAidKitBase.List) do
                        -- Square roots are computationally expensive to execute, do not perform them in a loop (distance computation
                        -- involves the Pythagorean theorem)
                        local dst = distance_sq(pos, o.pos)
                        if dst <= (cached_limit_sq or (o.min_distance * o.min_distance)) then
                            return math.sqrt(dst), o.min_distance, o.obj
                        end
                    end
                end
                return 0, 0, nil
            end

            -- Standard IEEE rounding to the nearest integer (round half away from zero)
            local function RoundToNearest(real)
                return real >= 0 and math.floor(real + 0.5) or math.ceil(real - 0.5)
            end

            local DoNotTrackUppersRangeGauge = not O:get("buff", "showUppersRangeGauge")
            PollUppersRange = function()
                if DoNotTrackUppersRangeGauge then
                    return
                end

                local playermanager = managers.player

                if playermanager == nil then
                    return
                end

                local playerunit = playermanager:player_unit()
                if alive(playerunit) then
                    if not me then
                        return
                    end
                    local distance, limit, fak = GetFirstApplicableFAK(playerunit:position())
                    if fak then
                        local ratio = distance / limit
                        local text = nil
                        -- The buff title must not be specified for the 'Vanilla' style when et is 1
                        if buff_style ~= 2 then
                            -- Recycling tables to prevent memory wastage
                            text = uppers_range_text_tbl
                            text[2][1] = string_format(" %sm", tostring(RoundToNearest(distance * 0.01)))
                        else
                            text = string_format("%sm", tostring(RoundToNearest(distance * 0.01)))
                        end
                        me:GaugeBuff3({
                            key = "UppersRangeGauge",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {(2 * 80) + 10, (11 * 80) + 8, 64, 64},
                            text = text,
                            st = buff_style == 2 and 1 - ratio or ratio
                        })
                    else
                        me:RemoveBuff("UppersRangeGauge")
                    end
                end
                DC:Add("PollUppersRange", UppersRangeResolution, PollUppersRange)
            end

            Hooks:Add("NetworkReceivedData", "NetworkReceivedData_PocoHud3", function(sender, id, data)
                if id == "Poco_AIReviveCooldown" then
                    CreateBuffInspireCooldownAI(data) -- data is our cooldown duration
                end
            end)

            hook(PlayerManager, "disable_cooldown_upgrade", function(self, category, upgrade, ...)
                local upgrade_value = self:upgrade_value(category, upgrade)
                if upgrade_value == 0 then
                    return
                end
                Run("disable_cooldown_upgrade", self, category, upgrade, ...)
                if category ~= "cooldown" or upgrade ~= "long_dis_revive" then
                    return
                end
                local playertime = self:player_timer():time()
                me:Buff4({
                    key = "InspireReviveCooldown",
                    good = false,
                    icon = U100SkillIcons,
                    iconRect = {(4 * 80) + 8, (9 * 80) + 8, 64, 64},
                    text = L("_buff_inspire_revive_cooldown"),
                    st = playertime,
                    et = playertime + upgrade_value[2]
                })
            end)

            hook(PlayerDamage, "_check_bleed_out", function(self, ...)
                local previous = self._uppers_elapsed
                Run("_check_bleed_out", self, ...)
                if previous < self._uppers_elapsed then
                    me:Buff4({
                        key = "UppersCooldown",
                        good = false,
                        icon = U100SkillIcons,
                        iconRect = {(2 * 80) + 10, (11 * 80) + 8, 64, 64},
                        text = L("_buff_cooldown"),
                        t = self._UPPERS_COOLDOWN or 20
                    })
                    -- It is possible to ping PollUppersRange instead, but this method is much simpler (and a bit
                    -- less expensive) since no extra poll is incurred (after all, it will tick again soon after this)
                    me:RemoveBuff("UppersRangeGauge")
                end
            end)

            --//////////////////////////--
            --//  Dodge Chance Gauge  //--
            --//////////////////////////--
            local dodge_gauge_text_tbl = {{ [1] = L("_buff_dodge_chance_gauge") }, { [2] = clGood }}
            local dodge_gauge_previous = 0
            local dodge_gauge_latch = nil
            local TrackPersistentDodgeChanceGauge = O:get("buff", "showPersistentDodgeChanceGauge")
            local function ComputeOverallDodgeChance(playermanager)
                if playermanager == nil or tweak_data == nil then
                    return
                end

                local playermovement = playermanager:player_unit()
                if playermovement == nil then
                    return
                end
                playermovement = playermovement:movement()
                if playermovement == nil then
                    return
                end

                -- From PlayerDamage:damage_bullet()
                local basechance = tweak_data.player.damage.DODGE_INIT or 0
                local armorchance = playermanager:body_armor_value("dodge")
                local skillchance = playermanager:skill_dodge_chance(playermovement:running(), playermovement:crouching(), playermovement:zipline_unit())
                return basechance + armorchance + skillchance
            end

            local function HideDodgeChanceGauge()
                if TrackPersistentDodgeChanceGauge then
                    return
                end

                local playermanager = managers.player
                if playermanager == nil then
                    return
                end
                local chance = ComputeOverallDodgeChance(playermanager)
                if chance == nil or chance > 0 then
                    return
                end

                me:RemoveBuff("DodgeChanceGauge")
            end

            local DoNotTrackDodgeChanceGauge = not O:get("buff", "showDodgeChanceGauge")
            PollDodgeChance = function()
                if DoNotTrackDodgeChanceGauge then
                    return
                end

                if not me then
                    DC:Add("PollDodgeChance", 1, PollDodgeChance)
                    return
                end

                local playermanager = managers.player

                if playermanager == nil then
                    return
                end

                local chance = ComputeOverallDodgeChance(playermanager)
                if chance == nil then
                    me:RemoveBuff("DodgeChanceGauge")
                else
                    local text = nil
                    -- The buff title must not be specified for the 'Vanilla' style when et is 1
                    if buff_style ~= 2 then
                        -- Recycling tables to prevent memory wastage
                        text = dodge_gauge_text_tbl
                        text[2][1] = string_format(" %s%%", tostring(_.f(chance * 100, 1)))
                    else
                        text = string_format("%s%%", tostring(_.f(chance * 100, 1)))
                    end
                    -- The last check ensures that any increases in chance are always permitted to be displayed this tick (otherwise it
                    -- will only be added on the following tick, one second later)
                    if TrackPersistentDodgeChanceGauge or dodge_gauge_previous > 0 or dodge_gauge_previous < chance then
                        me:Buff3({
                            key = "DodgeChanceGauge",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {(1 * 80) + 10, 12 * 80, 64, 64},
                            text = text,
                            st = buff_style == 2 and chance or 1 - chance,
                            et = 1
                        })
                        dodge_gauge_latch = true
                    end
                    dodge_gauge_previous = chance
                    -- Allow the player one second to visually confirm that their dodge chance has been reduced to 0 before hiding the
                    -- gauge
                    if chance <= 0 and dodge_gauge_latch then
                        dodge_gauge_latch = false
                        DC:Add("HideDodgeChanceGauge", 1, HideDodgeChanceGauge)
                    end
                end
                DC:Add("PollDodgeChance", 1, PollDodgeChance)
            end

            if O:get("buff", "showDodgeChanceGauge") then
                hook(PlayerStandard, "_start_action_zipline", function(...)
                    Run("_start_action_zipline", ...)
                    PollDodgeChance()
                end)
                hook(PlayerStandard, "_end_action_zipline", function(...)
                    Run("_end_action_zipline", ...)
                    PollDodgeChance()
                end)
                hook(PlayerStandard, "_start_action_ducking", function(...)
                    Run("_start_action_ducking", ...)
                    PollDodgeChance()
                end)
                hook(PlayerStandard, "_end_action_ducking", function(...)
                    Run("_end_action_ducking", ...)
                    PollDodgeChance()
                end)
            end

            --/////////////////////////////////--
            --//  Critical Hit Chance Gauge  //--
            --/////////////////////////////////--
            local critical_gauge_text_tbl = {{ [1] = L("_buff_critical_chance_gauge") }, { [2] = clGood }}
            local critical_gauge_previous = 0
            local critical_gauge_latch = nil
            local DoNotTrackCriticalChanceGauge = not O:get("buff", "showCriticalChanceGauge")
            local function HideCriticalChanceGauge()
                local playermanager = managers.player
                if playermanager == nil or playermanager:critical_hit_chance() > 0 then
                    return
                end

                me:RemoveBuff("CriticalChanceGauge")
            end

            PollCriticalChance = function()
                if DoNotTrackCriticalChanceGauge then
                    return
                end

                if not me then
                    DC:Add("PollCriticalChance", 1, PollCriticalChance)
                    return
                end

                local playermanager = managers.player

                if playermanager == nil then
                    return
                end

                local chance = playermanager:critical_hit_chance()
                -- The latter check ensures that any increases in chance are always permitted to be displayed this tick (otherwise it
                -- will only be added on the following tick, one second later)
                if critical_gauge_previous > 0 or critical_gauge_previous < chance then
                    local text = nil
                    -- The buff title must not be specified for the 'Vanilla' style when et is 1
                    if buff_style ~= 2 then
                        -- Recycling tables to prevent memory wastage
                        text = critical_gauge_text_tbl
                        text[2][1] = string_format(" %s%%", tostring(_.f(chance * 100, 1)))
                    else
                        text = string_format("%s%%", tostring(_.f(chance * 100, 1)))
                    end
                    me:Buff3({
                        key = "CriticalChanceGauge",
                        good = true,
                        icon = U100SkillIcons,
                        iconRect = {8, 12 * 80, 64, 64},
                        text = text,
                        st = buff_style == 2 and chance or 1 - chance,
                        et = 1
                    })
                    critical_gauge_latch = true
                end
                critical_gauge_previous = chance
                -- Allow the player one second to visually confirm that their critical chance has been reduced to 0 before hiding the
                -- gauge
                if chance <= 0 and critical_gauge_latch then
                    critical_gauge_latch = false
                    DC:Add("HideCriticalChanceGauge", 1, HideCriticalChanceGauge)
                end
                DC:Add("PollCriticalChance", 1, PollCriticalChance)
            end

            if buffO.showCriticalChanceGauge then
                hook(PlayerManager, "add_to_crit_mul", function(...)
                    Run("add_to_crit_mul", ...)
                    PollCriticalChance()
                end)
                hook(PlayerManager, "sub_from_crit_mul", function(...)
                    Run("sub_from_crit_mul", ...)
                    PollCriticalChance()
                end)
            end

            --/////////////////////////--
            --//  Forced Friendship  //--
            --/////////////////////////--
            if buffO.showForcedFriendshipStack then
                local forced_friendship_text_tbl = {{ [1] = L("_buff_forced_friendship_stack") }, { [2] = clGood }}
                local function UpdateForcedFriendshipStack(hostage_headcount)
                    local each = managers.player:team_upgrade_value("damage", "hostage_absorption", 0)
                    local current = each * (hostage_headcount or 10)
                    local limit = each * (tweak_data.upgrades.values.team.damage.hostage_absorption_limit or 8)
                    if current > limit then
                        current = limit
                    end
                    local ratio = current / limit
                    local text = nil
                    -- The buff title must not be specified for the 'Vanilla' style when et is 1
                    if buff_style ~= 2 then
                        -- Recycling tables to prevent memory wastage since this code runs frequently
                        text = forced_friendship_text_tbl
                        if buffO.showForcedFriendshipPercentage then
                            text[2][1] = string_format(" %s%%", tostring(_.f(ratio * 100, 1)))
                        else
                            text[2][1] = string_format(" %s", tostring(_.f(current * 10, 2)))
                        end
                    else
                        if buffO.showForcedFriendshipPercentage then
                            text = string_format("%s%%", tostring(_.f(ratio * 100, 1)))
                        else
                            text = tostring(_.f(current * 10, 2))
                        end
                    end
                    if ratio > 0 then
                        me:Buff3({
                            key = "ForcedFriendshipStack",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {(4 * 80) + 8, (7 * 80) + 8, 64, 64},
                            text = text,
                            st = buff_style == 2 and ratio or 1 - ratio,
                            et = 1
                        })
                    else
                        me:RemoveBuff("ForcedFriendshipStack")
                    end
                end
                hook(GroupAIStateBase, "sync_hostage_headcount", function(self, ...)
                    Run("sync_hostage_headcount", self, ...)
                    if not managers.player:has_team_category_upgrade("damage", "hostage_absorption") then
                        return
                    end
                    UpdateForcedFriendshipStack(self._hostage_headcount)
                end)
            end

            --///////////////--
            --//  Grinder  //--
            --///////////////--
            if buffO.showGrinderStackCooldown then
                hook(PlayerManager, "_check_damage_to_hot", function(self, t, unit, damage_info, ...)
                    local previouscooldown = self._next_allowed_doh_t or 0
                    Run("_check_damage_to_hot", self, t, unit, damage_info, ...)
                    if not self._next_allowed_doh_t or not self:has_category_upgrade("player", "damage_to_hot") then
                        return
                    end
                    if self._next_allowed_doh_t > previouscooldown then
                        me:Buff3({
                            key = "GrinderStackCooldown",
                            good = false,
                            icon = DeckIcons,
                            iconRect = {5 * 64, 6 * 64, 64, 64},
                            text = L("_buff_cooldown"),
                            t = self._next_allowed_doh_t - t
                        })
                    end
                end)
            end
            if buffO.showGrinderRegenPeriod then
                hook(PlayerDamage, "add_damage_to_hot", function(self, ...)
                    if self:got_max_doh_stacks() or self:need_revive() or self:dead() or self._check_berserker_done then
                        return Run("add_damage_to_hot", self, ...)
                    end
                    Run("add_damage_to_hot", self, ...)

                    local stack = self._damage_to_hot_stack
                    local last_entry = #stack
                    if last_entry < 1 then
                        return
                    end
                    last_entry = stack[last_entry]
                    --local duration = last_entry.ticks_left * (self._doh_data.tick_time or 1)

                    local playertime = managers.player:player_timer():time()
                    local buff = me.buffs.GrinderRegenPeriod
                    if not buff or buff.dying then
                        me:Buff3({
                            key = "GrinderRegenPeriod",
                            good = true,
                            icon = DeckIcons,
                            iconRect = {5 * 64, 6 * 64, 64, 64},
                            text = L("_buff_regen"),
                            st = playertime,
                            et = playertime + last_entry.ticks_left * (self._doh_data.tick_time or 1)
                        })
                    else
                        -- Don't re-create the buff since it already exists, just extend it
                        buff.data.st = playertime
                        buff.data.et = playertime + last_entry.ticks_left * (self._doh_data.tick_time or 1)
                    end
                end)
            end

            --/////////////////--
            --//  Dire Need  //--
            --/////////////////--
            if buffO.showDireNeedDuration then
                local next_dire_need_poll = 0
                hook(PlayerDamage, "update*", function(self, unit, t, dt, ...)
                    Run("update*", self, unit, t, dt, ...)
                    if t >= next_dire_need_poll and self._dire_need then
                        local buff = me.buffs.DireNeedDuration
                        if buff and not buff.dying and not self:is_regenerating_armor() then
                            local extension = managers.player:upgrade_value("player", "armor_depleted_stagger_shot", 0)
                            if extension > 0 and not me.__DireNeedTimerInitiated then
                                extension = t + extension
                                me.__DireNeedTimerInitiated = true
                                -- HACK: OCD cure - don't you dare blink back defiantly at me, sonny!
                                buff.data.st = t
                                buff.data.et = extension
                                me:Buff3({
                                    key = "DireNeedDuration",
                                    good = true,
                                    icon = U100SkillIcons,
                                    iconRect = {(10 * 80) + 8, (8 * 80) + 8, 64, 64},
                                    text = L("_buff_dire_need_duration"),
                                    st = t,
                                    et = extension
                                })
                            end
                        end

                        -- Poll 4 times every second. This is far less precise than the actual coroutine that implements the Dire Need skill, but
                        -- it seems to provide reasonably accurate timers (polling every frame just for this buff timer feels really wasteful)
                        next_dire_need_poll = t + DireNeedResolution
                    end
                end)
            end

            --////////////////////////////////////////////////--
            --//  Dire Need / Unseen Strike / Lock 'n Load  //--
            --////////////////////////////////////////////////--
            local dire_need_text_tbl = {{ [1] = L("_buff_dire_need_duration") }, { [1] = "" }}
            local DoNotTrackDireNeedDuration = not O:get("buff", "showDireNeedDuration")
            local DoNotTrackUnseenStrikeDamageAvoidanceDuration = not O:get("buff", "showUnseenStrikeDamageAvoidanceDuration")
            hook(PlayerManager, "send_message", function(self, message, uid, param1, param2, ...)
                Run("send_message", self, message, uid, param1, param2, ...)

                if self:local_player() == nil then
                    return
                end

                local Message = _G.Message

                -- Note: Message.OnEnemyKilled will /never/ be sent to this function; use PlayerManager:on_killshot() instead

                if message == Message.SetWeaponStagger then
                    if DoNotTrackDireNeedDuration or not self:has_category_upgrade("player", "armor_depleted_stagger_shot") then
                        return
                    end

                    me.__DireNeedTimerInitiated = false
                    if param1 then
                        local text = nil
                        -- The buff title must not be specified for the 'Vanilla' style when et is 1
                        if buff_style ~= 2 then
                            -- Recycling tables to prevent memory wastage
                            text = dire_need_text_tbl
                        else
                            text = L("_buff_active")
                        end
                        me:Buff3({
                            key = "DireNeedDuration",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {(10 * 80) + 8, (8 * 80) + 8, 64, 64},
                            text = text,
                            st = buff_style == 2 and 1 or 0,
                            et = 1
                        })
                    else
                        me:RemoveBuff("DireNeedDuration")
                    end
                elseif message == Message.OnPlayerDamage then
                    if self._unseen_strike then
                        --me:RemoveBuff("UnseenStrikeCriticalBoostDuration")

                        -- FFS, STOP FUCKING IMPLEMENTING SKILLS ACTIVATION AND DEACTIVATION IN COROUTINES ALREADY, OVK. NO IT'S NOT FUNNY
                        -- DAMMIT
                        DC:Add("TriggerCritPoll", 0.05, PollCriticalChance)

                        if DoNotTrackUnseenStrikeDamageAvoidanceDuration then
                            return
                        end

                        -- Note: PlayerManager:upgrade_value() always returns a number, even if a nil fallback is specified (due to
                        -- 'return default or 0')
                        local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0)
                        if data == 0 or self:has_activate_temporary_upgrade("temporary", "unseen_strike") then
                            return
                        end

                        -- This gets called very frequently if the player is taking heavy fire, which causes the buff to flicker
                        local buff = me.buffs.UnseenStrikeDamageAvoidanceDuration
                        if not buff or buff.dying then
                            me:Buff3({
                                key = "UnseenStrikeDamageAvoidanceDuration",
                                good = false,
                                icon = U100SkillIcons,
                                iconRect = {(10 * 80) + 8, (11 * 80) + 8, 64, 64},
                                text = L("_buff_unseen_strike_damage_avoidance_duration"),
                                t = data.min_time
                            })
                        else
                            buff:Extend(data.min_time)
                        end

                        -- Colorize the buff for the 'Vanilla' style since it does not permit any additional text to help distinguish the
                        -- two distinct phases of the skill
                        if buff_style == 2 then
                            local buff = me.buffs.UnseenStrikeDamageAvoidanceDuration
                            if buff then
                                if not buff.created then
                                    buff:_make()
                                end
                                local color = clBad or Color(1, 0.84, 0)
                                if alive(buff.bmp) then
                                    buff.bmp:set_color(color)
                                end
                                if alive(buff.bg) then
                                    local children = buff.bg:children()
                                    if children ~= nil then
                                        for __, panel in ipairs(children) do
                                            if alive(panel) and panel.type_name == "Bitmap" then
                                                panel:set_color(color)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                elseif message == Message.OnSwitchWeapon then
                    DC:Remove("TriggerLockAndLoadRepoll")
                    me:RemoveBuff("LockAndLoadReloadBoost")
                end
            end)

            --//////////////////////////////--
            --//  Muscle / Hostage Taker  //--
            --//////////////////////////////--
            if buffO.showHostageTakerMuscleRegen then
                local hostage_taker_icon_rect = {2 * 64, 10 * 64, 64, 64}
                local muscle_icon_rect = {4 * 64, 64, 64, 64}
                hook(PlayerDamage, "_upd_health_regen", function(self, t, dt, ...)
                    local previoustimer = self._health_regen_update_timer or 0

                    Run("_upd_health_regen", self, t, dt, ...)

                    if not self._health_regen_update_timer or self._health_regen_update_timer <= previoustimer then
                        return
                    end

                    local playermanager = managers.player
                    -- Yes, PlayerManager:health_regen() appears to be a rather expensive function to call, but the saving grace here is
                    -- that this code only runs when self._health_regen_update_timer reaches 0, which is at most once every few seconds
                    if playermanager:health_regen() <= 0 then
                        -- OVK changed the function in U135 to no longer check that PlayerManager:health_regen() returns > 0, no idea
                        -- exactly why they decided to make that change, but the end result is that self._health_regen_update_timer now
                        -- continually ticks after the player takes health damage for the first time (similar to Anarchist) for as long
                        -- as their health is not full. If the Frenzy skill is active, this means that the ticking is perpetual since
                        -- they effectively take health damage immediately upon spawning, and can never heal back up to 100% (note that
                        -- this behavior has not changed in U135)
                        return
                    end

                    -- Determine which icon to use. This is fine to do here since this code only runs once every few seconds (thanks to the
                    -- above checks)
                    local icon, iconRect
                    local hostage_taker = playermanager:has_category_upgrade("player", "hostage_health_regen_addend")
                    if hostage_taker then
                        -- Sure the player has the skill, but are there actually any hostages around to provide that regen benefit?
                        local state = managers.groupai and managers.groupai:state()
                        hostage_taker = ((state and state:hostage_count() or 0) + (playermanager:num_local_minions() or 0) > 0)
                    end
                    if hostage_taker then
                        icon = SkillIcons
                        iconRect = hostage_taker_icon_rect
                    else
                        icon = DeckIcons
                        iconRect = muscle_icon_rect
                    end

                    local endtime = t + self._health_regen_update_timer
                    -- Don't flicker
                    local buff = me.buffs.HostageTakerMuscleRegen
                    if buff and not buff.dying and buff.data.icon == icon then
                        buff.data.st = t
                        buff.data.et = endtime
                    end
                    me:Buff3({
                        key = "HostageTakerMuscleRegen",
                        good = true,
                        icon = icon,
                        iconRect = iconRect,
                        text = L("_buff_regen"),
                        st = t,
                        et = endtime
                    })
                end)
            end

            --//////////////--
            --//  Maniac  //--
            --//////////////--
            local next_maniac_stack_poll = 0
            local maniac_stack_text_tbl = {{ [1] = L("_buff_maniac_accumulated_stack") }, { [2] = clGood }}
            local ShowManiacStackTicks = O:get("buff", "showManiacStackTicks")
            local ShowManiacDecayTicks = O:get("buff", "showManiacDecayTicks")
            local ShowManiacAccumulatedStacks = O:get("buff", "showManiacAccumulatedStacks")
            hook(PlayerManager, "_update_damage_dealt", function(self, t, dt, ...)
                local previousstack = self._damage_dealt_to_cops_t or 0
                local previousdecay = self._damage_dealt_to_cops_decay_t or 0

                Run("_update_damage_dealt", self, t, dt, ...)

                if not self:has_category_upgrade("player", "cocaine_stacking") or self:local_player() == nil or self._damage_dealt_to_cops_t == nil or self._damage_dealt_to_cops_decay_t == nil then
                    return
                end

                -- t here is identical to the timestamp returned by PlayerManager:player_timer():time() so do not bother calling the latter

                if t >= previousstack and ShowManiacStackTicks then
                    -- Don't flicker
                    local buff = me.buffs.ManiacStackTicks
                    if buff and not buff.dying then
                        buff.data.st = t
                        buff.data.et = self._damage_dealt_to_cops_t
                    end
                    me:Buff3({
                        key = "ManiacStackTicks",
                        good = true,
                        icon = ManiacDeckIcons,
                        iconRect = {0, 0, 64, 64},
                        text = L("_buff_maniac_stack_tick"),
                        st = t,
                        et = self._damage_dealt_to_cops_t
                    })
                end

                if t >= previousdecay and ShowManiacDecayTicks then
                    -- Don't flicker
                    local buff = me.buffs.ManiacDecayTicks
                    if buff and not buff.dying then
                        buff.data.st = t
                        buff.data.et = self._damage_dealt_to_cops_decay_t
                    end
                    me:Buff3({
                        key = "ManiacDecayTicks",
                        good = false,
                        icon = ManiacDeckIcons,
                        iconRect = {2 * 64, 0, 64, 64},
                        text = L("_buff_maniac_stack_decay"),
                        st = t,
                        et = self._damage_dealt_to_cops_decay_t
                    })
                end

                -- Poll accumulated hysteria stacks, but not every frame
                if t >= next_maniac_stack_poll then
                    if ShowManiacAccumulatedStacks then
                        local newstacks = (self._damage_dealt_to_cops or 0) * (tweak_data.gui.stats_present_multiplier or 10) * self:upgrade_value("player", "cocaine_stacking", 0)
                        local maxstacks = tweak_data.upgrades.max_cocaine_stacks_per_tick or 20
                        if newstacks > maxstacks then
                            newstacks = maxstacks
                        end
                        local ratio = newstacks / maxstacks
                        if ratio > 0 then
                            local text = nil
                            -- The buff title must not be specified for the 'Vanilla' style when et is 1
                            if buff_style ~= 2 then
                                -- Recycling tables to prevent memory wastage since this code runs frequently
                                text = maniac_stack_text_tbl
                                text[2][1] = string_format(" %s%%", tostring(_.f(ratio * 100, 1)))
                            else
                                text = string_format("%s%%", tostring(_.f(ratio * 100, 1)))
                            end
                            me:Buff3({
                                key = "ManiacAccumulatedStacks",
                                good = true,
                                icon = ManiacDeckIcons,
                                iconRect = {3 * 64, 0, 64, 64},
                                text = text,
                                st = buff_style == 2 and ratio or 1 - ratio,
                                et = 1
                            })
                        else
                            me:RemoveBuff("ManiacAccumulatedStacks")
                        end
                    end
                    next_maniac_stack_poll = t + ManiacAccumulatedStackResolution
                end
            end)

            --///////////////////--
            --//  Bulletstorm  //--
            --///////////////////--
            hook(PlayerManager, "add_to_temporary_property", function(self, name, time, ...)
                Run('add_to_temporary_property', self, name, time, ...)
                if name == "bullet_storm" then
                    local playertime = self:player_timer():time()
                    local buff = me.buffs.Bulletstorm
                    if not buff or buff.dying then
                        me:Buff4({
                            key = "Bulletstorm",
                            good = true,
                            icon = U100SkillIcons,
                            iconRect = {(4 * 80) + 8, (5 * 80) + 8, 64, 64},
                            text = L("_buff_bulletStormShort"),
                            st = playertime,
                            et = playertime + time
                        })
                    else
                        -- Don't re-create the buff since it already exists, just extend it
                        buff.data.st = playertime
                        buff.data.et = playertime + time
                    end
                end
            end)
            if buffO.showBulletstormPotential then
                local bulletstorm_state = {}
                -- Do not allow this table to prevent the currently tracked ammo bag from being garbage collected
                setmetatable(bulletstorm_state, {__mode = "v"})

                local bulletstorm_duration_text_tbl = {{ [1] = L("_buff_bulletstorm_potential") }, { [2] = clGood }}
                --local bulletstorm_duration_latch = nil

                -- Based on RaycastWeaponBase:add_ammo_from_bag()
                local function ComputeAmmoRestoreQuantity(weapon, available)
                    if not weapon or weapon:ammo_max() then
                        return 0
                    end
                    return math.min(1 - weapon:get_ammo_total() / weapon:get_ammo_max(), available)
                end

                local function PollBulletstormPotential()
                    local playermanager = managers.player

                    if playermanager == nil then
                        return
                    end

                    local playerunit = playermanager:local_player()
                    if not playerunit then
                        return
                    end

                    local active_ammo_bag = bulletstorm_state.active_ammo_bag
                    if not active_ammo_bag or not alive(active_ammo_bag._unit) or active_ammo_bag._empty or active_ammo_bag._ammo_amount <= 0 then
                        me:RemoveBuff("BulletstormPotential")
                        return
                    end

                    -- Based on AmmoBagBase:_take_ammo()
                    local inventory = playerunit:inventory()
                    if not inventory then
                        me:RemoveBuff("BulletstormPotential")
                        return
                    end

                    local taken = 0
                    local simulated_amount = active_ammo_bag._ammo_amount
                    for __, weapon in pairs(inventory:available_selections()) do
                        local took = active_ammo_bag:round_value(ComputeAmmoRestoreQuantity(weapon.unit:base(), simulated_amount))
                        taken = taken + took
                        simulated_amount = active_ammo_bag:round_value(simulated_amount - took)
                        if simulated_amount <= 0 then
                            break
                        end
                    end

                    local duration = active_ammo_bag._BULLET_STORM[active_ammo_bag._bullet_storm_level] * taken
                    local ratio = taken / 2
                    local text = nil
                    -- The buff title must not be specified for the 'Vanilla' style when et is 1
                    if buff_style ~= 2 then
                        -- Recycling tables to prevent memory wastage since this code runs frequently
                        text = bulletstorm_duration_text_tbl
                        text[2][1] = string_format(" %ss", tostring(_.f(duration, 2)))
                    else
                        text = string_format("%ss", tostring(_.f(duration, 2)))
                    end
                    me:Buff3({
                        key = "BulletstormPotential",
                        good = true,
                        icon = U100SkillIcons,
                        iconRect = {(4 * 80) + 8, (5 * 80) + 8, 64, 64},
                        text = text,
                        st = buff_style == 2 and ratio or 1 - ratio,
                        et = 1
                    })

                    DC:Add("PollBulletstormPotential", BulletstormPotentialResolution, PollBulletstormPotential)
                end

                hook(AmmoBagInteractionExt, "selected", function(self, player, ...)
                    if not self:can_select(player) then
                        return Run("selected", self, player, ...)
                    end

                    if not alive(self._unit) then
                        return Run("selected", self, player, ...)
                    end

                    local ammobag = self._unit:base()
                    if ammobag == nil or not ammobag._bullet_storm_level or ammobag._bullet_storm_level < 1 then
                        return Run("selected", self, player, ...)
                    end

                    bulletstorm_state.active_ammo_bag = ammobag

                    local result = Run("selected", self, player, ...)

                    PollBulletstormPotential()

                    return result
                end)

                hook(AmmoBagInteractionExt, "unselect", function(self, ...)
                    Run("unselect", self, ...)

                    bulletstorm_state.active_ammo_bag = nil

                    -- Do not remove the AdditionalPocoHudTrackers_PollBulletstormPotential delayed call here as doing so breaks polling when
                    -- switching from a basic ammo bag to a Bulletstorm-enabled one (assuming both are right next to each other, a la Safe House
                    -- layout)
                    me:RemoveBuff("BulletstormPotential")
                end)
            end

            --///////////////////--
            --//  Bloodthirst  //--
            --///////////////////--
            if buffO.showBloodthirstMeleeBoostGauge then
                local meele_boost_tweak = tweak_data.upgrades.values.player.melee_damage_stacking[1]
                if meele_boost_tweak then
                    local max_multiplier = meele_boost_tweak.max_multiplier
                    local bloodthirst_text_tbl = {{ [1] = L("_buff_bloodthirst_melee_boost") }, { [2] = clGood }}
                    local bloodthirst_max = false
                    hook(PlayerManager, "set_melee_dmg_multiplier", function(self, multiplier, ...)
                        Run("set_melee_dmg_multiplier", self, multiplier, ...)
                        if bloodthirst_max then
                            return -- Avoid doing expensive call below because the multiplier is full
                        end
                        local ratio = multiplier / max_multiplier
                        if ratio > 0.34 then
                            bloodthirst_max = ratio == 1
                            local text = nil
                            -- The buff title must not be specified for the 'Vanilla' style when et is 1
                            if buff_style ~= 2 then
                                -- Recycling tables to prevent memory wastage since this code runs frequently
                                text = bloodthirst_text_tbl
                                text[2][1] = string_format(" %s%%", tostring(_.f(multiplier * 100, 1)))
                            else
                                text = string_format("%s%%", tostring(_.f(multiplier * 100, 1)))
                            end
                            me:GaugeBuff3({
                                key = "BloodthirstMeleeBoostGauge",
                                good = true,
                                icon = U100SkillIcons,
                                iconRect = {(11 * 80) + 8, (6 * 80) + 8, 64, 64},
                                text = text,
                                st = buff_style == 2 and ratio or 1 - ratio
                            })
                        end
                    end)
                    hook(PlayerManager, "reset_melee_dmg_multiplier", function(...)
                        Run("reset_melee_dmg_multiplier", ...)
                        me:RemoveBuff("BloodthirstMeleeBoostGauge")
                        bloodthirst_max = false -- Reset the lock
                    end)
                end
            end

            --///////////////////--
            --//  Sixth Sense  //--
            --///////////////////--
            -- Assume default, recomputed after spawn
            local computed_duration_civilian = 4.5
            local computed_duration_security = 13.5
            local target_resense_delay = tweak_data.player.omniscience.target_resense_t or 15
            local sense_latch = false
            local function ResetSxSnLatch()
                sense_latch = false
            end
            RecomputeContourDuration = function()
                local playermanager = managers.player
                local ContourExt = _G.ContourExt
                local tmp = ContourExt._types
                if tmp then
                    local multiplier = playermanager:upgrade_value("player", "mark_enemy_time_multiplier", 1)
                    local contour_type = playermanager:has_category_upgrade("player", "marked_enemy_extra_damage") and "mark_enemy_damage_bonus" or "mark_enemy"
                    tmp = tmp[contour_type]
                    if tmp then
                        computed_duration_civilian = tmp.fadeout and (tmp.fadeout * multiplier) or 4.5
                        computed_duration_security = tmp.fadeout_silent and (tmp.fadeout_silent * multiplier) or 13.5
                    end
                end
            end

            local sxsn_highlighted_text_tbl = {{[1] = L("_buff_sixth_sense_highlighted")}, { [2] = clGood }}
            local DoNotTrackSixthSenseInitial = not O:get("buff", "showSixthSenseInitial")
            local TrackSixthSenseSubsequent = O:get("buff", "showSixthSenseSubsequent")
            local TrackSixthSenseHighlighted = O:get("buff", "showSixthSenseHighlighted")
            hook(PlayerStandard, "_update_omniscience", function(self, t, dt, ...)
                local previoustime = self._state_data.omniscience_t

                Run("_update_omniscience", self, t, dt, ...)

                if previoustime and self._state_data.omniscience_t == nil then
                    -- The game forbade the skill, kill the buffs (this does not run every frame due to the combined check in the above
                    -- conditional clause)
                    me:RemoveBuff("SixthSenseInitial")
                    me:RemoveBuff("SixthSenseSubsequent")
                    me:RemoveBuff("SixthSenseHighlighted")
                    ResetSxSnLatch()
                    DC:Remove("ResetSxSnLatch")
                    return
                end

                -- Player does not have the skill or alarm has been raised
                if previoustime == nil and self._state_data.omniscience_t == nil then
                    return
                end

                if previoustime == nil and self._state_data.omniscience_t then
                    -- Delay prior to initial poll
                    if DoNotTrackSixthSenseInitial then
                        return
                    end

                    me:Buff3({
                        key = "SixthSenseInitial",
                        good = false,
                        icon = SkillIcons,
                        iconRect = {6 * 64, 10 * 64, 64, 64},
                        text = L("_buff_sixth_sense_initial"),
                        st = t,
                        et = self._state_data.omniscience_t
                    })
                elseif previoustime ~= self._state_data.omniscience_t then
                    -- Subsequent poll (called once every second)
                    local detected = 0
                    local tmp = self._state_data.omniscience_units_detected
                    local civilians = managers.enemy:all_civilians() or {}
                    if tmp ~= nil then
                        local begin_t = 0
                        local end_t = 0
                        for key, data in pairs(tmp) do
                            -- Since only expiry times are stored, work backwards to figure out when the start time was, and calculate the
                            -- time the highlight will expire
                            begin_t = data - target_resense_delay
                            end_t = begin_t + (civilians[key] and computed_duration_civilian or computed_duration_security)
                            if t >= begin_t and t < end_t then
                                detected = detected + 1
                            end
                        end
                    end

                    if detected > 0 and TrackSixthSenseSubsequent and not sense_latch then
                        sense_latch = true
                        DC:Add("ResetSxSnLatch", target_resense_delay, ResetSxSnLatch)

                        me:Buff3({
                            key = "SixthSenseSubsequent",
                            good = false,
                            icon = SkillIcons,
                            iconRect = {6 * 64, 10 * 64, 64, 64},
                            text = L("_buff_sixth_sense_subsequent"),
                            st = t,
                            et = t + target_resense_delay
                        })
                    end

                    if TrackSixthSenseHighlighted then
                        local text = nil
                        local ratio = detected > 0 and 1 or 0
                        -- The buff title must not be specified for the 'Vanilla' style when et is 1
                        if buff_style ~= 2 then
                            -- Recycling tables to prevent memory wastage since this code runs frequently
                            text = sxsn_highlighted_text_tbl
                            text[2][1] = string_format(" %s", tostring(detected))
                        else
                            text = string_format("%s", tostring(detected))
                        end
                        me:Buff3({
                            key = "SixthSenseHighlighted",
                            good = true,
                            icon = SkillIcons,
                            iconRect = {6 * 64, 10 * 64, 64, 64},
                            text = text,
                            st = buff_style == 2 and ratio or 1 - ratio,
                            et = 1
                        })
                    end
                end
            end)

            --//////////////////////////////////--
            --//  Bullseye / Ammo Efficiency  //--
            --//////////////////////////////////--
            local TrackBullseye = O:get("buff", "showBullseyeCooldown")
            local TrackHeadGames = O:get("buff", "showCopycatHeadGamesCooldown")
            local TrackAmmoEfficiencyDuration = O:get("buff", "showAmmoEfficiencyDuration")
            local TrackAmmoEfficiencyStack = O:get("buff", "showAmmoEfficiencyStack")
            local ammo_efficiency_counter = 0
            local ammo_efficiency_text_tbl = {{ [1] = L("_buff_ammo_efficiency_stack") }, { [2] = clGood }}
            local function ResetAmmoEfficiencyStack()
                ammo_efficiency_counter = 0
                me:RemoveBuff("AmmoEfficiencyStack")
            end
            hook(PlayerManager, "on_headshot_dealt", function(self, ...)
                local previouscooldown = self._on_headshot_dealt_t or 0
                local isgametracking = self._coroutine_mgr:is_running("ammo_efficiency")

                Run("on_headshot_dealt", self, ...)

                -- Need to do some additional gymnastics here because there apparently exists a skew between Application:time() and
                -- PlayerManager:player_timer():time(). Not basing the buff timer on the latter causes the timer to seem to expire
                -- prematurely (i.e. expiring even when the game's cooldown is still in effect), which defeats its very purpose as a timer
                local playertime = self:player_timer():time()

                if self:has_category_upgrade("player", "headshot_regen_armor_bonus") and TrackBullseye then
                    local t = Application:time()
                    if t >= previouscooldown then
                        me:Buff3({
                            key = "BullseyeCooldown",
                            good = false,
                            icon = SkillIcons,
                            iconRect = {6 * 64, 11 * 64, 64, 64},
                            text = "",
                            st = playertime,
                            et = playertime + (self._on_headshot_dealt_t - t)
                        })
                    end
                end

                if self:has_category_upgrade("player", "headshot_regen_health_bonus") and TrackHeadGames then
                    local t = Application:time()
                    if t >= previouscooldown then
                        me:Buff3({
                            key = "CopycatHeadGamesCooldown",
                            good = false,
                            icon = CopycatDeckIcons,
                            iconRect = {64, 0, 64, 64},
                            text = "",
                            st = playertime,
                            et = playertime + (self._on_headshot_dealt_t - t)
                        })
                    end
                end

                -- Derived from PlayerManager:_on_enter_ammo_efficiency_event()
                if self._ammo_efficiency ~= nil and (TrackAmmoEfficiencyDuration or TrackAmmoEfficiencyStack) then
                    local weaponunit = self:equipped_weapon_unit()
                    if weaponunit then
                        local weaponunitbase = weaponunit:base()
                        if weaponunitbase and weaponunitbase:fire_mode() == "single" and weaponunitbase:is_category("smg", "assault_rifle", "snp") then
                            ammo_efficiency_counter = (ammo_efficiency_counter or 0) + 1

                            if TrackAmmoEfficiencyDuration then
                                -- Only issue this if it is not already active (since the skill requires multiple hits)
        --						local buff = me.buffs.AmmoEfficiencyDuration
        --						if not buff then
                                if not isgametracking then
                                    me:Buff3({
                                        key = "AmmoEfficiencyDuration",
                                        good = true,
                                        icon = U100SkillIcons,
                                        iconRect = {(8 * 80) + 8, (4 * 80) + 12, 64, 64},
                                        text = L("_buff_ammo_efficiency_duration"),
                                        t = self._ammo_efficiency.time or 6
                                    })
                                end
                            end

                            if TrackAmmoEfficiencyStack then
                                local text = nil
                                -- The buff title must not be specified for the 'Vanilla' style when et is 1
                                if buff_style ~= 2 then
                                    -- Recycling tables to prevent memory wastage since this code runs frequently
                                    text = ammo_efficiency_text_tbl
                                    text[2][1] = string_format(" %s", tostring(ammo_efficiency_counter))
                                else
                                    text = tostring(ammo_efficiency_counter)
                                end
                                local maxheadshots = (self._ammo_efficiency.headshots or 3)
                                local ratio = ammo_efficiency_counter / maxheadshots
                                if ratio > 1 then
                                    -- Probably never, but just in case
                                    ratio = 1
                                end
                                me:GaugeBuff3({
                                    key = "AmmoEfficiencyStack",
                                    good = true,
                                    icon = U100SkillIcons,
                                    iconRect = {(8 * 80) + 8, (4 * 80) + 12, 64, 64},
                                    text = text,
                                    st = buff_style == 2 and ratio or 1 - ratio
                                })
                                -- Add only one delayed callback, not two or three
                                if not isgametracking then
                                    DC:Add("ResetAmmoEfficiencyStack", (self._ammo_efficiency.time or 6), ResetAmmoEfficiencyStack)
                                end
                            end
                        else
                            me:RemoveBuff("AmmoEfficiencyDuration")
                            ResetAmmoEfficiencyStack()
                        end
                    end
                end
            end)

            --///////////////////////--
            --//  Ammo Efficiency  //--
            --///////////////////////--
            if TrackAmmoEfficiencyDuration then
                -- This function is currently (i.e. as at U104.1) only called by PlayerAction.AmmoEfficiency.Function(). Should this exclusivity
                -- change in future, the Ammo Efficiency tracker will likely need to be rethought to prevent the occurrence of false positives
                hook(PlayerManager, "on_ammo_increase", function(self, ...)
                    Run("on_ammo_increase", self, ...)
                    if self._ammo_efficiency == nil then
                        return
                    end
                    me:RemoveBuff("AmmoEfficiencyDuration")
                    -- Delay the buff's removal to allow it to be updated to 3 (or 2 if aced) prior to removal (otherwise it will fade away as an
                    -- incomplete buff), but reset the counter immediately to prevent it from exceeding the limit (e.g. scoring a double
                    -- headshot with a sniper rifle for the final shot). This allows the player enough time to confirm that it has been procured
                    ammo_efficiency_counter = 0
                    DC:Add("ResetAmmoEfficiencyStack", 1.5, ResetAmmoEfficiencyStack)
                end)
            end

            --///////////////////--
            --//  Bloodthirst  //--
            --///////////////////--
            if buffO.showBloodthirstReloadBoostDuration then
                hook(PlayerManager, "_on_enemy_killed_bloodthirst", function(self, equipped_unit, variant, killed_unit, ...)
                    Run("_on_enemy_killed_bloodthirst", self, equipped_unit, variant, killed_unit, ...)
                    if variant == "melee" and self:has_active_temporary_property("bloodthirst_reload_speed") then
                        local data = self:upgrade_value("player", "melee_kill_increase_reload_speed", 0)
                        if data == 0 then
                            return
                        end
                        local buff = me.buffs.BloodthirstReloadBoostDuration
                        if not buff or buff.dying then
                            me:Buff3({
                                key = "BloodthirstReloadBoostDuration",
                                good = true,
                                icon = U100SkillIcons,
                                iconRect = {(11 * 80) + 8, (6 * 80) + 8, 64, 64},
                                text = L("_buff_bloodthirst_reload_boost"),
                                t = data[2]
                            })
                        else
                            buff:Extend(data[2])
                        end
                    end
                end)
            end

            --////////////////////--
            --//  Lock 'n Load  //--
            --////////////////////--
            hook(PlayerManager, "remove_property", function(self, name, ...)
                Run("remove_property", self, name, ...)
                if name == "shock_and_awe_reload_multiplier" and not self._coroutine_mgr:is_running("automatic_faster_reload") then
                    DC:Remove("TriggerLockAndLoadRepoll")
                    me:RemoveBuff("LockAndLoadReloadBoost")
                end
            end)

            --////////////////////////////////--
            --//  Sociopath / Lock 'n Load  //--
            --////////////////////////////////--
            local lockandload_boost_text_tbl = {{ [1] = L("_buff_lock_and_load_reload_boost") }, { [2] = clGood }}
            local TrackLockAndLoadReloadBoost = O:get("buff", "showLockAndLoadReloadBoost")
            local DoNotTrackLockAndLoadReloadBoost = not TrackLockAndLoadReloadBoost
            local function PollLockAndLoad()
                if DoNotTrackLockAndLoadReloadBoost then
                    return
                end

                local playermanager = managers.player
                if not playermanager._coroutine_mgr:is_running("automatic_faster_reload") then
                    return
                end

                -- Note: PlayerManager:upgrade_value() always returns a number, even if a nil fallback is specified (due to
                -- 'return default or 0')
                local data = playermanager:upgrade_value("player", "automatic_faster_reload", 0)
                if data ~= 0 then
                    local weaponunit = playermanager:equipped_weapon_unit()
                    if weaponunit then
                        local weaponunitbase = weaponunit:base()
                        if weaponunitbase then
                            local max_reload_increase = data.max_reload_increase or 2
                            local min_reload_increase = data.min_reload_increase or 1.4
                            local min_bullets = data.min_bullets or 20
                            local penalty = data.penalty or 0.98
                            -- From PlayerAction.ShockAndAwe.Function()
                            local reload_multiplier = max_reload_increase
                            local ammo = weaponunitbase:get_ammo_max_per_clip()
                            if playermanager:has_category_upgrade("player", "automatic_mag_increase") and weaponunitbase:is_category("smg", "assault_rifle", "lmg") then
                                ammo = ammo - playermanager:upgrade_value("player", "automatic_mag_increase", 0)
                            end
                            if min_bullets < ammo then
                                local num_bullets = ammo - min_bullets
                                local math_max = math.max
                                for i = 1, num_bullets do
                                    reload_multiplier = math_max(min_reload_increase, reload_multiplier * penalty)
                                end
                            end
                            local ratio = (reload_multiplier - min_reload_increase) / (max_reload_increase - min_reload_increase)
                            if ratio > 1 then
                                ratio = 1
                            end
                            local text = nil
                            -- The buff title must not be specified for the 'Vanilla' style when et is 1
                            if buff_style ~= 2 then
                                -- Recycling tables to prevent memory wastage
                                text = lockandload_boost_text_tbl
                                text[2][1] = string_format(" %sx", tostring(_.f(reload_multiplier, 3)))
                            else
                                text = string_format("%sx", tostring(_.f(reload_multiplier, 3)))
                            end
                            me:Buff3({
                                key = "LockAndLoadReloadBoost",
                                good = true,
                                icon = U100SkillIcons,
                                iconRect = {(10 * 80) + 8, 10, 64, 64},
                                text = text,
                                st = buff_style == 2 and ratio or 1 - ratio,
                                et = 1
                            })
                        end
                    end
                    DC:Add("TriggerLockAndLoadRepoll", LockAndLoadResolution, PollLockAndLoad)
                end
            end

            local sociopath_tension_icon_rect = {0, 5 * 64, 64, 64}
            local sociopath_cleanhit_icon_rect = {64, 5 * 64, 64, 64}
            local sociopath_overdose_icon_rect = {2 * 64, 5 * 64, 64, 64}
            local sociopath_showdown_icon_rect = {3 * 64, 5 * 64, 64, 64}
            -- Remapping Overdose's icon to Tension's since the icon is very similar to the domination cooldown's icon and leads to confusion
            sociopath_overdose_icon_rect = sociopath_tension_icon_rect
            local TrackSociopathCooldowns = O:get("buff", "showSociopathCooldowns")
            local close_combat_distance = tweak_data.upgrades.close_combat_distance or 1800
            local close_combat_distance_sq = close_combat_distance * close_combat_distance
            hook(PlayerManager, "on_killshot", function(self, killed_unit, variant, headshot, ...)
                local playerunit = self:player_unit()
                if not playerunit or not killed_unit or CopDamage.is_civilian(killed_unit:base()._tweak_table) then
                    return Run("on_killshot", self, killed_unit, variant, headshot, ...)
                end

                --local isgametrackinglockandload_pre = self._coroutine_mgr:is_running("automatic_faster_reload")
                local previouskillshot = self._on_killshot_t
                local hasmaxarmor = playerunit:character_damage()
                hasmaxarmor = hasmaxarmor and hasmaxarmor:armor_ratio() >= 1

                Run("on_killshot", self, killed_unit, variant, headshot, ...)

                local isgametrackinglockandload_post = self._coroutine_mgr:is_running("automatic_faster_reload")

                if TrackSociopathCooldowns then
                    local t = Application:time()
                    if (not previouskillshot or t >= previouskillshot) and self._on_killshot_t then
                        local playertime = self:player_timer():time()
                        local hastension = self:has_category_upgrade("player", "killshot_regen_armor_bonus")
                        local hascleanhit = variant == "melee" and self:has_category_upgrade("player", "melee_kill_life_leech")
                        local hasoverdose = self:has_category_upgrade("player", "killshot_close_regen_armor_bonus")
                        local hasshowdown = self:has_category_upgrade("player", "killshot_close_panic_chance")
                        local blocktension = false

                        -- Priorities (1 being highest):
                        -- 1) clean hit (since it is the least common)
                        -- 2) overdose (less common)
                        -- 3) tension (common)
                        -- 4) showdown (little impact on survivability)

                        if hasmaxarmor then
                            hasoverdose = false
                            -- Switch to panic instead if the player owns it and their armor is already full
                            if hasshowdown then
                                blocktension = true
                            end
                        end

                        if hasoverdose or hasshowdown then
                            local dist_sq = mvector3.distance_sq(playerunit:movement():m_pos(), killed_unit:movement():m_pos())
                            if dist_sq > close_combat_distance_sq then
                                -- Does not qualify for the additional Overdose armor regen bonus nor Showdown panic chance
                                hasoverdose = false
                                hasshowdown = false
                            end
                        end

                        -- If there are no relevant icons but the player owns the Tension perk, undo its block so it will be selected
                        if hastension and not hascleanhit and not hasoverdose and not hasshowdown and blocktension then
                            blocktension = false
                        end

                        local icon = nil
                        local text = ""
                        if hascleanhit then
                            icon = sociopath_cleanhit_icon_rect
                            text = L("_buff_sociopath_clean_hit")
                        elseif hasoverdose then
                            icon = sociopath_overdose_icon_rect
                            text = L("_buff_sociopath_overdose")
                        elseif hastension and not blocktension then
                            icon = sociopath_tension_icon_rect
                            text = L("_buff_sociopath_tension")
                        elseif hasshowdown then
                            icon = sociopath_showdown_icon_rect
                            text = L("_buff_sociopath_showdown")
                        end

                        if icon then
                            me:Buff3({
                                key = "SociopathCooldowns",
                                good = false,
                                icon = DeckIcons,
                                iconRect = icon,
                                text = text,
                                st = playertime,
                                et = playertime + (self._on_killshot_t - t)
                            })
                        end
                    end
                end

                local haslockandloadace = self:has_category_upgrade("player", "automatic_faster_reload")
            --[[
                -- I'm refusing to even bother trying to track this very sloppily written skill until OVK themselves fix it to work the way
                -- it should. The following code is unfinished so enable it at your own risk
                if AdditionalPocoHudTrackers.Prefs.ShowLockAndLoadKills and haslockandloadace then
                    if isgametrackinglockandload_post then
                        local kills = nil
                        local maxkills = (self._SHOCK_AND_AWE_TARGET_KILLS or 2)

                        -- WTF, OVK - why are you abusing modulo (a.k.a. even-odd checking in this case) for this instead of using a proper
                        -- numeric check? This method is inaccurate AF
                        if self._num_kills % maxkills == 0 and isgametrackinglockandload_pre then
                            kills = 2
                        else
                            kills = 1
                        end

                        local ratio = kills / maxkills
                        if ratio > 1 then
                            ratio = 1
                        end
                        local style = PocoHud3Class.O:get("buff", "style")
                        local text = nil
                        -- The buff title must not be specified for the 'Vanilla' style when et is 1
                        if style ~= 2 then
                            bloodthirst_color = bloodthirst_color or PocoHud3Class.O:get("root", "colorPositive") or Color(0.6, 0.8, 0.2)
                            -- Recycling tables to prevent memory wastage since this code runs frequently
                            text = bloodthirst_text_tbl
                            --
                            Text:
                            Kills
                            击杀
                            --
                            text[1][1] = tostring(AdditionalPocoHudTrackers.TrackerNames.LockAndLoadKills)
                            text[2][1] = string_format(" %s", tostring(kills))
                            text[2][2] = bloodthirst_color
                        else
                            text = string_format("%s", tostring(kills))
                        end
                        AdditionalPocoHudTrackers:Buff(PocoHud3, PocoHud3Class, {
                            key = "LockAndLoadKills",
                            good = true,
                            icon = AdditionalPocoHudTrackers.U100SkillIcons,
                            iconRect = {(10 * 80) + 8, 10, 64, 64},
                            text = text,
                            st = style == 2 and ratio or 1 - ratio,
                            et = 1
                        })
                    end
                end
            ]]
                if TrackLockAndLoadReloadBoost and haslockandloadace and isgametrackinglockandload_post then
                    PollLockAndLoad()
                end
            end)
            -- TODO:
            -- FIX ME
            -- This is ugly
            if buffO.showDodgeChanceGauge then
                hook(PlayerStandard, 'set_running', function(...)
                    local self, running = unpack{...}
                    if not self.RUN_AND_SHOOT and running then
                        _matchStance(true)
                    end
                    Run('set_running', ...)
                    -- Sprinting continues for a short period after PlayerStandard:_end_action_running() is called, so PlayerStandard:set_running()
                    -- is more reliable for tracking
                    PollDodgeChance()
                end)
            else
                hook(PlayerStandard, 'set_running', function(...)
                    local self, running = unpack{...}
                    if not self.RUN_AND_SHOOT and running then
                        _matchStance(true)
                    end
                    Run('set_running', ...)
                end)
            end

            hook(PlayerStandard, '_do_action_intimidate', function(self, t, interact_type, sound_name, skip_alert)
                local r = Run('_do_action_intimidate', self, t, interact_type, sound_name, skip_alert)
                local et =_.g('managers.player:player_unit():movement()._current_state._intimidate_t')

                if et and interact_type then
                    et = et + tweak_data.player.movement_state.interaction_delay
                    me:Buff4({
                        key='interact', good=false,
                        icon=SkillIcons,
                        iconRect = {2*64, 8*64, 64, 64},
                        st=t, et=et
                    })
                    local boost = self._ext_movement:rally_skill_data() and self._ext_movement:rally_skill_data().morale_boost_delay_t
                    if boost and boost > t then
                        me:Buff4({
                            key='inspire',
                            good=false,
                            icon=SkillIcons,
                            iconRect = {4*64, 9*64, 64, 64},
                            st=t, et=boost
                        })
                    end
                end
                return r
            end)

            --PlayerDamage
            if buffO.showShield then
                hook(PlayerDamage, 'set_regenerate_timer_to_max', function(self, ...)
                    Run('set_regenerate_timer_to_max', self, ...)
                    if self._armor_change_blocked then
                        return
                    end
                    local sd = self._supperssion_data and self._supperssion_data.decay_start_t
                    if sd then
                        sd = math.max(0,sd-now())
                    end
                    local et = now()+self._regenerate_timer+(sd or 0)
                    if et then
                        local buff = me.buffs.shield
                        if buff and not buff.dying then
                            buff.data.st = now()
                            buff.data.et = et
                        else
                            me:Buff3({
                                key="shield",
                                good=false,
                                icon=SkillIcons,
                                iconRect = {6 * 64, 4 * 64, 64, 64},
                                text='',
                                st=now(),
                                et=et
                            })
                        end
                    end
                end)
            end
        end

        if O:get("performance", "blockMagazines") then
            EnemyManager._MAX_MAGAZINES = 0
            function NewRaycastWeaponBase:drop_magazine_object()
            end
            function HuskPlayerMovement:allow_dropped_magazines()
                return false
            end
            function CopMovement:allow_dropped_magazines()
                return false
            end
        end

        if O:get("performance", "blockCorpses")then
            EnemyManager._MAX_NR_CORPSES = 0
            function EnemyManager:corpse_limit()
                return 0
            end
        end

        if O:get("performance", "blockShields") then
            EnemyManager._shield_disposal_lifetime = 0
            EnemyManager._MAX_NR_SHIELDS = 0
            function EnemyManager:shield_limit()
                return 0
            end
        end

        if O:get("performance", "blockHelmets") then
            function CopDamage:_spawn_head_gadget()
            end
        end

        if O:get("performance", "blockBulletDecals") then
            GamePlayCentralManager._block_bullet_decals = true
            function GamePlayCentralManager:_play_bullet_hit(...)
            end
        end
        if O:get("performance", "blockBloodDecals") then
            GamePlayCentralManager._block_blood_decals = true
            function GamePlayCentralManager:play_impact_flesh(...)
            end
            function GamePlayCentralManager:sync_play_impact_flesh(...)
            end
        end

        if O:get("performance", "reduceShotgunSpam") then
            for key, value in pairs(tweak_data.weapon) do
                if key:find("_crew") and (value.is_shotgun or value.rays) then
                    value.rays = 1
                end
            end
        end
    else -- if outGame
        if managers.player then
            managers.player._unseen_strike = nil
            managers.player._coroutine_mgr:clear()
        end
        local dO = O:get("corner")
        self.dbgLbl:set_visible(dO.showClockOutgame or dO.showFPS)
    end -- End of if inGame

    -- Kick menu
    if O:get('game','showRankInKickMenu') then
        hook(KickPlayer, 'modify_node', function(...)
            local self, node, up = unpack{...}
            local new_node = deep_clone(node)
            if managers.network:session() then
                for __, peer in pairs( managers.network:session():peers() ) do
                    local level_string = managers.experience:gui_string(peer:level() or "?", peer:rank())
                    local params = {
                                    name			= peer:name(),
                                    text_id			= _.s(level_string, peer:name()),
                                    callback		= 'kick_player',
                                    to_upper		= false,
                                    localize		= 'false',
                                    rpc				= peer:rpc(),
                                    peer			= peer,
                                    }
                    local new_item = node:create_item( nil, params )
                    new_node:add_item( new_item )
                end
            end
            managers.menu:add_back_button( new_node )
            return new_node
        end)
    end
    -- Mouse hook plugin

    hook(MenuRenderer, 'mouse_moved', function(...)
        --local self, o, x, y = unpack{...}
        if me.menuGui then
            return true
        else
            return Run('mouse_moved', ...)
        end
    end)
    hook(MenuInput, 'mouse_moved*', function(...)
        local self, o, x, y = unpack{...}
        if me.menuGui then
            if not inGame then
                return me.menuGui:mouse_moved(true, o, x, y)
            else
                return true
            end
        else
            return Run('mouse_moved*', ...)
        end
    end)
    hook(MenuManager, 'toggle_menu_state', function(...)
        if me.menuGui then
            me:Menu(true) -- dismiss Menu when actual game-menu is called
            if managers.menu:active_menu() then
                managers.menu:active_menu().renderer:disable_input(0.2)
            end

        else
            return Run('toggle_menu_state', ...)
        end
    end)
    hook(MenuInput, 'update**', function(...)
        if Poco._kbd:pressed(28) and alt() then
            managers.viewport:set_fullscreen(not RenderSettings.fullscreen)
        else
            return Run('update**', ...)
        end
    end)
    if inGame then
        hook(FPCameraPlayerBase, '_update_rot', function(...)
            if me.menuGui then
                return false
            else
                return Run('_update_rot', ...)
            end
        end)
    end
    -- Music hook
    local function MusicChange(s)
        if O:get("root","showMusicTitle") then
            me:SimpleFloat{key='showMusicTitle',x=10,y=10,time=5,anim=1,offset={200,0},
                text={{_.s(O:get("root","showMusicTitlePrefix")),cl.White:with_alpha(0.6)},{s,cl.Tan}},
                size=24, icon = {tweak_data.hud_icons:get_icon_data('jukebox_playing_icon')}
            }
        end
    end
    local ms = _.g('Global.music_manager.source')
    if ms then
        hook(getmetatable(ms), 'set_switch', function(self, type, val, ...)
            if type == 'music_randomizer' and val then
                local s = managers.localization:text("menu_jukebox_" .. val)
                MusicChange(s)
            end
            return Run('set_switch', self, type, val, ...)
        end)
    end
    --MusicManager:jukebox_menu_track(name)
    hook(MusicManager, 'jukebox_menu_track', function(...)
        local result = Run('jukebox_menu_track', ...)
        if result then
            local s = managers.localization:text("menu_jukebox_screen_" .. result)
            MusicChange(s)
        end
        return result
    end)
    --function LevelsTweakData:get_music_event(stage)
    hook(LevelsTweakData, 'get_music_event', function(...)
        local result = Run('get_music_event', ...)
        if result and O('root','shuffleMusic') then
            local self,stage = unpack{...}
            if stage == 'control' then
                if self._poco_can_shuffle then
                    _.g('managers.music:check_music_switch()')
                else
                    self._poco_can_shuffle = 1
                end
            end
        end
        return result
    end)

--- DEBUG ONLY
--------------
    if not inGame then
        --function CrimeNetGui:_create_job_gui(data, type, fixed_x, fixed_y, fixed_location)
        hook(CrimeNetGui, '_create_job_gui', function(...) -- Hook crimenet font size & color
            local sizeMul = O('game','resizeCrimenet')
            local colorize = O('game','colorizeCrimenet')
            if not tweak_data.menu.pd2_small_font_size_backup then
                tweak_data.menu.pd2_small_font_size_backup = tweak_data.menu.pd2_small_font_size
            else
                tweak_data.menu.pd2_small_font_size = tweak_data.menu.pd2_small_font_size_backup
            end
            sizeMul = sizeMul and sizeMul / 10 + 0.5 or 1
            local size = tweak_data.menu.pd2_small_font_size
            tweak_data.menu.pd2_small_font_size = size * sizeMul
            local result = Run('_create_job_gui',...)
            tweak_data.menu.pd2_small_font_size = size
            local self,data = unpack{...}
            if colorize and result.side_panel and result.side_panel:child('job_name') then
                local colors = {cl.Red,cl.PaleGreen,cl.PaleGoldenrod,cl.LavenderBlush,cl.Wheat,cl.Tomato}
                result.side_panel:child('job_name'):set_color(colors[data.difficulty_id] or cl.White)
            end
            if colorize and result.heat_glow then
                result.heat_glow:set_alpha(result.heat_glow:alpha()*0.5)
            end
            return result
        end)

        if O('game','gridCrimenet') then
            hook(CrimeNetGui, '_create_locations', function(self, ...) -- Hook locations[1]
                Run('_create_locations', self, ...)
                local newDots = {}
                local xx,yy = 12,10
                for i=1,xx do -- 224~1666 1442
                    for j=1,yy do -- 165~945 780
                        local newX = 100+ 1642*i/xx
                        local newY = 100+ 680*(i % 2 == 0 and j or j - 0.5)/yy
                        if  (i >= 3) or ( j < 7 ) then
                            -- avoiding fixed points
                            table.insert(newDots,{ newX, newY })
                        end
                    end
                end
                self._locations[1][1].dots = newDots
            end)
        end

        hook(CrimeNetGui, '_get_job_location', function(...) -- Hook locations[2]
            if O('game','sortCrimenet') then
                local self,data = unpack{...}
                local diff = (data and data.difficulty_id or 2) - 2
                local diffX = 236 + ( 1700 / 7 ) * diff
                local locations = self:_get_contact_locations()
                local sorted = {}
                for k,v in pairs(locations[1].dots) do
                    if not v[3] then
                        table.insert(sorted,v)
                    end
                end
                if #sorted > 0 then
                    local abs = math.abs
                    local diff_filter = false--(managers.user:get_setting("crimenet_filter_difficulty") or 0) > 0

                    if not self.sorted_last_poss then
                        self.sorted_last_poss = {}
                    end

                    local dot

                    if diff_filter then
                        table.sort(sorted,function(a,b)
                            return a[2] < b[2]
                        end)

                        local byteZ = 26
                        local byteJob = string.byte(data.job_id:sub(1,1)) - 96

                        dot = sorted[ math.ceil( #sorted * byteJob/byteZ ) ] or sorted[1]

                        local jobID = data.job_id
                        if self.sorted_last_poss[jobID] then
                            local dist = 1000
                            for k,v in pairs(sorted) do
                                local current_dist = abs(v[1] - self.sorted_last_poss[jobID][1])
                                                    + abs(v[2] - self.sorted_last_poss[jobID][2])
                                if current_dist < dist then
                                    dist = current_dist
                                    dot = v
                                end
                            end
                        else
                            self.sorted_last_poss[jobID] = dot
                        end
                    else
                        table.sort(sorted, function(a,b)
                            return abs(diffX-a[1]) < abs(diffX-b[1])
                        end)

                        dot = sorted[1]
                    end

                    local x,y = dot[1],dot[2]
                    local tw = math.max(self._map_panel:child("map"):texture_width(), 1)
                    local th = math.max(self._map_panel:child("map"):texture_height(), 1)
                    x = math.round(x / tw * self._map_size_w)
                    y = math.round(y / th * self._map_size_h)

                    return x,y,dot
                else
                    return self:_get_random_location() -- just in case of failure
                end
            else
                return Run('_get_job_location', ...)
            end
        end)
    end
end
--- Utility functions ---
function TPocoHud3:toggleVerbose(state)
    if state == 'toggle' then
        self.verbose = not self.verbose
    else
        self.verbose = state
    end
    if O:get("corner").detailedOnly and self.dbgLbl then
        self.dbgLbl:set_visible(self.verbose)
    end
    if self.menuGui and self.menuGui.alt then
        return
    end
    if not self.inGameDeep and self.verbose then
        pcall(function()
            self:Menu()
            if self.menuGui then
                self.menuGui.gui:goTo(3)
            end
        end)
    end
end
function TPocoHud3:test()
-- reserved
    self:Menu()
end

function TPocoHud3:_getAngle(unit)
    if not (unit and type(unit)=='userdata' and alive(unit) and not self.dead) then
        return 360
    end
    local uPos = unit:position()
    local vec = self.camPos - uPos
    local fwd = self.cam:rotation():y()
    local ang = math.floor( vec:to_polar_with_reference( fwd, math.UP ).spin )
    return -(ang+180)
end

function TPocoHud3:_v2p(pos)
    return alive(self._ws) and pos and self._ws:world_to_screen( self.cam, pos )
end

function TPocoHud3:_vectorToScreen(v3pos)
    if not self._ws then return end
    local cam = managers.viewport:get_current_camera()
    return (cam and v3pos) and self._ws:world_to_screen( cam, v3pos )
end

function TPocoHud3:_getDelayedCbk(id)
    local eM = managers.enemy
    local all_clbks = eM and eM._delayed_clbks or {}
    for __, clbk_data in ipairs(all_clbks) do
        if clbk_data[1] == id then
            return (clbk_data[2] or 0)-now(true), clbk_data[3]
        end
    end
end

function TPocoHud3:_lbl(lbl,txts)
    local result = ''
    if not alive(lbl) then
        if type(txts)=='table' then
            for __, t in pairs(txts) do
                result = result .. tostring(t[1])
            end
        else
            result = txts
        end
    else
        if type(txts)=='table' then
            local pos = 0
            local posEnd = 0
            local ranges = {}
            for _k,txtObj in ipairs(txts or {}) do
                txtObj[1] = tostring(txtObj[1])
                result = result..txtObj[1]
                local __, count = txtObj[1]:gsub('[^\128-\193]', '')
                posEnd = pos + count
                table.insert(ranges,{pos,posEnd,txtObj[2] or cl.White})
                pos = posEnd
            end
            lbl:set_text(result)
            for _,range in ipairs(ranges) do
                lbl:set_range_color(range[1], range[2], range[3] or cl.Green)
            end
        elseif type(txts)=='string' then
            result = txts
            lbl:set_text(txts)
        end
    end
    return result
end
function TPocoHud3:_drawRow(pnl, fontSize, texts, _x, _y, _w, bg, align, lineHeight)
    local _fontSize = fontSize * (lineHeight or 1.1)
    if bg then
        pnl:rect( { x=_x,y=_y,w=_w,h=_fontSize,color=cl.White, alpha=0.05, layer=0 } )
    end
    local count = #texts
    local iw = _w / count
    local isCenter = function(i)
        return align == true or (type(align)=='table' and align[i]~=0)
    end
    for i,text in pairs(texts) do
        if text and text ~= '' then
            if (type(text)=='table' or type(text)=='userdata') and text.set_y then
                text:set_y(_y)
                if isCenter(i) then
                    text:set_center_x(math.round(_x + iw*(i-0.5)))
                else
                    text:set_x(math.round(_x+iw*(i-1)))
                end
            else
                local res, lbl = _.l({ pnl=pnl,font=FONT, color=cl.White, font_size=fontSize, x=_x + iw*(i-0.5), y=math.floor(_y), w = iw, h = _fontSize, text='', align = isCenter(i) and 'center', vertical = 'center', blend_mode='add'},text,not isCenter(i))
                lbl:set_x(math.round(_x+iw*(i-1)))
                --[[if isCenter(i) then
                    lbl:set_center_x(math.round(_x + iw*(i-0.5)))
                end]]

            end
        end
    end
    return _y + _fontSize
end
--- Class end ---
PocoHud3 = PocoHud3
TPocoHud3.Toggle = function()
    me = Poco:AddOn(TPocoHud3)
    DC = Poco.DelayedCallsFix
    if me and not me.dead then
        PocoHud3 = me
    else
        PocoHud3 = true
    end
    PocoHud3Class.loadVar(O,me,L)
    if me then
		me:ImportFloats()
        me:Refresh()
	end
end
if Poco and not Poco.dead then
    TPocoHud3.Toggle()
else
    managers.menu_component:post_event('zoom_out')
end
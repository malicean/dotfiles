PocoLocale = {}

PocoLocale._BAGS = {
	ammo = 'Ammo',
	medic = 'Med',
	body = 'Body',
	fak = 'Aid',
	grenades = 'Throwables'
}

PocoLocale._defaultLocaleData = {

	-- no need to translate this
	_client_name = 'PocoHud3',
	_about_trans_fullList = '{Dansk (DA)|Tan}\nNickyFace, DanishDude93\n{Deutsch (DE)|Tan}\nfallenpenguin, Raxdor, GIider, Hoffy,\nNowRiseAgain, Pixelpille, Sithryl,\nValkein, Zee_, baddog_11\n{Español (ES)|Tan}\nNiccy, BurnBabyBurn\n{Français (FR)|Tan}\nChopper385, Dewk Noukem, Lekousin, Shendow\n{Italiano (IT)|Tan}\nOktober, Nitronik\n{Bahasa Indonesia (ID)|Tan}\nPapin Faizal(papin97)\n{Nederlands (NL)|Tan}\nNickolas Cat, Rezqual\n{Norsk (NO)|Tan}\nikoddn\n{Polski (PL_PL)|Tan}\nMartinz, Kuziz, gmaxpl3\n{Português (PT_PT)|Tan}\nBruno \"Personagem\" Tibério, John Ryder\n{Português (PT_BR)|Tan}\ngabsF\n{Русский (RU)|Tan}\ncollboy, Hellsing, troskahtoh\n{Svenska (SV_SE)|Tan}\nTheLovinator, KillYoy, kao172',
	_about_trans_special_thanks_list = '{Overkill|White}\nfor a legendary game {& not kicking my arse off|Silver|0.5}\n{Harfatus|White}\nfor a cool injector\n{Olipro|White}\nfor keeping MOD community alive\n{v00d00 & gir489 & 90e|White}\nfor making me able to learn Lua from the humble ground\n{Arkkat|White}\nfor crashing the game for me at least 50 times since alpha stage\n{Tatsuto|White}\nfor PD2Stats.com API\n{You|Yellow}\nfor keeping me way too busy to go out at weekends {/notreally|Silver|0.5}',

	-- a player converted ____
	_mob_city_swat = 'a Gensec Elite',
	_mob_cop = 'a cop',
	_mob_fbi = 'an FBI agent',
	_mob_fbi_heavy_swat = 'an FBI heavy SWAT',
	_mob_fbi_swat = 'an FBI SWAT',
	_mob_gangster = 'a gangster',
	_mob_gensec = 'a Gensec guard',
	_mob_heavy_swat = 'a heavy SWAT',
	_mob_security = 'a guard',
	_mob_shield = 'a shield',
	_mob_sniper = 'a sniper',
	_mob_spooc = 'a cloaker',
	_mob_swat = 'a SWAT',
	_mob_tank = 'a bulldozer',
	_mob_taser = 'a taser',

	_msg_around = 'around [1]',
	_msg_captured = '[1] has been captured [2]',
	_msg_converted = '[1] converted [2] [3]',
	_msg_downed = '[1] was downed',
	_msg_downedWarning = 'Warning: [1] has 0 downs left',
	_msg_minionLost = '[1] lost a minion ([2][3])',
	_msg_minionShot = '[1] damaged [2] minion for [3]',
	_msg_not_implemented = 'Not Implemented for now',
	_msg_replenished = '[1] replenished health by [2]% [3]',
	_msg_replenishedDown = '(+[1] down)',
	_msg_replenishedDownPlu = '(+[1] downs)',
	_msg_replenishedDownFak = '(fak)',
	_msg_used_doctorbag = "[1] used a Doctor Bag (+[2] [3])",
	_msg_used_doctorbag_down = "down",
	_msg_used_doctorbag_downs = "downs",
	_msg_used_fak = "[1] used a First Aid Kit",
	_msg_usedPistolMessiah = 'Used Pistol messiah',
	_msg_usedPistolMessiahCharges = '[1] charge',
	_msg_usedPistolMessiahChargesPlu = '[1] charges',
	_msg_specOps = 'A Spec Ops DLC item was picked up',
	_msg_havePagers = 'You can answer [1] pager(s)',
	_msg_haveCivilians = 'You can kill [1] civilian(s)',

	_opt_chat_desc = '{_opt_chat_desc_1}\n{_opt_chat_desc_2|White|0.5}\n{_opt_chat_desc_3|White|0.6}\n{_opt_chat_desc_4|White|0.7}\n{_opt_chat_desc_5|White|0.8}\n{_opt_chat_desc_6|White|0.9}\n{_opt_chat_desc_7|White}',
	_opt_truncateTags_desc = '{_opt_truncateTags_desc_1} {[Poco]Hud|Tan} > {_Dot|Tan}{Hud|Tan}',
	_vanity_resizeCrimenet = '60%,70%,80%,90%,100%,110%,120%,130%',
}

PocoLocale._drillNames = {
	drill = 'Drill',
	lance = 'Thermal Drill',
	uload_database = 'Uploading',
	votingmachine2 = 'Voting Machine',
	hold_download_keys = 'Encryption Keys', -- Hoxton Breakout
	hold_hack_comp = 'Security Clearance', -- Hoxton Breakout Director's PC
	hold_analyze_evidence = 'Evidence Analysis', -- Hoxton Breakout
	digitalgui = 'Timelock',
	huge_lance = 'The Beast',
	pd1_drill = 'OVERDRILL', -- First World Bank Overdrill
	cas_copy_usb = 'Guest List', -- Guest List Download for Golden Grin Casino
	are_laptop = 'Pyrotechnic Hacking', -- Laptop hacking for Alesso Heist
	invisible_interaction_open = 'Hacking', -- The first hacking on counterfeit
	process = 'Process', -- If a process does not have a name
	hold_charge_gun = 'Weapon Charge', -- Henry's Rock
	security_station = 'Hack' -- Undercover hack
}

PocoLocale._drillNamesGuess = {
	laptop = 'Hacking',
	hack = 'Hacking',
	drill = 'Drill',
	lance = 'Drill',
	saw = 'Saw',
	load = 'Loading',
	copy = 'Copying'
}

PocoLocale._drillHosts = {

	-- a drill on ____
	['d2e9092f3a57cefc'] = 'a mini safe',
	['e87e439e3e1a7313'] = 'a mini titan safe',
	['ad6fb7a483695e19'] = 'a safe',
	['dbfbfbb21eddcd30'] = 'a titan safe',
	['3e964910f730f3d7'] = 'a huge safe',
	['246cc067a20249df'] = 'a huge titan safe',
	['8834e3a4da3df5c6'] = 'a tall safe',
	['e3ab30d889c6db5f'] = 'a tall titan safe',
	['4407f5e571e2f51a'] = 'a door',
	['0afafcebe54ae7c4'] = 'a cage door',
	['1153b673d51ed6ad'] = 'a Gensec truck',
	['04080fd150a77c7f'] = 'a crashed Gensec truck',
	['0d07ff22a1333115'] = 'a sniped Gensec truck',
	['a8715759c090b251'] = 'a fence door',
	['a7b371bf0e3fd30a'] = 'a truck hinge',
	['07e2cf254ef76c5e'] = 'a vault cage door',
	['d475830b4e6eda32'] = 'a vault door',
	['b2928ed7d5b8797e'] = 'a cage door',
	['43132b0a273df773'] = 'an office door',
	['b8ebd1a5a8426e52'] = 'an artifact safe'
}

PocoLocale._drillOn = 'on' -- drill [on] a safe
PocoLocale._drillAlmost = ' < 10s left'
PocoLocale._drillDone = 'is done'

PocoLocale._convertOwn = 'own'
PocoLocale._handsUp = 'Hands-Up'
PocoLocale._Intimidated = 'Intimidated'
PocoLocale._s = '\'s'  -- someone damaged almir['s] convert

PocoLocale._Someone = 'Someone'
PocoLocale._hours = 'h'
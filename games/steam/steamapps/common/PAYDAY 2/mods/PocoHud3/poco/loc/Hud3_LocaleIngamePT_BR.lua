PocoLocale = {}

PocoLocale._BAGS = {
	ammo = 'Munição',
	medic = 'Bolsa Médica',
	body = 'Cadáver',
	fak = 'Kit',
	grenades = 'Granadas'
}

PocoLocale._defaultLocaleData = {

	-- no need to translate this
	_client_name = 'PocoHud3',
	_about_trans_fullList = '{Dansk (DA)|Tan}\nNickyFace, DanishDude93\n{Deutsch (DE)|Tan}\nfallenpenguin, Raxdor, GIider, Hoffy,\nNowRiseAgain, Pixelpille, Sithryl,\nValkein, Zee_, baddog_11\n{Español (ES)|Tan}\nNiccy, BurnBabyBurn\n{Français (FR)|Tan}\nChopper385, Dewk Noukem, Lekousin, Shendow\n{Italiano (IT)|Tan}\nOktober, Nitronik\n{Bahasa Indonesia (ID)|Tan}\nPapin Faizal(papin97)\n{Nederlands (NL)|Tan}\nNickolas Cat, Rezqual\n{Norsk (NO)|Tan}\nikoddn\n{Polski (PL_PL)|Tan}\nMartinz, Kuziz, gmaxpl3\n{Português (PT_PT)|Tan}\nBruno \"Personagem\" Tibério, John Ryder\n{Português (PT_BR)|Tan}\ngabsF\n{Русский (RU)|Tan}\ncollboy, Hellsing, troskahtoh\n{Svenska (SV_SE)|Tan}\nTheLovinator, KillYoy, kao172',
	_about_trans_special_thanks_list = '{Overkill|White}\nfor a legendary game {& not kicking my arse off|Silver|0.5}\n{Harfatus|White}\nfor a cool injector\n{Olipro|White}\nfor keeping MOD community alive\n{v00d00 & gir489 & 90e|White}\nfor making me able to learn Lua from the humble ground\n{Arkkat|White}\nfor crashing the game for me at least 50 times since alpha stage\n{Tatsuto|White}\nfor PD2Stats.com API\n{You|Yellow}\nfor keeping me way too busy to go out at weekends {/notreally|Silver|0.5}',

	-- a player converted ____
	_mob_city_swat = 'um Elite da Gensec',
	_mob_cop = 'um policial',
	_mob_fbi = 'um agente do FBI',
	_mob_fbi_heavy_swat = 'um FBI da SWAT Pesado',
	_mob_fbi_swat = 'um FBI da SWAT',
	_mob_gangster = 'um gangster',
	_mob_gensec = 'um guarda da Gensec',
	_mob_heavy_swat = 'uma SWAT pesado',
	_mob_security = 'um guarda',
	_mob_shield = 'um shield',
	_mob_sniper = 'um sniper',
	_mob_spooc = 'um cloaker',
	_mob_swat = 'uma SWAT',
	_mob_tank = 'um bulldozer',
	_mob_taser = 'um taser',

	_msg_around = 'em [1]',
	_msg_captured = '[1] foi capturado [2]',
	_msg_converted = '[1] converteu [2] [3]',
	_msg_downed = '[1] caiu',
	_msg_downedWarning = 'Aviso: [1] tem 0 quedas restantes.',
	_msg_minionLost = '[1] perdeu um convertido ([2][3])',
	_msg_minionShot = '[1] fez um dano no convertido do [2] por [3]',
	_msg_not_implemented = 'Ainda não foi implemetado',
	_msg_replenished = '[1] recuperou [2]% [3]',
	_msg_replenishedDown = '(+[1] queda)',
	_msg_replenishedDownPlu = '(+[1] quedas)',
	_msg_replenishedDownFak = '(fak)',
	_msg_used_doctorbag = "[1] used a Doctor Bag (+[2] [3])",
	_msg_used_doctorbag_down = "queda",
	_msg_used_doctorbag_downs = "quedas",
	_msg_used_fak = "[1] used a First Aid Kit",
	_msg_usedPistolMessiah = 'Usou Messiah',
	_msg_usedPistolMessiahCharges = '[1] uso',
	_msg_usedPistolMessiahChargesPlu = '[1] usos',
	_msg_specOps = 'Alguém pegou um item da DLC Spec Ops.',
	_msg_havePagers = 'Você pode responder [1] pager(s)',
	_msg_haveCivilians = 'Você pode matar [1] civis',

	_opt_chat_desc = '{_opt_chat_desc_1}\n{_opt_chat_desc_2|White|0.5}\n{_opt_chat_desc_3|White|0.6}\n{_opt_chat_desc_4|White|0.7}\n{_opt_chat_desc_5|White|0.8}\n{_opt_chat_desc_6|White|0.9}\n{_opt_chat_desc_7|White}',
	_opt_truncateTags_desc = '{_opt_truncateTags_desc_1} {[Poco]Hud|Tan} > {_Dot|Tan}{Hud|Tan}',
	_vanity_resizeCrimenet = '60%,70%,80%,90%,100%,110%,120%,130%',
}

PocoLocale._drillNames = {
	drill = 'Furadeira',
	lance = 'Furadeira Térmica',
	uload_database = 'Enviando',
	votingmachine2 = 'Máquinas de Votação',
	hold_download_keys = 'Senhas de Encriptação', -- Hoxton Breakout
	hold_hack_comp = 'Aprovação de Segurança', -- Hoxton Breakout Directors PC
	hold_analyze_evidence = 'Análise de Evidência', -- Hoxton Breakout
	digitalgui = 'Temporizador',
	huge_lance = 'A Besta',
	pd1_drill = 'OVERDRILL', -- First World Bank Overdrill
	cas_copy_usb = 'Lista de Convidados', -- Guest List Download for Golden Grin Casino
	are_laptop = 'Hackeando Pirotecnia', -- Laptop hacking for Alesso Heist
	invisible_interaction_open = 'Hackeando', -- The first hacking on counterfeit
	process = 'Processando', -- If a process does not have a name
	hold_charge_gun = 'Carga da Arma', -- Henry's Rock
	security_station = 'Hackeando' -- Undercover hack
}

PocoLocale._drillNamesGuess = {
	laptop = 'Hackeando',
	hack = 'Hackeando',
	drill = 'Furadeira',
	lance = 'Furadeira',
	saw = 'Serra',
	load = 'Carregando',
	copy = 'Copiando'
}

PocoLocale._drillHosts = {

	-- a drill on ____
	['d2e9092f3a57cefc'] = 'um cofre pequeno',
	['e87e439e3e1a7313'] = 'um cofre titã pequeno',
	['ad6fb7a483695e19'] = 'um cofre',
	['dbfbfbb21eddcd30'] = 'um cofre titã',
	['3e964910f730f3d7'] = 'um cofre grande',
	['246cc067a20249df'] = 'um cofre titã grande',
	['8834e3a4da3df5c6'] = 'um cofre alto',
	['e3ab30d889c6db5f'] = 'um cofre titã alto',
	['4407f5e571e2f51a'] = 'uma porta',
	['0afafcebe54ae7c4'] = 'uma porta de gaiola',
	['1153b673d51ed6ad'] = 'um caminhão da Gensec',
	['04080fd150a77c7f'] = 'um caminhão da Gensec quebrado',
	['0d07ff22a1333115'] = 'um caminhão da Gensec snipado (?)',
	['a8715759c090b251'] = 'um portão da cerca',
	['a7b371bf0e3fd30a'] = 'uma dobradiça do caminhão',
	['07e2cf254ef76c5e'] = 'uma porta da gaiola do cofre',
	['d475830b4e6eda32'] = 'uma porta do cofre',
	['b2928ed7d5b8797e'] = 'uma porta da gaiola',
	['43132b0a273df773'] = 'uma porta do escritório',
	['b8ebd1a5a8426e52'] = 'um cofre de artefato'
}

PocoLocale._drillOn = 'em' -- drill [on] a safe
PocoLocale._drillAlmost = ' < 10 segundos restantes'
PocoLocale._drillDone = 'terminou'

PocoLocale._convertOwn = 'que possui'
PocoLocale._handsUp = 'Mãos Para Cima'
PocoLocale._Intimidated = 'Dominado'
PocoLocale._s = ''  -- someone damaged almir['s] convert

PocoLocale._Someone = 'Alguém'
PocoLocale._hours = 'hrs'
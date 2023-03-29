PocoLocale = {}

PocoLocale._BAGS = {
	ammo = '총알',
	medic = '의료가방',
	body = '시체가방',
	fak = '의료킷',
	grenades = '투척물'
}

PocoLocale._defaultLocaleData = {

	-- no need to translate this
	_client_name = 'PocoHud3',
	_about_trans_fullList = '{Dansk (DA)|Tan}\nNickyFace, DanishDude93\n{Deutsch (DE)|Tan}\nfallenpenguin, Raxdor, GIider, Hoffy,\nNowRiseAgain, Pixelpille, Sithryl,\nValkein, Zee_, baddog_11\n{Español (ES)|Tan}\nNiccy, BurnBabyBurn\n{Français (FR)|Tan}\nChopper385, Dewk Noukem, Lekousin, Shendow\n{Italiano (IT)|Tan}\nOktober, Nitronik\n{Bahasa Indonesia (ID)|Tan}\nPapin Faizal(papin97)\n{Nederlands (NL)|Tan}\nNickolas Cat, Rezqual\n{Norsk (NO)|Tan}\nikoddn\n{Polski (PL_PL)|Tan}\nMartinz, Kuziz, gmaxpl3\n{Português (PT_PT)|Tan}\nBruno \"Personagem\" Tibério, John Ryder\n{Português (PT_BR)|Tan}\ngabsF\n{Русский (RU)|Tan}\ncollboy, Hellsing, troskahtoh\n{Svenska (SV_SE)|Tan}\nTheLovinator, KillYoy, kao172',
	_about_trans_special_thanks_list = '{Overkill|White}\nfor a legendary game {& not kicking my arse off|Silver|0.5}\n{Harfatus|White}\nfor a cool injector\n{Olipro|White}\nfor keeping MOD community alive\n{v00d00 & gir489 & 90e|White}\nfor making me able to learn Lua from the humble ground\n{Arkkat|White}\nfor crashing the game for me at least 50 times since alpha stage\n{Tatsuto|White}\nfor PD2Stats.com API\n{You|Yellow}\nfor keeping me way too busy to go out at weekends {/notreally|Silver|0.5}',

	-- a player converted ____
	_mob_city_swat = '젠섹 엘리트',
	_mob_cop = '경찰',
	_mob_fbi = 'FBI 요원',
	_mob_fbi_heavy_swat = 'FBI 헤비 스왓',
	_mob_fbi_swat = 'FBI 스왓',
	_mob_gangster = '갱스터',
	_mob_gensec = '젠섹 경비',
	_mob_heavy_swat = '헤비 스왓',
	_mob_security = '경비',
	_mob_shield = '실드',
	_mob_sniper = '스나이퍼',
	_mob_spooc = '클로커',
	_mob_swat = '스왓',
	_mob_tank = '불도저',
	_mob_taser = '테이저',

	_msg_around = '주변 [1]',
	_msg_captured = '[1] 투항시켰습니다 [2]',
	_msg_converted = '[1] 조커로만들었습니다 [2] [3]',
	_msg_downed = '[1] 쓰러졌습니다',
	_msg_minionLost = '[1] 조커를 잃었습니다 ([2][3])',
	_msg_minionShot = '[1] 대미지를 주었습니다 [2] 조커에게 [3]',
	_msg_not_implemented = '지금은 할수없습니다',
	_msg_replenished = '[1] 체력 회복 [2]% [3]',
	_msg_replenishedDown = '(+[1] 다운)',
	_msg_replenishedDownPlu = '(+[1] 다운)',
	_msg_replenishedDownFak = '(의료킷)',
	_msg_used_doctorbag = "[1] used a Doctor Bag (+[2] [3])",
	_msg_used_doctorbag_down = "down",
	_msg_used_doctorbag_downs = "downs",
	_msg_used_fak = "[1] used a First Aid Kit",
	_msg_usedPistolMessiah = '메시아 피스톨 사용됨',
	_msg_usedPistolMessiahCharges = '[1] 충전',
	_msg_usedPistolMessiahChargesPlu = '[1] 충전됨',
	_msg_specOps = '스펙 옵스 dlc 아이템 획득',
	_msg_havePagers = '당신은 응답할수있습니다 [1] 페이저',
	_msg_haveCivilians = '죽일수있습니다 [1] 시민',

	_opt_chat_desc = '{_opt_chat_desc_1}\n{_opt_chat_desc_2|White|0.5}\n{_opt_chat_desc_3|White|0.6}\n{_opt_chat_desc_4|White|0.7}\n{_opt_chat_desc_5|White|0.8}\n{_opt_chat_desc_6|White|0.9}\n{_opt_chat_desc_7|White}',
	_opt_truncateTags_desc = '{_opt_truncateTags_desc_1} {[Poco]Hud|Tan} > {_Dot|Tan}{Hud|Tan}',
	_vanity_resizeCrimenet = '60%,70%,80%,90%,100%,110%,120%,130%',
}

PocoLocale._drillNames = {
	drill = '드릴',
	lance = '써멀 드릴',
	uload_database = '업로딩중',
	votingmachine2 = '투표기계 해킹',
	hold_download_keys = '암호화 키', -- Hoxton Breakout
	hold_hack_comp = '시큐리티 승인', -- Hoxton Breakout Directors PC
	hold_analyze_evidence = '증거 분석', -- Hoxton Breakout
	digitalgui = '타임락',
	huge_lance = '비스트',
	pd1_drill = '오버드릴', -- First World Bank Overdrill
	cas_copy_usb = '손님 명단', -- Guest List Download for Golden Grin Casino
	are_laptop = '파이로테크닉 해킹', -- Laptop hacking for Alesso Heist
	invisible_interaction_open = '해킹', -- The first hacking on counterfeit
	process = '잠금 해제', -- If a process does not have a name
	hold_charge_gun = '무기 차지' -- Henry's Rock
}

PocoLocale._drillNamesGuess = {
	laptop = '해킹',
	hack = '해킹',
	drill = '드릴',
	lance = '드릴',
	saw = '톱',
	load = '로딩중',
	copy = '복사중'
}

PocoLocale._drillHosts = {

	-- a drill on ____
	['d2e9092f3a57cefc'] = '작은 금고',
	['e87e439e3e1a7313'] = '작은 타이탄 금고',
	['ad6fb7a483695e19'] = '금고',
	['dbfbfbb21eddcd30'] = '타이탄 금고',
	['3e964910f730f3d7'] = '거대한 금고',
	['246cc067a20249df'] = '거대한 타이탄 금고',
	['8834e3a4da3df5c6'] = '긴 금고',
	['e3ab30d889c6db5f'] = '긴 타이탄 금고',
	['4407f5e571e2f51a'] = '문',
	['0afafcebe54ae7c4'] = '철창 문',
	['1153b673d51ed6ad'] = '젠섹 트럭',
	['04080fd150a77c7f'] = '손상된 젠섹 트럭',
	['0d07ff22a1333115'] = '저격당한 젠섹 트럭',
	['a8715759c090b251'] = '철창 문',
	['a7b371bf0e3fd30a'] = '트럭 경첩',
	['07e2cf254ef76c5e'] = '볼트 철창 문',
	['d475830b4e6eda32'] = '볼트 문',
	['b2928ed7d5b8797e'] = '철창 문',
	['43132b0a273df773'] = '오피스 문',
	['b8ebd1a5a8426e52'] = '아티팩트 금고'
}

PocoLocale._drillOn = '작동' -- drill [on] a safe
PocoLocale._drillAlmost = ' < 10초 남음'
PocoLocale._drillDone = '끝남'

PocoLocale._convertOwn = '자기'
PocoLocale._handsUp = '손들어'
PocoLocale._Intimidated = '투항함'
PocoLocale._s = '\'의'  -- someone damaged almir['s] convert

PocoLocale._Someone = '누군가'
PocoLocale._hours = '시간'
-- Thanks to http://steamcommunity.com/id/2609665

PocoLocale = {}

PocoLocale._BAGS = {
	ammo = '弹药包',
	medic = '急救箱',
	body = '尸体袋',
	fak = '援助包',
	grenades = '投掷物'
}

PocoLocale._defaultLocaleData = {

	-- no need to translate this
	_client_name = 'PocoHud3',
	_about_trans_fullList = '{Dansk (DA)|Tan}\nNickyFace, DanishDude93\n{Deutsch (DE)|Tan}\nfallenpenguin, Raxdor, GIider, Hoffy,\nNowRiseAgain, Pixelpille, Sithryl,\nValkein, Zee_, baddog_11\n{Español (ES)|Tan}\nNiccy, BurnBabyBurn\n{Français (FR)|Tan}\nChopper385, Dewk Noukem, Lekousin, Shendow\n{Italiano (IT)|Tan}\nOktober, Nitronik\n{Bahasa Indonesia (ID)|Tan}\nPapin Faizal(papin97)\n{Nederlands (NL)|Tan}\nNickolas Cat, Rezqual\n{Norsk (NO)|Tan}\nikoddn\n{Polski (PL_PL)|Tan}\nMartinz, Kuziz, gmaxpl3\n{Português (PT_PT)|Tan}\nBruno \"Personagem\" Tibério, John Ryder\n{Português (PT_BR)|Tan}\njkisten\n{Русский (RU)|Tan}\ncollboy, Hellsing, troskahtoh\n{Svenska (SV_SE)|Tan}\nTheLovinator, KillYoy, kao172',
	_about_trans_special_thanks_list = '{Overkill|White}\nfor a legendary game {& not kicking my arse off|Silver|0.5}\n{Harfatus|White}\nfor a cool injector\n{Olipro|White}\nfor keeping MOD community alive\n{v00d00 & gir489 & 90e|White}\nfor making me able to learn Lua from the humble ground\n{Arkkat|White}\nfor crashing the game for me at least 50 times since alpha stage\n{Tatsuto|White}\nfor PD2Stats.com API\n{You|Yellow}\nfor keeping me way too busy to go out at weekends {/notreally|Silver|0.5}',

	-- a player converted ____
	_mob_city_swat = '精英特警',
	_mob_cop = '警察',
	_mob_fbi = 'FBI探员',
	_mob_fbi_heavy_swat = 'FBI重型特警',
	_mob_fbi_swat = 'FBI特警',
	_mob_gangster = '黑帮匪徒',
	_mob_gensec = '警卫',
	_mob_heavy_swat = '重型特警',
	_mob_security = '保安',
	_mob_shield = '钢盾特警',
	_mob_sniper = '狙击手',
	_mob_spooc = '幽灵特警',
	_mob_swat = 'SWAT特警',
	_mob_tank = '恐吓者(钢熊)',
	_mob_taser = '泰瑟特警',
	
	_msg_around = ' [1] ',
	_msg_captured = '[1]被绑在[2]的附近',
	_msg_converted = '[1] 对着那个跪在 [3] 地上可怜兮兮的 [2] 吼道：“当什么狗条子?跟着俺们打家劫舍,吃香喝辣有女人,潇洒快活!!!',
	_msg_downed = '[1]重伤倒地,急需援助',
	_msg_minionLost = '[1]的狗腿子[2]已被乱枪打死,赶紧再去抓一个吧!',
	_msg_minionShot = '[1]总爱对着[2]的菊花射来射去,[1]这家伙该不会真的是个基佬吧! ',
	_msg_not_implemented = '现在不能执行',
	_msg_replenished = '[1] 使用了急救包，体力已完全恢复，血量回复 [2]% [3]',
	_msg_replenishedDown = '(可倒地次数+[1])',
	_msg_replenishedDownPlu = '(可倒地次数+[1])',
	_msg_replenishedDownFak = '(后援包)',
	_msg_used_doctorbag = "[1] used a Doctor Bag (+[2] [3])",
	_msg_used_doctorbag_down = "down",
	_msg_used_doctorbag_downs = "downs",
	_msg_used_fak = "[1] used a First Aid Kit",
	_msg_usedPistolMessiah = '倒在地上的 [1] 奇迹般的跳了起来，吼道：“我胡汉三又回来了！”',
	_msg_usedPistolMessiahCharges = '[1] 被电击',
	_msg_usedPistolMessiahChargesPlu = '[1] 被电击',
	_msg_specOps = '一个盖奇特别行动(DLC)物品被捡取',
	_msg_havePagers = '你可以回答 [1] 个对讲机',
	_msg_haveCivilians = '你能杀死 [1] 个平民',

	_opt_chat_desc = '{_opt_chat_desc_1}\n{_opt_chat_desc_2|White|0.5}\n{_opt_chat_desc_3|White|0.6}\n{_opt_chat_desc_4|White|0.7}\n{_opt_chat_desc_5|White|0.8}\n{_opt_chat_desc_6|White|0.9}\n{_opt_chat_desc_7|White}',
	_opt_truncateTags_desc = '{_opt_truncateTags_desc_1} {[Poco]Hud|Tan} > {_Dot|Tan}{Hud|Tan}',
	_vanity_resizeCrimenet = '60%,70%,80%,90%,100%,110%,120%,130%',
}

PocoLocale._drillNames = {
	drill = '钻机解锁',
	lance = '热力钻机',
	uload_database = '上传',
	votingmachine2 = '植入病毒',
	hold_download_keys = '获取加密密匙', -- Hoxton Breakout
	hold_hack_comp = '获取安全许可证', -- Hoxton Breakout Directors PC
	hold_analyze_evidence = '证据分析', -- Hoxton Breakout
	digitalgui = '定时锁',
	huge_lance = '野兽钻机',
	pd1_drill = '再钻深点', -- First World Bank Overdrill
	cas_copy_usb = '获取宾客名单', -- Guest List Download for Golden Grin Casino
	are_laptop = '骇入烟火控制台', -- Laptop hacking for Alesso Heist
	invisible_interaction_open = '骇入电脑', -- The first hacking on counterfeit
	process = '正在处理', -- If a process does not have a name
	hold_hack_server_room = '骇入服务器机房' --游艇劫案
}

PocoLocale._drillNamesGuess = {
	laptop = '骇入电脑',
	hack = '骇入电脑',
	drill = '钻开',
	lance = '钻开',
	saw = '锯开',
	load = '加载...',
	copy = '复制...'
}

PocoLocale._drillHosts = {

	-- a drill on ____
	['d2e9092f3a57cefc'] = '迷你保险箱',
	['e87e439e3e1a7313'] = '迷你钛合金保险箱',
	['ad6fb7a483695e19'] = '保险箱',
	['dbfbfbb21eddcd30'] = '钛合金保险箱',
	['3e964910f730f3d7'] = '巨型保险箱',
	['246cc067a20249df'] = '巨型钛合金保险箱',
	['8834e3a4da3df5c6'] = '立式保险箱',
	['e3ab30d889c6db5f'] = '立式钛合金保险箱',
	['4407f5e571e2f51a'] = '门',
	['0afafcebe54ae7c4'] = '铁栏门',
	['1153b673d51ed6ad'] = '押运车',
	['04080fd150a77c7f'] = '撞坏押运车',
	['0d07ff22a1333115'] = '伏击押运车',
	['a8715759c090b251'] = '栅栏门',
	['a7b371bf0e3fd30a'] = '卡车铰链',
	['07e2cf254ef76c5e'] = '地下室铁栏门',
	['d475830b4e6eda32'] = '地下室门',
	['b2928ed7d5b8797e'] = '铁栏门',
	['43132b0a273df773'] = '办公室的门',
	['b8ebd1a5a8426e52'] = '艺术品保险箱'
}

PocoLocale._drillOn = '解锁' -- drill [on] a safe
PocoLocale._drillAlmost = ' 10秒钟后完成'
PocoLocale._drillDone = '完成'

PocoLocale._convertOwn = '警察小弟'
PocoLocale._handsUp = '大佬饶我狗命'
PocoLocale._Intimidated = '捆x绑'
PocoLocale._s = '\'秒'  -- someone damaged almir['s] convert

PocoLocale._Someone = '其他人'
PocoLocale._hours = '小时'
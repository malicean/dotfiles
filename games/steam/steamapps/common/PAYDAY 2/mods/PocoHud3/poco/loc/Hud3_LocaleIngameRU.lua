-- За коррекцию перевода спасибо -GoodFarsh-
-- http://steamcommunity.com/id/goodfarsh/

PocoLocale = {}

PocoLocale._BAGS = {
	ammo = 'Патроны',
	medic = 'Аптека',
	body = 'Мешки для трупов',
	fak = 'АПП',
	grenades = 'Метательное'
}

PocoLocale._defaultLocaleData = {
	_client_name = 'PocoHud3',
	_about_trans_fullList = '{Dansk (DA)|Tan}\nNickyFace, DanishDude93\n{Deutsch (DE)|Tan}\nfallenpenguin, Raxdor, GIider, Hoffy,\nNowRiseAgain, Pixelpille, Sithryl,\nValkein, Zee_, baddog_11\n{Español (ES)|Tan}\nNiccy, BurnBabyBurn\n{Français (FR)|Tan}\nChopper385, Dewk Noukem, Lekousin, Shendow\n{Italiano (IT)|Tan}\nOktober, Nitronik\n{Bahasa Indonesia (ID)|Tan}\nPapin Faizal(papin97)\n{Nederlands (NL)|Tan}\nNickolas Cat, Rezqual\n{Norsk (NO)|Tan}\nikoddn\n{Polski (PL_PL)|Tan}\nMartinz, Kuziz, gmaxpl3\n{Português (PT_PT)|Tan}\nBruno \"Personagem\" Tibério, John Ryder\n{Português (PT_BR)|Tan}\ngabsF\n{Русский (RU)|Tan}\ncollboy, Hellsing, troskahtoh\n{Svenska (SV_SE)|Tan}\nTheLovinator, KillYoy, kao172',
	_about_trans_special_thanks_list = '{Overkill|White}\nfor a legendary game {& not kicking my arse off|Silver|0.5}\n{Harfatus|White}\nfor a cool injector\n{Olipro|White}\nfor keeping MOD community alive\n{v00d00 & gir489 & 90e|White}\nfor making me able to learn Lua from the humble ground\n{Arkkat|White}\nfor crashing the game for me at least 50 times since alpha stage\n{Tatsuto|White}\nfor PD2Stats.com API\n{You|Yellow}\nfor keeping me way too busy to go out at weekends {/notreally|Silver|0.5}',

	-- a player converted ____
	_mob_city_swat = 'элитного бойца GenSec',
	_mob_cop = 'полицейского',
	_mob_fbi = 'агента ФБР',
	_mob_fbi_heavy_swat = 'тяжелого SWAT из ФБР',
	_mob_fbi_swat = 'SWAT из ФБР',
	_mob_gangster = 'бандита',
	_mob_gensec = 'охранника GenSec',
	_mob_heavy_swat = 'тяжелого SWAT',
	_mob_security = 'охранника',
	_mob_shield = 'щита',
	_mob_sniper = 'снайпера',
	_mob_spooc = 'клокера',
	_mob_swat = 'SWAT',
	_mob_tank = 'бульдозера',
	_mob_taser = 'тазера',
	_msg_around = 'возле [1]',
	_msg_captured = '[1] взяли в заложники [2]',
	_msg_converted = '[1] конвертировал [2] [3]',
	_msg_downed = '[1] упал',
	_msg_minionLost = '[1] потерял конверта ([2][3])',
	_msg_minionShot = '[1] нанес урон [3] конверту [2]',
	_msg_not_implemented = 'Еще в разработке',
	_msg_replenished = '[1] восстановил здоровье на [2]% [3]',
	_msg_replenishedDown = '(+[1] падение)',
	_msg_replenishedDownPlu = '(+[1] падения)',
	_msg_replenishedDownFak = '(АПП)',
	_msg_used_doctorbag = "[1] used a Doctor Bag (+[2] [3])",
	_msg_used_doctorbag_down = "падение",
	_msg_used_doctorbag_downs = "падения",
	_msg_used_fak = "[1] used a First Aid Kit",
	_msg_usedPistolMessiah = 'Использован "Мессия"',
	_msg_usedPistolMessiahCharges = '[1] раз',
	_msg_usedPistolMessiahChargesPlu = '[1] раз',
	_msg_specOps = 'Предмет из Spec Ops DLC найден',
	_msg_havePagers = 'Можно ответить на [1] пейджер(а)',
	_msg_haveCivilians = 'Можно убить [1] гражданских',
	_opt_chat_desc = '{_opt_chat_desc_1}\n{_opt_chat_desc_2|White|0.5}\n{_opt_chat_desc_3|White|0.6}\n{_opt_chat_desc_4|White|0.7}\n{_opt_chat_desc_5|White|0.8}\n{_opt_chat_desc_6|White|0.9}\n{_opt_chat_desc_7|White}',
	_opt_truncateTags_desc = '{_opt_truncateTags_desc_1} {[Poco]Hud|Tan} > {_Dot|Tan}{Hud|Tan}',
	_vanity_resizeCrimenet = '60%,70%,80%,90%,100%,110%,120%,130%',
}

PocoLocale._drillNames = {
	drill = 'Дрель',
	lance = 'Термобур',
	uload_database = 'Загрузка данных',
	votingmachine2 = 'Взлом голосов',
	hold_download_keys = 'Загрузка ключей', -- Hoxton Breakout
	hold_hack_comp = 'Взлом компьютера', -- Hoxton Breakout Directors PC
	hold_analyze_evidence = 'Анализ улик', -- Hoxton Breakout
	digitalgui = 'Временной замок',
	huge_lance = 'Зверь',
	pd1_drill = 'OVERDRILL', -- First World Bank Overdrill
	cas_copy_usb = 'Список гостей', -- Guest List Download for Golden Grin Casino
	are_laptop = 'Взлом пиротехники', -- Laptop hacking for Alesso Heist
	invisible_interaction_open = 'Взлом',
	process = 'Процесс'
}

PocoLocale._drillNamesGuess = {
	laptop = 'Взлом',
	hack = 'Взлом',
	drill = 'Дрель',
	lance = 'Бур',
	saw = 'Пила',
	load = 'Загрузка',
	copy = 'Копирование'
}

PocoLocale._drillHosts = {
	['d2e9092f3a57cefc'] = 'мини сейфе',
	['e87e439e3e1a7313'] = 'титановом мини-сейфе',
	['ad6fb7a483695e19'] = 'сейфе',
	['dbfbfbb21eddcd30'] = 'титановом сейфе',
	['3e964910f730f3d7'] = 'большом сейфе',
	['246cc067a20249df'] = 'большом титановом сейфе',
	['8834e3a4da3df5c6'] = 'высоком сейфе',
	['e3ab30d889c6db5f'] = 'высоком титановом сейфе',
	['4407f5e571e2f51a'] = 'двери',
	['0afafcebe54ae7c4'] = 'решётчатой двери',
	['1153b673d51ed6ad'] = 'грузовике GenSec',
	['04080fd150a77c7f'] = 'грузовике GenSec',
	['0d07ff22a1333115'] = 'грузовике GenSec',
	['a8715759c090b251'] = 'решётке',
	['a7b371bf0e3fd30a'] = 'грузовике',
	['07e2cf254ef76c5e'] = 'решетке в хранилище',
	['d475830b4e6eda32'] = 'двери хранилища',
	['b2928ed7d5b8797e'] = 'решётчатой двери',
	['43132b0a273df773'] = 'офисной двери',
	['b8ebd1a5a8426e52'] = 'нише с бриллиантом'
}

PocoLocale._drillOn = 'на' -- drill [on] a safe
PocoLocale._drillAlmost = ' - осталось 10 сек.'
PocoLocale._drillDone = ' - выполнено'

PocoLocale._convertOwn = '(своему)'
PocoLocale._handsUp = 'Руки вверх'
PocoLocale._Intimidated = 'Сдался'
PocoLocale._s = ''

PocoLocale._Someone = 'Кто-то'
PocoLocale._hours = 'ч'
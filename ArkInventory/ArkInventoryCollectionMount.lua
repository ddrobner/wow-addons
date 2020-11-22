local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table
local C_MountJournal = _G.C_MountJournal

local loc_id = ArkInventory.Const.Location.Mount
local PLAYER_MOUNT_LEVEL = 20

ArkInventory.Collection.Mount = { }

local collection = {
	
	isInit = false,
	isScanning = false,
	isReady = false,
	
	numTotal = 0,
	numOwned = 0,
	
	cache = { },
	owned = { }, -- [mta] = { } array of all mounts of that type that you own, updated here when scanned
	usable = { }, -- [mta] = { } array of all mounts of that type that you can use at the location you called it, updated via LDB
	
	filter = {
		ignore = false,
		search = nil,
		collected = true,
		uncollected = true,
		family = { },
		source = { },
		backup = false,
	},
	
	
}

local ImportCrossRefTable = {

[1132]={sid=580}, -- Horn of the Timber Wolf
[5656]={sid=458}, -- Brown Horse Bridle
[2411]={sid=470}, -- Black Stallion Bridle
[2414]={sid=472}, -- Pinto Bridle
[-5784]={sid=5784}, -- Felsteed
[5655]={sid=6648}, -- Chestnut Mare Bridle
[5665]={sid=6653}, -- Horn of the Dire Wolf
[5668]={sid=6654}, -- Horn of the Brown Wolf
[5864]={sid=6777}, -- Gray Ram
[5872]={sid=6899}, -- Brown Ram
[5873]={sid=6898}, -- White Ram
[8631]={sid=8394}, -- Reins of the Striped Frostsaber
[8588]={sid=8395}, -- Whistle of the Emerald Raptor
[8627]={sid=10787}, -- Reins of the Nightsaber / Black Nightsaber
[8632]={sid=10789}, -- Reins of the Spotted Frostsaber
[8628]={sid=10792}, -- Reins of the Spotted Nightsaber / Spotted Panther
[8629]={sid=10793}, -- Reins of the Striped Nightsaber
[8591]={sid=10796}, -- Whistle of the Turquoise Raptor
[8592]={sid=10799}, -- Whistle of the Violet Raptor
[8563]={sid=10873}, -- Red Mechanostrider
[8595]={sid=10969}, -- Blue Mechanostrider
[-13819]={sid=13819}, -- Warhorse
[13326]={sid=15779}, -- White Mechanostrider Mod B
[12303]={sid=16055}, -- Reins of the Nightsaber / Black Nightsaber
[12302]={sid=16056}, -- Reins of the Ancient Frostsaber
[12330]={sid=16080}, -- Horn of the Red Wolf
[12351]={sid=16081}, -- Horn of the Arctic Wolf / Winter Wolf
[12354]={sid=16082}, -- Palomino Bridle
[16339]={sid=16082}, -- Commander's Steed / Palomino
[12353]={sid=16083}, -- White Stallion Bridle
[8586]={sid=16084}, -- Whistle of the Mottled Red Raptor
[13086]={sid=17229}, -- Reins of the Winterspring Frostsaber
[13317]={sid=17450}, -- Whistle of the Ivory Raptor
[13321]={sid=17453}, -- Green Mechanostrider
[13322]={sid=17454}, -- Unpainted Mechanostrider
[13327]={sid=17459}, -- Icy Blue Mechanostrider Mod A
[13329]={sid=17460}, -- Frost Ram
[13328]={sid=17461}, -- Black Ram
[13331]={sid=17462}, -- Red Skeletal Horse
[13332]={sid=17463}, -- Blue Skeletal Horse
[13333]={sid=17464}, -- Brown Skeletal Horse
[13334]={sid=17465}, -- Green Skeletal Warhorse
[13335]={sid=17481}, -- Deathcharger's Reins / Rivendare's Deathcharger
[15277]={sid=18989}, -- Gray Kodo
[15290]={sid=18990}, -- Brown Kodo
[15292]={sid=18991}, -- Green Kodo
[15293]={sid=18992}, -- Teal Kodo
[29468]={sid=22717}, -- Black War Steed Bridle
[29466]={sid=22718}, -- Black War Kodo
[29465]={sid=22719}, -- Black Battlestrider
[29467]={sid=22720}, -- Black War Ram
[29472]={sid=22721}, -- Whistle of the Black War Raptor
[29470]={sid=22722}, -- Red Skeletal Warhorse
[29471]={sid=22723}, -- Reins of the Black War Tiger
[29469]={sid=22724}, -- Horn of the Black War Wolf
[-23214]={sid=23214}, -- Charger
[18767]={sid=23219}, -- Reins of the Swift Mistsaber
[-23161]={sid=23161}, -- Dreadsteed
[18766]={sid=23221}, -- Reins of the Swift Frostsaber
[18774]={sid=23222}, -- Swift Yellow Mechanostrider
[18773]={sid=23223}, -- Swift White Mechanostrider
[18772]={sid=23225}, -- Swift Green Mechanostrider
[18776]={sid=23227}, -- Swift Palomino
[18778]={sid=23228}, -- Swift White Steed
[18777]={sid=23229}, -- Swift Brown Steed
[18786]={sid=23238}, -- Swift Brown Ram
[18787]={sid=23239}, -- Swift Gray Ram
[18785]={sid=23240}, -- Swift White Ram
[18788]={sid=23241}, -- Swift Blue Raptor
[18789]={sid=23242}, -- Swift Olive Raptor
[18790]={sid=23243}, -- Swift Orange Raptor
[18791]={sid=23246}, -- Purple Skeletal Warhorse
[18793]={sid=23247}, -- Great White Kodo
[18795]={sid=23248}, -- Great Gray Kodo
[18794]={sid=23249}, -- Great Brown Kodo
[18796]={sid=23250}, -- Horn of the Swift Brown Wolf
[18797]={sid=23251}, -- Horn of the Swift Timber Wolf
[18798]={sid=23252}, -- Horn of the Swift Gray Wolf
[18902]={sid=23338}, -- Reins of the Swift Stormsaber
[19029]={sid=23509}, -- Horn of the Frostwolf Howler
[19030]={sid=23510}, -- Stormpike Battle Charger
[19872]={sid=24242}, -- Swift Razzashi Raptor
[19902]={sid=24252}, -- Swift Zulian Tiger
[21218]={sid=25953,r={zone = {[766]=true,[717]=true}}}, -- Blue Qiraji Resonating Crystal / Blue Qiraji Battle Tank
[21321]={sid=26054,r={zone = {[766]=true,[717]=true}}}, -- Red Qiraji Resonating Crystal / Red Qiraji Battle Tank
[21324]={sid=26055,r={zone = {[766]=true,[717]=true}}}, -- Yellow Qiraji Resonating Crystal / Yellow Qiraji Battle Tank
[21323]={sid=26056,r={zone = {[766]=true,[717]=true}}}, -- Green Qiraji Resonating Crystal / Green Qiraji Battle Tank
[21176]={sid=26656}, -- Black Qiraji Resonating Crystal / Black Qiraji Battle Tank
[23720]={sid=30174}, -- Riding Turtle
[25470]={sid=32235}, -- Golden Gryphon
[25471]={sid=32239}, -- Ebon Gryphon
[25472]={sid=32240}, -- Snowy Gryphon
[25473]={sid=32242}, -- Swift Blue Gryphon
[25474]={sid=32243}, -- Tawny Wind Rider
[25475]={sid=32244}, -- Blue Wind Rider
[25476]={sid=32245}, -- Green Wind Rider
[25477]={sid=32246}, -- Swift Red Wind Rider
[25527]={sid=32289}, -- Swift Red Gryphon
[25528]={sid=32290}, -- Swift Green Gryphon
[25529]={sid=32292}, -- Swift Purple Gryphon
[25531]={sid=32295}, -- Swift Green Wind Rider
[25532]={sid=32296}, -- Swift Yellow Wind Rider
[25533]={sid=32297}, -- Swift Purple Wind Rider
[25596]={sid=32345}, -- Peep's Whistle / Peep the Phoenix Mount
[28936]={sid=33660}, -- Swift Pink Hawkstrider
[-33943]={sid=33943}, -- Flight Form
[28481]={sid=34406}, -- Brown Elekk
[29228]={sid=34790}, -- Reins of the Dark War Talbuk
[28927]={sid=34795}, -- Red Hawkstrider
[29102]={sid=34896}, -- Reins of the Cobalt War Talbuk
[29227]={sid=34896}, -- Reins of the Cobalt War Talbuk
[29103]={sid=34897}, -- Reins of the White War Talbuk
[29231]={sid=34897}, -- Reins of the White War Talbuk
[29104]={sid=34898}, -- Reins of the Silver War Talbuk
[29229]={sid=34898}, -- Reins of the Silver War Talbuk
[29105]={sid=34899}, -- Reins of the Tan War Talbuk
[29230]={sid=34899}, -- Reins of the Tan War Talbuk
[29222]={sid=35018}, -- Purple Hawkstrider
[29220]={sid=35020}, -- Blue Hawkstrider
[29221]={sid=35022}, -- Black Hawkstrider
[29223]={sid=35025}, -- Swift Green Hawkstrider
[29224]={sid=35027}, -- Swift Purple Hawkstrider
[34129]={sid=35028}, -- Swift Warstrider
[30480]={sid=36702}, -- Fiery Warhorse's Reins
[29744]={sid=35710}, -- Gray Elekk
[29743]={sid=35711}, -- Purple Elekk
[29746]={sid=35712}, -- Great Green Elekk
[29745]={sid=35713}, -- Great Blue Elekk
[29747]={sid=35714}, -- Great Purple Elekk
[30609]={sid=37015}, -- Swift Nether Drake
[31829]={sid=39315}, -- Reins of the Cobalt Riding Talbuk
[31830]={sid=39315}, -- Reins of the Cobalt Riding Talbuk
[28915]={sid=39316}, -- Reins of the Dark Riding Talbuk
[31831]={sid=39317}, -- Reins of the Silver Riding Talbuk
[31832]={sid=39317}, -- Reins of the Silver Riding Talbuk
[31833]={sid=39318}, -- Reins of the Tan Riding Talbuk
[31834]={sid=39318}, -- Reins of the Tan Riding Talbuk
[31835]={sid=39319}, -- Reins of the White Riding Talbuk
[31836]={sid=39319}, -- Reins of the White Riding Talbuk
[32314]={sid=39798}, -- Green Riding Nether Ray
[32317]={sid=39800}, -- Red Riding Nether Ray
[32316]={sid=39801}, -- Purple Riding Nether Ray
[32318]={sid=39802}, -- Silver Riding Nether Ray
[32319]={sid=39803}, -- Blue Riding Nether Ray
[32458]={sid=40192}, -- Ashes of Al'ar
[32768]={sid=41252}, -- Reins of the Raven Lord
[32857]={sid=41513}, -- Reins of the Onyx Netherwing Drake
[32858]={sid=41514}, -- Reins of the Azure Netherwing Drake
[32859]={sid=41515}, -- Reins of the Cobalt Netherwing Drake
[32860]={sid=41516}, -- Reins of the Purple Netherwing Drake
[32861]={sid=41517}, -- Reins of the Veridian Netherwing Drake
[32862]={sid=41518}, -- Reins of the Violet Netherwing Drake
[49283]={sid=42776}, -- Reins of the Spectral Tiger
[49284]={sid=42777}, -- Reins of the Swift Spectral Tiger
[33809]={sid=43688}, -- Amani War Bear
[33976]={sid=43899}, -- Brewfest Ram
[33977]={sid=43900}, -- Swift Brewfest Ram
[33999]={sid=43927}, -- Cenarion War Hippogryph
[34061]={sid=44151}, -- Turbo-Charged Flying Machine Control
[34060]={sid=44153}, -- Flying Machine Control
[34092]={sid=44744}, -- Merciless Nether Drake
[49285]={sid=46197}, -- X-51 Nether-Rocket
[49286]={sid=46199}, -- X-51 Nether-Rocket X-TREME
[35513]={sid=46628}, -- Swift White Hawkstrider
[37012]={sid=48025}, -- The Horseman's Reins / Headless Horseman's Mount
[35906]={sid=48027}, -- Reins of the Black War Elekk
[37676]={sid=49193}, -- Vengeful Nether Drake
[37719]={sid=49322}, -- Swift Zhevra
[37828]={sid=49379}, -- Great Brewfest Kodo
[37827]={sid=50869}, -- Brewfest Kodo
[49282]={sid=51412}, -- Big Battle Bear
[40775]={sid=54729}, -- Winged Steed of the Ebon Blade / Death Knight
[43962]={sid=54753}, -- Reins of the White Polar Bear
[41508]={sid=55531}, -- Mechano-hog
[43516]={sid=58615}, -- Brutal Nether Drake
[43599]={sid=58983}, -- Big Blizzard Bear
[43952]={sid=59567}, -- Reins of the Azure Drake
[43953]={sid=59568}, -- Reins of the Blue Drake
[43951]={sid=59569}, -- Reins of the Bronze Drake
[43955]={sid=59570}, -- Reins of the Red Drake
[43954]={sid=59571}, -- Reins of the Twilight Drake
[-59572]={sid=59572}, -- Black Polar Bear
[43986]={sid=59650}, -- Reins of the Black Drake
[43956]={sid=59785}, -- Reins of the Black War Mammoth
[44077]={sid=59788}, -- Reins of the Black War Mammoth
[44230]={sid=59791}, -- Reins of the Wooly Mammoth
[44231]={sid=59793}, -- Reins of the Wooly Mammoth
[44080]={sid=59797}, -- Reins of the Ice Mammoth
[43958]={sid=59799}, -- Reins of the Ice Mammoth
[44160]={sid=59961}, -- Reins of the Red Proto-Drake
[44164]={sid=59976}, -- Reins of the Black Proto-Drake
[44151]={sid=59996}, -- Reins of the Blue Proto-Drake
[44168]={sid=60002}, -- Reins of the Time-Lost Proto-Drake
[44175]={sid=60021}, -- Reins of the Plagued Proto-Drake
[44177]={sid=60024}, -- Reins of the Violet Proto-Drake
[44178]={sid=60025}, -- Reins of the Albino Drake
[44225]={sid=60114}, -- Reins of the Armored Brown Bear
[44226]={sid=60116}, -- Reins of the Armored Brown Bear
[44223]={sid=60118}, -- Reins of the Black War Bear
[44224]={sid=60119}, -- Reins of the Black War Bear
[44413]={sid=60424}, -- Mekgineer's Chopper
[44689]={sid=61229}, -- Armored Snowy Gryphon
[44690]={sid=61230}, -- Armored Blue Wind Rider
[44707]={sid=61294}, -- Reins of the Green Proto-Drake
[44558]={sid=61309}, -- Magnificent Flying Carpet
[44235]={sid=61425}, -- Reins of the Traveler's Tundra Mammoth
[44234]={sid=61447}, -- Reins of the Traveler's Tundra Mammoth
[44554]={sid=61451}, -- Flying Carpet
[43959]={sid=61465}, -- Reins of the Grand Black War Mammoth
[44083]={sid=61467}, -- Reins of the Grand Black War Mammoth
[44086]={sid=61469}, -- Reins of the Grand Ice Mammoth
[43961]={sid=61470}, -- Reins of the Grand Ice Mammoth
[44843]={sid=61996}, -- Blue Dragonhawk Mount
[44842]={sid=61997}, -- Red Dragonhawk Mount
[45125]={sid=63232}, -- Stormwind Steed
[45593]={sid=63635}, -- Darkspear Raptor
[45586]={sid=63636}, -- Ironforge Ram
[45591]={sid=63637}, -- Darnassian Nightsaber
[45589]={sid=63638}, -- Gnomeregan Mechanostrider
[45590]={sid=63639}, -- Exodar Elekk
[45595]={sid=63640}, -- Orgrimmar Wolf
[45592]={sid=63641}, -- Thunder Bluff Kodo
[45596]={sid=63642}, -- Silvermoon Hawkstrider
[45597]={sid=63643}, -- Forsaken Warhorse
[45693]={sid=63796}, -- Mimiron's Head
[45725]={sid=63844}, -- Argent Hippogryph
[45801]={sid=63956}, -- Reins of the Ironbound Proto-Drake
[45802]={sid=63963}, -- Reins of the Rusted Proto-Drake
[46101]={sid=64656}, -- Blue Skeletal Warhorse
[46100]={sid=64657}, -- White Kodo
[46099]={sid=64658}, -- Horn of the Black Wolf
[46102]={sid=64659}, -- Whistle of the Venomhide Ravasaur
[46109]={sid=64731}, -- Sea Turtle
[46708]={sid=64927}, -- Deadly Gladiator's Frost Wyrm
[46308]={sid=64977}, -- Black Skeletal Horse
[46171]={sid=65439}, -- Furious Gladiator's Frost Wyrm
[46745]={sid=65637}, -- Great Red Elekk
[46744]={sid=65638}, -- Swift Moonsaber
[46751]={sid=65639}, -- Swift Red Hawkstrider
[46752]={sid=65640}, -- Swift Gray Steed
[46750]={sid=65641}, -- Great Golden Kodo
[46747]={sid=65642}, -- Turbostrider
[46748]={sid=65643}, -- Swift Violet Ram
[46743]={sid=65644}, -- Swift Purple Raptor
[46746]={sid=65645}, -- White Skeletal Warhorse
[46749]={sid=65646}, -- Swift Burgundy Wolf
[49290]={sid=65917}, -- Magic Rooster Egg / Magic Rooster
[46813]={sid=66087}, -- Silver Covenant Hippogryph
[46814]={sid=66088}, -- Sunreaver Dragonhawk
[46815]={sid=66090}, -- Quel'dorei Steed
[46816]={sid=66091}, -- Sunreaver Hawkstrider
[47100]={sid=66847}, -- Reins of the Striped Dawnsaber
[47101]={sid=66846}, -- Ochre Skeletal Warhorse
[47179]={sid=66906}, -- Argent Charger / Paladin
[47840]={sid=67336}, -- Relentless Gladiator's Frost Wyrm
[47180]={sid=67466}, -- Argent Warhorse
[49046]={sid=68056}, -- Swift Horde Wolf
[49044]={sid=68057}, -- Swift Alliance Steed
[49096]={sid=68187}, -- Crusader's White Warhorse
[49098]={sid=68188}, -- Crusader's Black Warhorse
[49636]={sid=69395}, -- Reins of the Onyxian Drake
[50250]={sid=71342}, -- Big Love Rocket
[50435]={sid=71810}, -- Wrathful Gladiator's Frost Wyrm
[50818]={sid=72286}, -- Invincible's Reins
[51955]={sid=72807}, -- Reins of the Icebound Frostbrood Vanquisher
[51954]={sid=72808}, -- Reins of the Bloodbathed Frostbrood Vanquisher
[52200]={sid=73313}, -- Reins of the Crimson Deathcharger
[54069]={sid=74856}, -- Blazing Hippogryph
[74269]={sid=74856}, -- Blazing Hippogryph
[54068]={sid=74918}, -- Wooly White Rhino
[54465]={sid=75207,r={zone = {[613]=true,[610]=true,[615]=true,[614]=true}}}, -- Abyssal Seahorse
[54797]={sid=75596}, -- Frosty Flying Carpet
[54811]={sid=75614}, -- Celestial Steed
[54860]={sid=75973}, -- X-53 Touring Rocket
[60954]={sid=84751}, -- Fossilized Raptor
[62461]={sid=87090}, -- Goblin Trike Key
[62462]={sid=87091}, -- Goblin Turbo-Trike Key
[62900]={sid=88331}, -- Reins of the Volcanic Stone Drake
[62901]={sid=88335}, -- Reins of the Drake of the East Wind
[63042]={sid=88718}, -- Reins of the Phosphorescent Stone Drake
[63039]={sid=88741}, -- Reins of the Drake of the West Wind
[65356]={sid=88741}, -- Reins of the Drake of the West Wind
[63040]={sid=88742}, -- Reins of the Drake of the North Wind
[63041]={sid=88744}, -- Reins of the Drake of the South Wind
[63043]={sid=88746}, -- Reins of the Vitreous Stone Drake
[63044]={sid=88748}, -- Reins of the Brown Riding Camel
[63045]={sid=88749}, -- Reins of the Tan Riding Camel
[63046]={sid=88750}, -- Reins of the Grey Riding Camel
[63125]={sid=88990}, -- Reins of the Dark Phoenix
[62298]={sid=90621}, -- Reins of the Golden King
[64883]={sid=92155}, -- Scepter of Azj'Aqir / Ultramarine Qiraji Battle Tank
[64998]={sid=92231}, -- Reins of the Spectral Steed
[64999]={sid=92232}, -- Reins of the Spectral Wolf
[65891]={sid=93326}, -- Vial of the Sands / Sandstone Drake
[68008]={sid=93623}, -- Mottled Drake
[67107]={sid=93644}, -- Reins of the Kron'Kar Annihilator
[68823]={sid=96491}, -- Armored Razzashi Raptor
[68824]={sid=96499}, -- Swift Zulian Panther
[68825]={sid=96503}, -- Amani Dragonhawk
[69213]={sid=97359}, -- Flameward Hippogryph
[69224]={sid=97493}, -- Smoldering Egg of Millagazor / Pureblood Fire Hawk
[69226]={sid=97501}, -- Green Fire Hawk Mount / Green Fire Hawk
[69230]={sid=97560}, -- Corrupted Egg of Millagazor / Corrupted Fire Hawk
[69228]={sid=97581}, -- Savage Raptor
[69747]={sid=98204}, -- Amani Battle Bear
[67151]={sid=98718}, -- Reins of Poseidus / Subdued Seahorse
[69846]={sid=98727}, -- Winged Guardian
[71339]={sid=101282}, -- Vicious Gladiator's Twilight Drake
[71665]={sid=101542}, -- Flametalon of Alysrazor
[71718]={sid=101573}, -- Swift Shorestrider
[71954]={sid=101821}, -- Ruthless Gladiator's Twilight Drake
[70909]={sid=100332}, -- Vicious War Steed
[70910]={sid=100333}, -- Vicious War Wolf
[72140]={sid=102346}, -- Swift Forest Strider
[-102349]={sid=102349}, -- Swift Springstrider
[72146]={sid=102350}, -- Swift Lovebird
[72575]={sid=102488}, -- White Riding Camel
[72582]={sid=102514}, -- Corrupted Hippogryph
[73766]={sid=103081}, -- Darkmoon Dancing Bear
[73838]={sid=103195}, -- Mountain Horse
[73839]={sid=103196}, -- Swift Mountain Horse
[76755]={sid=107203}, -- Tyrael's Charger
[76889]={sid=107516}, -- Spectral Gryphon
[76902]={sid=107517}, -- Spectral Wind Rider
[77067]={sid=107842}, -- Reins of the Blazing Drake
[77068]={sid=107844}, -- Reins of the Twilight Harbinger
[77069]={sid=107845}, -- Life-Binder's Handmaiden
[78919]={sid=110039}, -- Experiment 12-B
[78924]={sid=110051}, -- Heart of the Aspects
[79771]={sid=113120}, -- Feldrake
[79802]={sid=113199}, -- Reins of the Jade Cloud Serpent
[81354]={sid=118089}, -- Reins of the Azure Water Strider
[81559]={sid=118737}, -- Pandaren Kite String
[82453]={sid=120043}, -- Jeweled Onyx Panther
[82765]={sid=120395}, -- Reins of the Green Dragon Turtle
[91004]={sid=120395}, -- Reins of the Green Dragon Turtle
[82811]={sid=120822}, -- Reins of the Great Red Dragon Turtle
[91010]={sid=120822}, -- Reins of the Great Red Dragon Turtle
[91016]={sid=120822}, -- Reins of the Great Red Dragon Turtle
[83086]={sid=121820}, -- Heart of the Nightwing / Obsidian Nightwing
[83090]={sid=121836}, -- Sapphire Panther
[83088]={sid=121837}, -- Jade Panther
[83087]={sid=121838}, -- Ruby Panther
[83089]={sid=121839}, -- Sunstone Panther
[84101]={sid=122708}, -- Reins of the Grand Expedition Yak
[84728]={sid=123160}, -- Reins of the Crimson Riding Crane
[84753]={sid=123182}, -- Reins of the White Riding Yak
[85262]={sid=123886}, -- Reins of the Amber Scorpion
[85430]={sid=123992}, -- Reins of the Azure Cloud Serpent
[85429]={sid=123993}, -- Reins of the Golden Cloud Serpent
[85666]={sid=124408}, -- Reins of the Thundering Jade Cloud Serpent
[85785]={sid=124550}, -- Cataclysmic Gladiator's Twilight Drake
[85870]={sid=124659}, -- Imperial Quilen
[87250]={sid=126507}, -- Depleted-Kyparium Rocket
[87251]={sid=126508}, -- Geosynchronous World Spinner
[87768]={sid=127154}, -- Reins of the Onyx Cloud Serpent
[87769]={sid=127156}, -- Reins of the Crimson Cloud Serpent
[87771]={sid=127158}, -- Reins of the Heavenly Onyx Cloud Serpent
[87773]={sid=127161}, -- Reins of the Heavenly Crimson Cloud Serpent
[87774]={sid=127164}, -- Reins of the Heavenly Golden Cloud Serpent
[87775]={sid=127165}, -- Reins of the Heavenly Jade Cloud Serpent
[87776]={sid=127169}, -- Reins of the Heavenly Azure Cloud Serpent
[87777]={sid=127170}, -- Reins of the Astral Cloud Serpent
[87781]={sid=127174}, -- Reins of the Azure Riding Crane
[87782]={sid=127176}, -- Reins of the Golden Riding Crane
[87783]={sid=127177}, -- Reins of the Regal Riding Crane
[87784]={sid=127178}, -- Jungle Riding Crane
[87785]={sid=127180}, -- Reins of the Albino Riding Crane
[87786]={sid=127209}, -- Reins of the Black Riding Yak
[87787]={sid=127213}, -- Reins of the Brown Riding Yak
[87788]={sid=127216}, -- Reins of the Grey Riding Yak
[87789]={sid=127220}, -- Reins of the Blonde Riding Yak
[87791]={sid=127271}, -- Reins of the Crimson Water Strider
[87792]={sid=127272}, -- Reins of the Orange Water Strider
[87793]={sid=127274}, -- Reins of the Jade Water Strider
[87794]={sid=127278}, -- Reins of the Golden Water Strider
[87795]={sid=127286}, -- Reins of the Black Dragon Turtle
[91008]={sid=127286}, -- Reins of the Black Dragon Turtle
[87796]={sid=127287}, -- Reins of the Blue Dragon Turtle
[91009]={sid=127287}, -- Reins of the Blue Dragon Turtle
[87797]={sid=127288}, -- Reins of the Brown Dragon Turtle
[91005]={sid=127288}, -- Reins of the Brown Dragon Turtle
[87799]={sid=127289}, -- Reins of the Purple Dragon Turtle
[91006]={sid=127289}, -- Reins of the Purple Dragon Turtle
[87800]={sid=127290}, -- Reins of the Red Dragon Turtle
[91007]={sid=127290}, -- Reins of the Red Dragon Turtle
[87801]={sid=127293}, -- Reins of the Great Green Dragon Turtle
[91012]={sid=127293}, -- Reins of the Great Green Dragon Turtle
[87802]={sid=127295}, -- Reins of the Great Black Dragon Turtle
[91011]={sid=127295}, -- Reins of the Great Black Dragon Turtle
[87803]={sid=127302}, -- Reins of the Great Blue Dragon Turtle
[91013]={sid=127302}, -- Reins of the Great Blue Dragon Turtle
[87804]={sid=127308}, -- Reins of the Great Brown Dragon Turtle
[91014]={sid=127308}, -- Reins of the Great Brown Dragon Turtle
[87805]={sid=127310}, -- Reins of the Great Purple Dragon Turtle
[91015]={sid=127310}, -- Reins of the Great Purple Dragon Turtle
[89154]={sid=129552}, -- Reins of the Crimson Pandaren Phoenix
[89304]={sid=129918}, -- Reins of the Thundering August Cloud Serpent
[89305]={sid=129932}, -- Reins of the Green Shado-Pan Riding Tiger
[89307]={sid=129934}, -- Reins of the Blue Shado-Pan Riding Tiger
[89306]={sid=129935}, -- Reins of the Red Shado-Pan Riding Tiger
[89362]={sid=130086}, -- Reins of the Brown Riding Goat
[89363]={sid=130092}, -- Disc of the Red Flying Cloud
[89390]={sid=130137}, -- Reins of the White Riding Goat
[89391]={sid=130138}, -- Reins of the Black Riding Goat
[89783]={sid=130965}, -- Son of Galleon's Saddle
[89785]={sid=130985}, -- Pandaren Kite String
[90655]={sid=132036}, -- Reins of the Thundering Ruby Cloud Serpent
[90710]={sid=132117}, -- Reins of the Ashen Pandaren Phoenix
[90711]={sid=132118}, -- Reins of the Emerald Pandaren Phoenix
[90712]={sid=132119}, -- Reins of the Violet Pandaren Phoenix
[-133023]={sid=133023}, -- Jade Pandaren Kite
[-134359]={sid=134359}, -- Sky Golem
[-135418]={sid=135418}, -- Grand Armored Wyvern
[-136164]={sid=136164}, -- Grand Wyvern
[-136400]={sid=136400}, -- Armored Skyscreamer
[-136471]={sid=136471}, -- Spawn of Horridon
[-136505]={sid=136505}, -- Ghastly Charger
[-138423]={sid=138423}, -- Cobalt Primordial Direhorn
[-138424]={sid=138424}, -- Amber Primardial Direhorn
[-138425]={sid=138425}, -- Slate Primordial Direhorn
[-138426]={sid=138426}, -- Jade Primordial Direhorn
[-138640]={sid=138640}, -- Bone-White Primal Raptor
[-138641]={sid=138641}, -- Red Primal Raptor
[-138642]={sid=138642}, -- Black Primal Raptor
[-138643]={sid=138643}, -- Green Primal Raptor
[-139442]={sid=139442}, -- Thundering Cobalt Cloud Serpent
[-139448]={sid=139448}, -- Clutch of Ji-Kun
[-140250]={sid=140250}, -- Crimson Primordial Direhorn
[-142266]={sid=142266}, -- Armored Red Dragonhawk
[-142641]={sid=142641}, -- Brawler's Burly Mushan Beast
[-148392]={sid=148392}, -- Spawn of Galakras
[-148396]={sid=148396}, -- Kor'kron War Wolf
[-148417]={sid=148417}, -- Kor'kron Juggernaut
[-148428]={sid=148428}, -- Ashhide Mushan Beast
[-148476]={sid=148476}, -- Thundering Onyx Cloud Serpent
[115363]={sid=169952}, -- Creeping Carpet
[116771]={sid=171828}, -- Solar Spirehawk
[108883]={sid=171844}, -- Riding Harness / Dustmane Direwolf
[116788]={sid=171845}, -- Warlord's Deathwheel
[118676]={sid=175700}, -- Reins of the Emerald Drake
[122703]={sid=179244}, -- Chauffeured Chopper / Chauffeured Mechano-Hog (Horde)
[120968]={sid=179245}, -- Chauffeured Chopper / Chauffeured Mekgineer's Chopper (Alliance)
[-179478]={sid=179478}, -- Voidtalon of the Dark Star
[122469]={sid=180545}, -- Mystic Runesaber
[123890]={sid=182912}, -- Felsteel Annihilator
[123974]={sid=183117}, -- Corrupted Dreadwing
[124089]={sid=183889}, -- Vicious War Mechanostrider
[124540]={sid=185052}, -- Vicious War Kodo
[127140]={sid=186305}, -- Infernal Direwolf
[128277]={sid=186828}, -- Primal Gladiator's Felblood Gronnling
[128281]={sid=189043}, -- Wild Gladiator's Felblood Gronnling
[128282]={sid=189044}, -- Warmongering Gladiator's Felblood Gronnling
[128311]={sid=189364}, -- Coalfist Gronnling
[128425]={sid=189998}, -- Illidari Felstalker
[128422]={sid=189999}, -- Grove Warden
[128480]={sid=190690}, -- Bristling Hellboar
[128481]={sid=190690}, -- Bristling Hellboar
[128526]={sid=190977}, -- Deathtusk Felboar
[128527]={sid=190977}, -- Deathtusk Felboar
[128671]={sid=191314}, -- Minion of Grumpus
[128706]={sid=191633}, -- Soaring Skyterror
[129923]={sid=194464}, -- Eclipse Dragonhawk
[133543]={sid=201098}, -- Infinite Timereaver
[-215545]={sid=215545}, -- Fel Bat (Test)

-- 22248 7.0.3
[140228]={sid=222202}, -- Prestigious Bronze Courser
[140232]={sid=222237}, -- Prestigious Forest Courser
[140233]={sid=222238}, -- Prestigious Ivory Courser
[140407]={sid=222241}, -- Prestigious Midnight Courser
[140408]={sid=222240}, -- Prestigious Azure Courser
[140230]={sid=222236}, -- Prestigious Royal Courser
[131734]={sid=196681}, -- Spirit of Eche'ro
[137570]={sid=213115}, -- Bloodfang Widow
[137574]={sid=213134}, -- Felblaze Infernal
[137575]={sid=171827}, -- Hellfire Infernal
[137576]={sid=171840}, -- Coldflame Infernal
[137577]={sid=213158}, -- Predatory Bloodgazer
[137578]={sid=213163}, -- Snowfeather Hunter
[137579]={sid=213164}, -- Brilliant Direbeak
[137580]={sid=213165}, -- Viridian Sharptalon
[137614]={sid=213350}, -- Frostshard Infernal
[137615]={sid=213349}, -- Flarecore Infernal
[137686]={sid=213209}, -- Steelbound Devourer
[138201]={sid=223018}, -- Fathom Dweller
[138258]={sid=215159}, -- Long-Forgotten Hippogryph
[138387]={sid=215558}, -- Ratstallion
[141216]={sid=193007}, -- Grove Defiler
[141217]={sid=225765}, -- Leyfeather Hippogryph
[141843]={sid=227986}, -- Vindictive Gladiator's Storm Dragon
[141844]={sid=227988}, -- Fearless Gladiator's Storm Dragon
[141845]={sid=227989}, -- Cruel Gladiator's Storm Dragon
[141846]={sid=227991}, -- Ferocious Gladiator's Storm Dragon
[141847]={sid=227994}, -- Fierce Gladiator's Storm Dragon
[141848]={sid=227995}, -- Demonic Gladiator's Storm Dragon
[129962]={sid=213339}, -- Great Northern Elderhorn
[137573]={sid=171850}, -- Llothien Prowler
[138811]={sid=214791}, -- Brinedeep Bottom-Feeder
[129280]={sid=193695}, -- Prestigious War Steed
[140348]={sid=223363}, -- Vicious Warstrider
[140350]={sid=223578}, -- Vicious War Elekk
[140353]={sid=223341}, -- Vicious Gilnean Warhorse
[140354]={sid=223354}, -- Vicious War Trike
[141713]={sid=227956}, -- Arcadian War Turtle
[129744]={sid=142910}, -- Ironbound Wraithcharger
[140500]={sid=223814}, -- Mechanized Lumber Extractor

-- 22731 7.1.0
[142436]={sid=230987}, -- Arcanist's Manasaber
[142552]={sid=231428}, -- Smoldering Ember Wyrm
[142403]={sid=230844}, -- Rockspine Basilisk
[142236]={sid=229499}, -- Midnight
[142398]={sid=228919}, -- Darkwater Skate
[142369]={sid=230401}, -- White Hawkstrider

-- 22864 7.1.0
[143864]={sid=204166}, -- Prestigious War Wolf

-- 23436 7.2.0
[143503]={sid=231587}, -- Highlord's Vengeful Charger
[142224]={sid=229377}, -- High Priest's Lightsworn Seeker
[142226]={sid=229438}, -- Huntmaster's Fierce Wolfhawk
[142227]={sid=229386}, -- Huntmaster's Loyal Wolfhawk
[142228]={sid=229439}, -- Huntmaster's Dire Wolfhawk
[142231]={sid=229387}, -- Deathlord's Vilebrood Vanquisher
[142232]={sid=229388}, -- Battlelord's Bloodthirsty War Wyrm
[142233]={sid=238454}, -- Netherlord's Accursed Wrathsteed
[143489]={sid=231442}, -- Farseer's Raging Tempest
[143490]={sid=231525}, -- Shadowblade's Crimson Omen
[143491]={sid=231524}, -- Shadowblade's Baneful Omen
[143492]={sid=231523}, -- Shadowblade's Lethal Omen
[143493]={sid=231434}, -- Shadowblade's Murderous Omen
[143502]={sid=231435}, -- Highlord's Golden Charger
[142225]={sid=229385}, -- Ban-Lu, Grandmaster's Companion
[143504]={sid=231588}, -- Highlord's Vigilant Charger
[143505]={sid=231589}, -- Highlord's Valorous Charger
[143637]={sid=238452}, -- Netherlord's Brimstone Wrathsteed
[143638]={sid=231437}, -- Archdruid's Lunarwing Form
[143643]={sid=232519}, -- Abyss Worm
[143764]={sid=233364}, -- Leywoven Flying Carpet
[142234]={sid=229487}, -- Vicious War Bear
[142235]={sid=229486}, -- Vicious War Bear
[142237]={sid=229512}, -- Vicious War Lion
[142437]={sid=230988}, -- Vicious War Scorpion
[143648]={sid=232523}, -- Vicious War Turtle
[143649]={sid=232525}, -- Vicious War Turtle
[143752]={sid=230844}, -- Brawler's Burly Basilisk

-- 23623 7.2.0
[147804]={sid=242875}, -- Wild Dreamrunner
[147805]={sid=242882}, -- Valarjar Stormwing
[147806]={sid=242881}, -- Cloudwing Hippogryph
[147807]={sid=242874}, -- Highmountain Elderhorn

-- 23657 7.2.0
[147835]={sid=243025}, -- Riddler's Mind-Worm

-- 23801 7.2.0
[143631]={sid=232405}, -- Primal Flamesaber

-- 24484 7.3.0
[151623]={sid=247402}, -- Lucid Nightmare

-- 24608 7.3.0
[152814]={sid=253058}, -- Maddened Chaosrunner
[152788]={sid=239013}, -- Lightforged Warframe
[152790]={sid=243652}, -- Vile Fiend
[152791]={sid=242305}, -- Sable Ruinstrider
[152793]={sid=253006}, -- Russet Ruinstrider
[152794]={sid=253004}, -- Amethyst Ruinstrider
[152795]={sid=253005}, -- Beryl Ruinstrider
[152796]={sid=253008}, -- Umber Ruinstrider
[152797]={sid=253007}, -- Cerulean Ruinstrider
[152789]={sid=243651}, -- Shackled Ur'zul
[152815]={sid=253087}, -- Antoran Gloomhound
[152816]={sid=253088}, -- Antoran Charhound
[152840]={sid=253109}, -- Scintillating Mana Ray
[152841]={sid=253108}, -- Felglow Mana Ray
[152842]={sid=253106}, -- Vibrant Mana Ray
[152843]={sid=235764}, -- Darkspore Mana Ray
[152844]={sid=253107}, -- Lambent Mana Ray
[152869]={sid=242897}, -- Vicious War Fox
[152870]={sid=242896}, -- Vicious War Fox

-- 24651 7.3.0
[152901]={sid=253639}, -- Violet Spellwing
[152903]={sid=253660}, -- Biletooth Gnasher
[152904]={sid=253662}, -- Acid Belcher
[152905]={sid=253661}, -- Crimson Slavermaw
[152912]={sid=253711}, -- Pond Nettle

-- 24727 7.3.0
[153041]={sid=254260}, -- Bleakhoof Ruinstrider
[153042]={sid=254069}, -- Glorious Felcrusher
[153043]={sid=254258}, -- Blessed Felcrusher
[153044]={sid=254259}, -- Avenging Felcrusher

-- 24781 7.3.0
[147901]={sid=243512}, -- Luminous Starseeker
[153485]={sid=247448}, -- Darkmoon Dirigible

-- 25021 7.3.0
[151617]={sid=245725}, -- Orgrimmar Interceptor
[151618]={sid=245723}, -- Stormwind Skychaser

-- 25326 7.3.2
[153493]={sid=243201}, -- Demonic Gladiator's Storm Dragon

-- 25600 7.3.5
[155656]={sid=258022}, -- Lightforged Felcrusher
[155662]={sid=258060}, -- Highmountain Thunderhoof
[156486]={sid=259202}, -- Starcursed Voidstrider
[156487]={sid=258845}, -- Nightborne Manasaber

-- 25902 8.0.1
[156879]={sid=262022}, -- Dread Gladiator's Proto-Drake
[156880]={sid=262023}, -- Blue Gladiator's Proto-Drake
[156881]={sid=262024}, -- Purple Gladiator's Proto-Drake
[156882]={sid=262025}, -- Pale Gladiator's Proto-Drake
[156883]={sid=262026}, -- Green Gladiator's Proto-Drake
[156884]={sid=262027}, -- Black Gladiator's Proto-Drake
[156885]={sid=262028}, -- Gold Gladiator's Proto-Drake
[156798]={sid=261395}, -- The Hivemind
[157870]={sid=263707}, -- Zandalari Direhorn

-- 25937 7.3.5
[153539]={sid=255695}, -- Seabraid Stallion
[153540]={sid=255696}, -- Gilded Ravasaur

-- 25976 8.0.1
[153594]={sid=256123}, -- Xiwyllag ATV

-- 26032 8.0.1
[159146]={sid=267270}, -- Kua'fon's Harness
[156564]={sid=259395}, -- Shu-Zen, the Divine Sentinel

-- 26175 8.0.1
[159842]={sid=254813}, -- Sharkbait's Favorite Crackers / Sharkbait
[159921]={sid=266058}, -- Mummified Raptor Skull / Tomb Stalker

-- 26433 8.0.1
[160829]={sid=273541}, -- Underrot Crawg Harness / Underrot Crawg

-- 26476 8.0.1
--[161134]={sid=}, -- Mecha-Mogul Mk2
[161215]={sid=239049}, -- Reins of the Obsidian Krolusk
[161330]={sid=267274}, -- Mag'har Direwolf
[161331]={sid=271646}, -- Dark Iron Core Hound

-- 26522 8.0.1
[161774]={sid=275841}, -- Reins of the Expedition Bloodswarmer
[161479]={sid=275623}, -- Nazjatar Blood Serpent
[161665]={sid=275837}, -- Reins of the Cobalt Pterrordax
[161666]={sid=275838}, -- Reins of the Armored Orange Pterrordax
[161667]={sid=275840}, -- Reins of the Armored Albino Pterrordax
[161773]={sid=237287}, -- Reins of the Alabaster Hyena
[161664]={sid=244712}, -- Reins of the Armored Ebony Pterrordax
[161879]={sid=275868}, -- Reins of the Proudmoore Sea Scout
[161908]={sid=275859}, -- Reins of the Dusky Waycrest Gryphon
[161909]={sid=275866}, -- Reins of the Stormsong Coastwatcher
[161910]={sid=260173}, -- Reins of the Smoky Charger
[161911]={sid=259213}, -- Reins of the Admiralty Stallion
[161912]={sid=260172}, -- Reins of the Dapple Gray

-- 26624 8.0.1
[163584]={sid=279466}, -- Twilight Avenger
[163042]={sid=264058}, -- Reins of the Mighty Caravan Brutosaur
[163188]={sid=278979}, -- Surf Jelly
[163573]={sid=260175}, -- Goldenmane's Reins
[163574]={sid=260174}, -- Chewed-On Reins of the Terrified Pack Mule
[163575]={sid=243795}, -- Reins of a Tamed Bloodfeaster / Leaping Veinseeker
[163576]={sid=237286}, -- Captured Dune Scavenger
[163577]={sid=279454}, -- Conquerer's Scythemaw
[163578]={sid=279457}, -- Broken Highland Mustang
[163579]={sid=279456}, -- Highland Mustang
[163582]={sid=279469}, -- Qinsho's Eternal Hound
[163583]={sid=279467}, -- Craghorn Chasm-Leaper
[163063]={sid=278656}, -- Reins of the Spectral Phoenix
[163585]={sid=278979}, -- Surf Jelly
[163586]={sid=254811}, -- Squawks
[163589]={sid=279474}, -- Reins of the Palehide Direhorn
[163121]={sid=261434}, -- Vicious War Basilisk (Horde)
[163122]={sid=261433}, -- Vicious War Basilisk (Alliance)
[163123]={sid=272481}, -- Vicious War Riverbeast
[163124]={sid=270560}, -- Vicious War Clefthoof
[163127]={sid=274610}, -- Smoldering Reins of the Teldrassil Hippogryph (Alliance)
[163128]={sid=272472}, -- War-Torn Reins of the Undercity Plaguebat (Horde)
[163131]={sid=278803}, -- Great Sea Ray
[163183]={sid=259740}, -- Spawn of Krag'wa
[163186]={sid=278966}, -- Tempestuous Skystallion

-- 26714 8.0.1
[163644]={sid=279569}, -- Swift Albino Raptor
[163645]={sid=279611}, -- Skullripper
[163646]={sid=279608}, -- Lil' Donkey
[163706]={sid=279868}, -- Witherbark Direwing

-- 26788 8.0.1
[164250]={sid=281044}, -- Prestigious Bloodforged Courser
--[163981]={sid=______}, -- Frenzied Feltalon
[163982]={sid=280730}, -- Pureheart Courser

-- 27602 8.0.1
[160589]={sid=272770}, -- The Dreadwake

-- 28724 8.0.1
[166428]={sid=288438}, -- Blackpaw
[166432]={sid=288495}, -- Ashenvale Chimaera
[166433]={sid=288499}, -- Frightened Kodo
[166434]={sid=288503}, -- Umber Nightsaber
[166435]={sid=288505}, -- Kaldorei Nightsaber
[166436]={sid=288506}, -- Sandy Nightsaber
[166437]={sid=288505}, -- Kaldorei Nightsaber
[166438]={sid=288438}, -- Blackpaw
[166463]={sid=288740}, -- Priestess' Moonsaber
[166464]={sid=288735}, -- Rubyshell Krolusk
[166465]={sid=288736}, -- Azureshell Krolusk
[166466]={sid=288722}, -- Risen Mare
[166467]={sid=288721}, -- Island Thunderscale
[166468]={sid=288720}, -- Bloodgorged Hunter
[166469]={sid=288714}, -- Bloodthirsty Dreadwing
[166470]={sid=288712}, -- Stonehide Elderhorn
[166471]={sid=288711}, -- Saltwater Seahorse
[166518]={sid=289083}, -- G.M.O.D.
[166539]={sid=289101}, -- Dazar'alor Windreaver
[166705]={sid=289555}, -- Glacial Tidestorm
[166745]={sid=266925}, -- Siltwing Albatross
[166803]={sid=288503}, -- Umber Nightsaber
[165019]={sid=281887}, -- Vicious Black Warsaber
[165020]={sid=281890}, -- Vicious Black Bonesteed
[166417]={sid=237288}, -- Onyx War Hyena
[166442]={sid=288587}, -- Blue Marsh Hopper
[166443]={sid=288589}, -- Yellow Marsh Hopper
[164571]={sid=281554}, -- Meat Wagon
[166775]={sid=290133}, -- Vulpine Familiar

-- 29139 8.0.1
[166774]={sid=290134}, -- Hogrus, Swine of Good Fortune

-- 29701 8.1.5
[168055]={sid=295387}, -- Bloodflank Charger
[168056]={sid=295386}, -- Ironclad Frostclaw
[164762]={sid=282682}, -- Kul Tiran Charger
[167894]={sid=294568}, -- Beastlord's Irontusk
[167895]={sid=294569}, -- Beastlord's Warwolf
[166724]={sid=289639}, -- Bruce



--	sourced from wowhead.com and user feedback
--	https://www.wowhead.com/mount-items/live-only:on?filter=198;29814;0

--	[itemid] = {sid=00000,cid=00000,r={zone restrictions}}

--	sid = spell id for mount
--	r = zone restrictions

}

function ArkInventory.Collection.Mount.ImportCrossRefTable( )
	
	if not ImportCrossRefTable then return end
	if not ArkInventory.Collection.Mount.IsReady( ) then return end
	
	local item, spell, speciesID, key1, key2
	
	for k, v in pairs( ImportCrossRefTable ) do
		
		item = tonumber( k ) or 0
		spell = tonumber( v.sid ) or 0
		
		if item > 0 and spell > 0 then
			
			key1 = ArkInventory.ObjectIDCount( string.format( "item:%s", item ) )
			key2 = ArkInventory.ObjectIDCount( string.format( "spell:%s", spell ) )
			
			--ArkInventory.Output2( key1, " / ", key2 )
			
			if not ArkInventory.Global.ItemCrossReference[key1] then
				ArkInventory.Global.ItemCrossReference[key1] = { }
			end
			ArkInventory.Global.ItemCrossReference[key1][key2] = true
			
			if not ArkInventory.Global.ItemCrossReference[key2] then
				ArkInventory.Global.ItemCrossReference[key2] = { }
			end
			ArkInventory.Global.ItemCrossReference[key2][key1] = true
			
		end
		
	end
	
	ArkInventory.Table.Clean( ImportCrossRefTable )
	ImportCrossRefTable = nil
	
end


-- the UI filters have no impact on the mount source so we can safely ignore them

function ArkInventory.Collection.Mount.OnHide( )
	ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_MOUNT_UPDATE_BUCKET", "FRAME_HIDE" )
end

function ArkInventory.Collection.Mount.IsReady( )
	return collection.isReady
end

function ArkInventory.Collection.Mount.GetCount( mta )
	if mta then
		return ArkInventory.Table.Elements( collection.usable[mta] ), ArkInventory.Table.Elements( collection.owned[mta] )
	else
		return collection.numOwned, collection.numTotal
	end
end

function ArkInventory.Collection.Mount.GetMount( index )
	if type( index ) == "number" then
		return collection.cache[index]
	end
end

function ArkInventory.Collection.Mount.GetUsable( mta )
	if mta then
		return collection.usable[mta]
	end
end

function ArkInventory.Collection.Mount.GetMountBySpell( spellID )
	for _, v in pairs( collection.cache ) do
		if v.spellID == spellID then
			return v
		end
	end
end

function ArkInventory.Collection.Mount.IterateAll( )
	local t = collection.cache
	return ArkInventory.spairs( t, function( a, b ) return ( t[a].name or "" ) < ( t[b].name or "" ) end )
end

function ArkInventory.Collection.Mount.Iterate( mta )
	local t = collection.owned
	if mta and t[mta] then
		return ArkInventory.spairs( t[mta], function( a, b ) return ( t[mta][a].name or "" ) < ( t[mta][b].name or "" ) end )
	end
end

function ArkInventory.Collection.Mount.Dismiss( )
	C_MountJournal.Dismiss( )
end

function ArkInventory.Collection.Mount.Summon( id )
	local obj = ArkInventory.Collection.Mount.GetMount( id )
	if obj then
		C_MountJournal.SummonByID( obj.index )
	end
end

function ArkInventory.Collection.Mount.GetFavorite( id )
	local obj = ArkInventory.Collection.Mount.GetMount( id )
	if obj then
		return C_MountJournal.GetIsFavorite( obj.index )
	end
end

function ArkInventory.Collection.Mount.SetFavorite( id, value )
	-- value = true|false
	local obj = ArkInventory.Collection.Mount.GetMount( id )
	--ArkInventory.Output( id, " / ", value, " (", type(value), ") / ", obj )
	if obj then
		C_MountJournal.SetIsFavorite( obj.index, value )
	end
end

function ArkInventory.Collection.Mount.isUsable( id )
	
	local md = ArkInventory.Collection.Mount.GetMount( id )
	if md then
		local mu = select( 5, C_MountJournal.GetMountInfoByID( id ) ) -- is not always correct
		return IsOutdoors( ) and mu and ( IsUsableSpell( md.spellID ) ) -- so check outdoors, mount, and spell
	end
	
end

function ArkInventory.Collection.Mount.SkillLevel( )
	
	local skill = 1 -- the chauffer and sea tutle mounts can be ridden by anyone reagrdless of riding skill
	
	if UnitLevel( "player" ) >= PLAYER_MOUNT_LEVEL then
		
		if IsSpellKnown( 90265 ) then
			-- master
			-- level 80
			-- 310% flying
			-- 100% ground
			skill = 310
		elseif IsSpellKnown( 34091 ) then
			-- artisan
			-- level 70
			-- 280% flying
			-- 100% ground
			skill = 300
		elseif IsSpellKnown( 34090 ) then
			-- expert
			-- level 60
			-- 150% flying
			-- 100% ground
			skill = 225
		elseif IsSpellKnown( 33391 ) then
			-- journeyman
			-- level 40
			-- 100% ground
			skill = 150
		elseif IsSpellKnown( 33388 ) then
			-- apprentice
			-- level 20
			-- 60% ground
			skill = 75
		end
		
	end
	
	return skill
	
end

function ArkInventory.Collection.Mount.GetEquipmentID( )
	local itemID = C_MountJournal.GetAppliedMountEquipmentID( )
	if itemID then
		itemID = string.format( "item:%s", itemID )
	end
	return itemID
end

function ArkInventory.Collection.Mount.UpdateOwned( )
	
	for mta, mt in pairs( ArkInventory.Const.MountTypes ) do
		if not collection.owned[mta] then
			collection.owned[mta] = { }
		else
			wipe( collection.owned[mta] )
		end
	end
	
	for _, md in ArkInventory.Collection.Mount.IterateAll( ) do
		if md.owned then
			collection.owned[md.mta][md.index] = md
		end
	end
	
end

function ArkInventory.Collection.Mount.UpdateUsable( )
	
	for mta in pairs( ArkInventory.Const.MountTypes ) do
		if not collection.usable[mta] then
			collection.usable[mta] = { }
		else
			wipe( collection.usable[mta] )
		end
	end
	
	if not ArkInventory.Collection.Mount.IsReady( ) then return end
	
	local n = ArkInventory.Collection.Mount.GetCount( )
	if n == 0 then return end
	
	local me = ArkInventory.GetPlayerCodex( )
	
	for mta, mt in pairs( ArkInventory.Const.MountTypes ) do
		
		for _, md in ArkInventory.Collection.Mount.Iterate( mta ) do
			
			local usable = true
			
			if me.player.data.ldb.mounts.type[mta].selected[md.spellID] == false then
				usable = false
			elseif not me.player.data.ldb.mounts.type[mta].useall then
				usable = me.player.data.ldb.mounts.type[mta].selected[md.spellID]
			end
			
			if usable then
				usable = ArkInventory.Collection.Mount.isUsable( md.index )
			end
			
			if usable then
				collection.usable[mta][md.index] = md
			end
			
		end
		
		--ArkInventory.Output( "usable ", mta, " = ", collection.usable[mta] )
		
	end
	
end

function ArkInventory.Collection.Mount.ApplyUserCorrections( )
	
	-- apply user corrections (these are global settings so the mount may not exist for this character)
	
	for _, md in ArkInventory.Collection.Mount.IterateAll( ) do
		
		local correction = ArkInventory.db.option.mount.correction[md.spellID]
		
		if correction ~= nil then -- check for nil as we use both true and false
			if correction == md.mto then
				-- code has been updated, clear correction
				--ArkInventory.Output( "clearing mount correction ", md.spellID, ": system=", md.mt, ", correction=", correction )
				ArkInventory.db.option.mount.correction[md.spellID] = nil
				md.mt = md.mto
			else
				-- apply correction
				--ArkInventory.Output( "correcting mount ", md.spellID, ": system=", md.mt, ", correction=", correction )
				md.mt = correction
				
				for mta, mt in pairs( ArkInventory.Const.MountTypes ) do
					if md.mt == mt then
						md.mta = mta
						break
					end
				end
				
			end
		end
		
	end
	
	ArkInventory.Collection.Mount.UpdateOwned( )
	
end


local function ScanInit( )
	
	collection.isInit = true
	
end

local function Scan_Threaded( thread_id )
	
	local update = false
	
	local numTotal = 0
	local numOwned = 0
	
	--ArkInventory.Output2( "Mount: Start Scan @ ", time( ) )
	
	if not collection.isInit then
		ScanInit( )
		ArkInventory.ThreadYield_Scan( thread_id )
	end
	
	if not collection.isInit then
		-- recheck later
		return
	end
	
	local c = collection.cache
	
	local data_source = C_MountJournal.GetMountIDs( )
	
	for _, index in pairs( data_source ) do
		
		numTotal = numTotal + 1
		
		local name, spellID, icon, isActive, isUsable, source, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID( index )
		local creatureDisplayInfoID, description, source2, isSelfMount, mountTypeID, uiModelSceneID = C_MountJournal.GetMountInfoExtraByID( index )
--		local isFavorite, canSetFavorite = C_MountJournal.GetIsFavorite( i )
		
		local i = mountID
		
		local isOwned = isCollected and not shouldHideOnChar
		
		if isFactionSpecific and not shouldHideOnChar then
			-- faction is either 0 = horde / 1 = alliance
			-- cater for races who are neutral until they choose a faction
			local f0 = -1
			local f1, f2 = UnitFactionGroup( "player" )
			f2 = f2 or FACTION_OTHER
			if f2 == FACTION_HORDE then
				f0 = 0
			elseif f2 == FACTION_ALLIANCE then
				f0 = 1
			end
			if faction ~= f0 then
				shouldHideOnChar = true
				isOwned = false
			end
		end
		
		if not c[i] then
			update = true
			c[i] = { index = index }
		end
		
		if c[i].name ~= name or c[i].index ~= index or c[i].spellID ~= spellID then
			
			update = true
			
			c[i].name = name
			c[i].spellID = spellID
			c[i].icon = icon
			c[i].source = source
			c[i].isFactionSpecific = isFactionSpecific
			c[i].faction = faction
			c[i].creatureDisplayInfoID = creatureDisplayInfoID
			c[i].description = description
			c[i].isSelfMount = isSelfMount
			c[i].mountTypeID = mountTypeID
			c[i].uiModelSceneID = uiModelSceneID
			
			c[i].link = GetSpellLink( spellID )
			
			local mta = "x"
			if mountTypeID == 230 or mountTypeID == 241 or mountTypeID == 284 then
				-- land
				mta = "l"
			elseif mountTypeID == 248 or mountTypeID == 247 or mountTypeID == 242 then
				-- flying
				mta = "a"
			elseif mountTypeID == 231 or mountTypeID == 232 or mountTypeID == 254 then
				--underwater
				mta = "u"
--			elseif mountTypeID == 269 then
--				-- surface
--				mta = "s"
			end
			
			c[i].mta = mta
			c[i].mt = ArkInventory.Const.MountTypes[mta]
			c[i].mto = c[i].mt -- save original mount type (user corrections can override the other value)
			
		end
		
		if c[i].isCollected ~= isCollected then
			update = true
			c[i].isCollected = isCollected
		end
		
		if c[i].isActive ~= isActive then
			update = true
			c[i].isActive = isActive
		end
		
		if c[i].isUsable ~= isUsable then
			update = true
			c[i].isUsable = isUsable
		end
		
		if c[i].isFavorite ~= isFavorite then
			update = true
			c[i].isFavorite = isFavorite
		end
		
		if isOwned then
			numOwned = numOwned + 1
		end
		
		if c[i].owned ~= isOwned then
			update = true
			c[i].owned = isOwned
		end
		
	end
	
	ArkInventory.ThreadYield_Scan( thread_id )
	
	collection.numOwned = numOwned
	collection.numTotal = numTotal
	
	ArkInventory.Collection.Mount.ApplyUserCorrections( )
	
	--ArkInventory.Output2( "Mount: End Scan @ ", time( ), " [", collection.numOwned, "] [", collection.numTotal, "] [", update, "]" )
	
	collection.isReady = true
	
	ArkInventory.Collection.Mount.ImportCrossRefTable( )
	ArkInventory.Collection.Mount.ApplyUserCorrections( )
	
	if update then
		ArkInventory.ScanLocation( loc_id )
--		ArkInventory.LDB.Mounts:Update( )
	end
	
end

local function Scan( )
	
	local thread_id = string.format( ArkInventory.Global.Thread.Format.Collection, "mount" )
	
	if not ArkInventory.Global.Thread.Use then
		local tz = debugprofilestop( )
		ArkInventory.OutputThread( thread_id, " start" )
		Scan_Threaded( )
		tz = debugprofilestop( ) - tz
		ArkInventory.OutputThread( string.format( "%s took %0.0fms", thread_id, tz ) )
		return
	end

	local tf = function ( )
		Scan_Threaded( thread_id )
	end
	
	ArkInventory.ThreadStart( thread_id, tf )
	
end


function ArkInventory:EVENT_ARKINV_COLLECTION_MOUNT_UPDATE_BUCKET( events )
	
	--ArkInventory.Output2( "MOUNT BUCKET [", events, "]" )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if ArkInventory.Global.Mode.Combat then
		-- set to scan when leaving combat
		ArkInventory.Global.LeaveCombatRun[loc_id] = true
		return
	end
	
	if not ArkInventory.isLocationMonitored( loc_id ) then
		--ArkInventory.Output( "IGNORED (MOUNTS NOT MONITORED)" )
		return
	end
	
	if MountJournal:IsVisible( ) then
		--ArkInventory.Output( "ABORTED (MOUNT JOURNAL IS OPEN)" )
		return
	end
	
	if not collection.isScanning then
		collection.isScanning = true
		Scan( )
		collection.isScanning = false
	else
		--ArkInventory.Output( "IGNORED (MOUNT JOURNAL BEING SCANNED - WILL RESCAN WHEN DONE)" )
		ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_MOUNT_UPDATE_BUCKET", "RESCAN" )
	end
	
end

function ArkInventory:EVENT_ARKINV_COLLECTION_MOUNT_UPDATE( event, ... )
	
	if event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED" then
		local arg1 = ...
		if arg1 == "MOUNT" then
			ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_MOUNT_UPDATE_BUCKET", event )
		elseif arg1 == "PET" then
			ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET", event )
		end
	elseif event == "NEW_MOUNT_ADDED" then
		--local arg1 = ... -- mount id
		ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_MOUNT_UPDATE_BUCKET", event )
	end
	
end

function ArkInventory:EVENT_ARKINV_COLLECTION_MOUNT_EQUIPMENT_UPDATE( event )
	local loc_id = ArkInventory.Const.Location.MountEquipment
	ArkInventory.ScanLocation( loc_id )	
end

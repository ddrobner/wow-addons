local _G = _G
local select = _G.select
local pairs = _G.pairs
local ipairs = _G.ipairs
local string = _G.string
local type = _G.type
local error = _G.error
local table = _G.table
local C_PetJournal = _G.C_PetJournal
local C_PetBattles = _G.C_PetBattles

local loc_id = ArkInventory.Const.Location.Pet
local BreedAvailable = IsAddOnLoaded( "BattlePetBreedID" )

ArkInventory.Collection.Pet = { }

local collection = {
	
	isScanning = false,
	isReady = false,
	
	numTotal = 0, -- number of total pets
	numOwned = 0, -- number of owned pets
	
	cache = { }, -- [guid] = { }
	species = { }, -- [speciesID] = { } - all pet types
	ability = { }, -- [abilityID] = { } - all pet types
	creature = { },	-- [creatureID] = speciesID
	
	isTrainerDataLoaded = false,
	trainer = nil, -- linked to ArkInventory.db.cache.trainerspecies when acedb is loaded
	
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

local ImportCrossRefTableAttempt = 0
local ImportCrossRefTable = {

-- xxxxx 1.11.1
[2671]={4401}, -- Mechanical Squirrel Box / Mechanical Squirrel
[7380]={8490}, -- Cat Carrier (Siamese) / Siamese Cat
[7381]={8488}, -- Cat Carrier (Silver Tabby) / Silver Tabby Cat
[7382]={8487}, -- Cat Carrier (Orange Tabby) / Orange Tabby Cat
[7383]={8491},  -- Cat Carrier (Black Tabby) / Black Tabby Cat
[7384]={8486}, -- Cat Carrier (Cornish Rex) / Cornish Rex Cat
[7385]={8485}, -- Cat Carrier (Bombay) / Bombay Cat
[7386]={8489}, -- Cat Carrier (White Kitten) / White Kitten
[7387]={8492},  -- Parrot Cage (Green Wing Macaw) / Green Wing Macaw
[7389]={8495},  -- Parrot Cage (Senegal) / Senegal
[7390]={8496},  -- Parrot Cage (Cockatiel) / Cockatiel
[7391]={8494},  -- Parrot Cage (Hyacinth Macaw) / Hyacinth Macaw
[7394]={11023},  -- Ancona Chicken
[7395]={10393},  -- Undercity Cockroach
[7543]={10822},  -- Dark Whelpling
[7544]={8499},  -- Tiny Crimson Whelpling / Crimson Whelpling
[7545]={8498},  -- Emerald Whelpling
[7549]={11026},  -- Tree Frog Box / Tree Frog
[7550]={11027},  -- Wood Frog Box / Wood Frog
[7553]={8500},  -- Great Horned Owl
[7555]={8501},  -- Hawk Owl
[7560]={8497},  -- Rabbit Crate (Snowshoe) / Snowshoe Rabbit
[7562]={10361},  -- Brown Snake
[7565]={10360},  -- Black Kingsnake
[7567]={10392},  -- Crimson Snake
[8376]={10398},  -- Mechanical Chicken
[9656]={11825},  -- Pet Bombling
[9657]={11826},  -- Lil' Smoky
[9662]={11474},  -- Sprite Darter Egg / Sprite Darter Hatchling
[10259]={12264},  -- Worg Carrier / Worg Pup
[10598]={12529},  -- Smolderweb Carrier / Smolderweb Hatchling
[11325]={13583},  -- Panda Collar / Panda Cub
[11326]={13584},  -- Diablo Stone / Mini Diablo
[11327]={13582},  -- Zergling Leash / Zergling
[12419]={15996},  -- Lifelike Mechanical Toad / Lifelike Toad
[14421]={10394},  -- Prairie Dog Whistle / Brown Prairie Dog
[14878]={19450,19462},  -- Unhatched Jubling Egg > A Jubling's Tiny Home / Jubling
[15186]={20371},  -- Blue Murloc Egg / Murky
[15429]={20769},  -- Disgusting Oozeling
[15698]={21301},  -- Green Helper Box / Father Winter's Helper
[15699]={21277},  -- Tranquil Mechanical Yeti
[15705]={21305},  -- Red Helper Box / Winter's Little Helper
[15706]={21308},  -- Jingling Bell / Winter Reindeer
[15710]={21309},  -- Snowman Kit / Tiny Snowman
[16085]={22235},  -- Truesilver Shafted Arrow / Peddlefeet
[16547]={23002},  -- Turtle Box / Speedy
[16548]={23007},  -- Piglet's Collar / Mr. Wiggles
[16549]={23015},  -- Rat Cage / Whiskers the Rat
[16701]={23083},  -- Captured Flame / Spirit of Summer
[30379]={11110},  -- Chicken Egg / Westfall Chicken

-- xxxxx 1.12.1
[7546]={118675,-10699},  -- Time-Locked Box / Bronze Whelpling
[14755]={19055},  -- Green Dragon Orb / Tiny Green Dragon (chinese servers only)
[14756]={19054},  -- Red Dragon Orb / Tiny Red Dragon (chinese servers only)
[23429]={18964},  -- Turtle Egg (Loggerhead) / Loggerhead Snapjaw

-- xxxxx 2.0.0
[17255]={23713},  -- Hippogryph Hatchling

-- xxxxx 2.0.1
[18839]={27445},  -- Magical Crawdad Box
[20408]={29363},  -- Mana Wyrmling
[20472]={29364},  -- Brown Rabbit Crate
[21008]={29903},  -- Yellow Moth Egg
[21009]={29902},  -- Red Moth Egg
[21010]={29901},  -- Blue Moth Egg
[21018]={29904},  -- White Moth Egg
[21055]={29953},  -- Golden Dragonhawk Hatchling
[21056]={29958},  -- Blue Dragonhawk Hatchling
[21063]={29957},  -- Silver Dragonhawk Hatchling
[21064]={29956},  -- Red Dragonhawk Hatchling
[22445]={31760},  -- Miniwing
[23234]={32588},  -- Banana Charm / Bananas

-- xxxxx 2.1.0
[15358]={30360},  -- Lurky's Egg
[16069]={22114},  -- Pink Murloc Egg / Gurky (EU servers only)
[18381]={25535},  -- Netherwhelp's Collar
[21076]={29960},  -- Captured Firefly
[23231]={32617},  -- Sleepy Willy
[23258]={32616},  -- Egbert's Egg
[23266]={32622},  -- Elekk Training Collar / Peanut

-- xxxxx 2.2.2
[22943]={32233},  -- Wolpertinger's Tankard
[23909]={33154},  -- Sinister Squashling

-- xxxxx 2.3.0
[7547]={34535},  -- Azure Whelpling
[24480]={33993},  -- Mojo
[24968]={34425},  -- Clockwork Rocket Bot
[25062]={34478},  -- Tiny Sporebat
[25109]={34492},  -- Rocket Chicken
[25110]={34493},  -- Dragon Kite

-- xxxxx 2.4.0
[17254]={23712},  -- White Tiger Cub
[24388]={33816},  -- Toothy's Bucket
[24389]={33818},  -- Muckbreath's Bucket
[26050]={35349},  -- Snarly's Bucket
[26056]={35350},  -- Chuck's Bucket
[26119]={35504},  -- Phoenix Hatchling

-- xxxxx 2.4.2
[23198]={32498},  -- Fortune Coin / Lucky (korean servers only)
[25706]={34955},  -- Scorched Stone / Scorchling
[27914]={38050},  -- Soul-Trader Beacon / Ethereal Soul-Trader
[28470]={38628},  -- Nether Ray Fry
[29089]={39656},  -- Tyrael's Hilt / Mini Tyrael

-- xxxxx 2.4.3
[27217]={37297},  -- Gold Medallion / Spirit of Competition

-- xxxxx 3.0.1
--[15661]={21168},  -- Baby Shark (no longer in game)
[23274]={40653},  -- Reeking Pet Carrier / Stinker

-- xxxxx 3.0.2
[28513]={38658},  -- Vampiric Batling
[29147]={39973},  -- Ghostly Skull
[31575]={43698},  -- Giant Sewer Rat
[32595]={44723},  -- Nurtured Penguin Egg / Pengu
[32589]={39896},  -- Tickbird Hatchling
[32590]={39899},  -- White Tickbird Hatchling
[32592]={44721},  -- Proto-Drake Whelp

-- xxxxx 3.0.3
[28883]={39286},  -- Frosty's Collar
[32591]={39898},  -- Cobra Hatchling
[32643]={44738},  -- Kirin Tor Familiar
[32841]={44819},  -- Baby Blizzard Bear

-- xxxxx 3.0.8
[32939]={44841},  -- Little Fawn's Salt Lick

-- xxxxx 3.1.0
[7561]={44822},  -- Albino Snake
[32791]={44794},  -- Spring Rabbit's Foot
[33188]={44965},  -- Teldrassil Sproutling
[33194]={44970},  -- Dun Morogh Cub
[33197]={44971},  -- Tirisfal Batling
[33198]={44973},  -- Durotar Scorpion
[33200]={44974},  -- Elwynn Lamb
[33205]={44984},  -- Ammen Vale Lashling
[33219]={44980},  -- Mulgore Hatchling
[33226]={44983},  -- Strand Crawler
[33227]={44982},  -- Enchanted Broom
[33238]={44998},  -- Argent Squire
[33239]={45022},  -- Argent Gruntling
[33274]={45002},  -- Mechanopeep
[33810]={45606},  -- Sen'jin Fetish

-- xxxxx 3.1.2
[33578]={45180},  -- Murkimus' Little Spear / Murkimus the Gladiator

-- xxxxx 3.1.3
[34587]={46767},  -- Warbot Ignition Key / Warbot

-- xxxxx 3.2.0
[24753]={46707},  -- Pint-Sized Pink Pachyderm
[33529]={46544},  -- Curious Wolvar Pup
[33530]={46545},  -- Curious Oracle Hatchling
[34694]={46802},  -- Heavy Murloc Egg / Grunty
[34724]={46820,46821},  -- Shimmering Wyrmling
[35387]={48118},  -- Leaping Hatchling
[35394]={48126},  -- Razzashi Hatchling
[35395]={48114},  -- Deviate Hatchling
[35396]={48112},  -- Darting Hatchling
[35397]={48122},  -- Ravasaur Hatchling
[35398]={48124},  -- Razormaw Hatchling
[35399]={48120},  -- Obsidian Hatchling
[35400]={48116},  -- Gundrak Hatchling

-- xxxxx 3.2.2
[29726]={41133},  -- Unhatched Mr. Chilly
[32818]={44810},  -- Turkey Cage / Plump Turkey
[34770]={46831},  -- Macabre Marionette
[36482]={49287},  -- Tuskarr Kite
[36511]={49343},  -- Spectral Tiger Cub
[36607]={49362},  -- Onyxian Whelpling
[36911]={49665},  -- Pandaren Monk
[36979]={49693},  -- Lil' Phylactery / Lil' K.T.

-- xxxxx 3.3.0
[16456]={22781},  -- Polar Bear Collar / Poley (chinese servers only)
[25146]={34518},  -- Golden Pig Coin
[25147]={34519},  -- Silver Pig Coin
[27346]={37298},  -- Competitor's Souvenir / Essence of Competition
[34364]={46398},  -- Cat Carrier (Calico Cat) / Calico Cat
[36871]={49646},  -- Core Hound Pup
[37865]={49912},  -- Perky Pug

-- xxxxx 3.3.2
[36908]={49662},  -- Gryphon Hatchling
[36909]={49663},  -- Wind Rider Cub
[38374]={50446},  -- Toxic Wasteling

-- xxxxx 3.3.3
[40198]={53641},  -- Ice Chip / Frigid Frostling
[40295]={54436},  -- Blue Clockwork Rocket Bot
[40624]={54810},  -- Celestial Dragon
[40703]={54847},  -- Lil' XT

-- xxxxx 3.3.5
[34031]={45942},  -- XS-001 Constructor Bot
[42078]={56806},  -- Mini Thor

-- xxxxx 4.0.1
[51122]={67418},  -- Smoldering Murloc Egg / Deathy

-- xxxxx 4.0.3
[34278]={46325},  -- Withers
[42177]={65661},  -- Blue Mini Jouster
[42183]={65662},  -- Gold Mini Jouster
[43800]={59597},  -- Personal World Destroyer
[43916]={60216},  -- De-Weaponized Mechanical Companion
[45128]={60847},  -- Crawling Claw
[45247]={60869},  -- Pebble
[45340]={60955},  -- Fossilized Hatchling
[46896]={62540},  -- Lil' Deathwing
[46898]={67274},  -- Enchanted Lantern
[47169]={62769},  -- Hardboiled Egg / Eat the Egg (not available to players)
[47944]={63138},  -- Dark Phoenix Hatchling
[48107]={63355,64996},  -- Rustberg Gull / Rustberg Seagull
[48242]={63398},  -- Armadillo Pup
[48609]={64372},  -- Clockwork Gnome
[48641]={64403},  -- Fox Kit
[48982]={64494},  -- Tiny Shale Spider
[49586]={65361},  -- Guild Page
[49587]={65363},  -- Guild Herald
[49588]={65362},  -- Guild Page
[49590]={65364},  -- Guild Herald
[50468]={67128,-93624},  -- Landro's Lil' XT
[50545]={67275},  -- Magic Lamp
[50586]={66076},  -- Mr. Grubbs
[50722]={67282},  -- Elementium Geode
[51090]={66067},  -- Brazie's Sunflower Seeds / Singing Sunflower
[51600]={67601,68385},  -- Lil' Ragnaros
[51601]={68618},  -- Moonkin Hatchling
[51632]={66080},  -- Tiny Flamefly
[51634]={66075},  -- Bubbles
[51635]={66073},  -- Snail Shell / Scooter the Snail
--[51636],  -- Lizzy
[51649]={68619},  -- Moonkin Hatchling
--[nil]={67600},  -- Lil' Alexstrasza (removed from game)

-- xxxxx 4.1.0
[50384]={67128,-93461},  -- Landro's Lil' XT (no longer in game)
[53225]={69821},  -- Pterrordax Hatchling
[52226]={68833},  -- Panther Cub
[53232]={69824},  -- Voodoo Figurine
[52343]={68840},  -- Landro's Lichling
[52344]={68841},  -- Nightsaber Cub
[52831]={69239},  -- Winterspring Cub
[52894]={69251},  -- Lashtail Hatchling
[53048]={69648},  -- Legs
[53283]={69847,72068},  -- Guardian Cub
[53623]={70099},  -- Cenarion Hatchling

-- xxxxx 4.2.0
[53658]={70140},  -- Hyjal Bear Cub
[53661]={70160},  -- Crimson Lasher
[53884]={70908},  -- Feline Familiar
[54027]={71033},  -- Lil' Tarecgosa
[54128]={71076},  -- Creepy Crate

-- 14107 4.2.0
[54227]={71140},  -- Nuts' Acorn / Nuts

-- 14179 4.2.0
[54374]={71387},  -- Brilliant Kaliri

-- 14199 4.2.0
[54438]={71726},  -- Murkablo

-- 14265 4.2.0
[54539]={72042},  -- Alliance Balloon
[54541]={72045},  -- Horde Balloon

-- 15005 4.3.0
[54383]={71624},  -- Purple Puffer
[54487]={73765},  -- Darkmoon Turtle
[54491]={73764},  -- Darkmoon Monkey
[54730]={72134},  -- Grell Moss / Gregarious Grell
[54745]={72153},  -- Sand Scarab
[55187]={73762,75040},  -- Flimsy Darkmoon Balloon / Darkmoon Balloon
[55215]={73797},  -- Lump of Coal / Lumpy
[55356]={73903},  -- Darkmoon Tonk
[55367]={73905},  -- Darkmoon Zeppelin
[55386]={73953},  -- Sea Pony
[55571]={74610},  -- Lunar Lantern
[55574]={74611},  -- Festival Lantern
[56031]={74981},  -- Darkmoon Cub
[56266]={76062},  -- Fetish Shaman's Spear / Fetish Shaman
[58163]={78916},  -- Soul of the Aspects

-- 15211 4.3.2
[59020]={79744},  -- Eye of the Legion

-- xxxxx 5.0.1
[34930]={-66520},  -- Jade Tiger
[48376]={-89929},  -- Rumbling Rockling (not availalbe to players at the moment)
[48377]={-89930},  -- Swirling Stormling (not availalbe to players at the moment)
[48378]={-89931},  -- Whirling Waveling (not availalbe to players at the moment)

-- xxxxx 5.0.4
[48641]={90897,90898},  -- Fox Kit

-- 15890 5.0.4
[59358]={80008},  -- Darkmoon Rabbit
[61086]={89587},  -- Porcupette
[61877]={82774},  -- Jade Owl
[61883]={82775},  -- Sapphire Cub
[62829]={84105},  -- Fishy
[63097]={-123212},  -- Shore Crawler
[63098]={-123214},  -- Gilnean Raven
[63365]={85220},  -- Terrible Turnip
[63370]={85222},  -- Red Cricket
[63559]={85447},  -- Tiny Goldfish
[63621]={85578},  -- Feral Vermling
[63832]={85871},  -- Lucky Quilen Cub
[64232]={88147},  -- Singing Cricket Cage / Singing Cricket
[64632]={86562},  -- Hopling
[64633]={86563},  -- Hollow Reed / Aqua Strider
[64634]={86564},  -- Imbued Jade Fragment / Grinder
[64899]={87526},  -- Mechanical Pandaren Dragonling
[65313]={85513},  -- Thundering Serpent Hatchling
[65314]={88148},  -- Jade Crane Chick
[66104]={89368},  -- Chi-ji Kite
[66105]={89367},  -- Yu'lon Kite
[66450]={89686},  -- Jade Tentacle
[66491]={89736},  -- Venus

-- 16016 5.0.4
[66950]={90173},  -- Pandaren Water Spirit
[68502]={90953},  -- Spectral Cub (chinese servers only)
[66984]={90177},  -- Baneling

-- 16309 5.1.0
[67230]={90900},  -- Imperial Moth
[67233]={90902},  -- Imperial Silkworm
[67319]={91003},  -- Darkmoon Hatchling
[67329]={91031},  -- Darkmoon Glowfly
[67332]={91040},  -- Darkmoon Eye
[68267]={92707},  -- Cinder Kitten
[68466]={92798},  -- Pandaren Fire Spirit
[68467]={92799},  -- Pandaren Air Spirit
[68468]={92800},  -- Pandaren Earth Spirit
[68601]={93025},  -- Clock'em
[68654]={93029},  -- Gluth's Bone / Stitched Pup
[68655]={93031},  -- Mr. Bigglesworth
[68656]={93030},  -- Dusty Clutch of Eggs / Giant Bone Spider
[68657]={93032},  -- Blighted Spore / Fungal Abomination
[68658]={93041},  -- Jewel of Maddening Whispers / Mini Mindslayer
[68659]={93040},  -- Anubisath Idol
[68660]={93039},  -- Viscidus Globule
[68661]={93036},  -- Unscathed Egg / Untamed Hatchling
[68662]={93038},  -- Whistle of Chromatic Bone / Chrominius
[68663]={93037},  -- Blackwing Banner / Death Talon Whelpguard
[68664]={93034},  -- Blazing Rune / Corefire Imp
[68665]={93033},  -- Mark of Flame / Harbinger of Flame
[68666]={93035},  -- Core of Hardened Ash / Ashtone Core

-- xxxxx 5.2.0
[34587]={95621},  -- Warbot Ignition Key / Warbot

-- 16408 5.2.0
[69208]={93669},  -- Gusting Grimoire
[69649]={94025},  -- Red Panda
[69748]={94125},  -- Living Sandling

-- 16446 5.2.0
[69778]={94124},  -- Sunreaver Micro-Sentry
[69796]={94126},  -- Zandalari Kneebiter
[69820]={94152},  -- Son of Animus
[69848]={94190},  -- Spectral Porcupette
[69849]={94191},  -- Stunted Direhorn
[69891]={94208},  -- Sunfur Panda
[69892]={94210},  -- Mountain Panda
[69893]={94209},  -- Snowy Panda

-- 16467 5.2.0
[70082]={94903},  -- Pierre
[70083]={94574},  -- Pygmy Direhorn
[70098]={94595},  -- Spawn of G'nathus
[70144]={94835},  -- Ji-Kun Hatchling
[70154]={94573},  -- Direhorn Runt

-- 16486 5.2.0
[70257]={94932},  -- Tiny Red Carp
[70258]={94933},  -- Tiny Blue Carp
[70259]={94934},  -- Tiny Green Carp
[70260]={94935},  -- Tiny White Carp

-- 16503 5.2.0
[70451]={95422},  -- Zandalari Anklerender
[70452]={95423},  -- Zandalari Footslasher
[70453]={95424},  -- Zandalari Toenibbler

-- xxxxx 5.3.0
[71014]={97548},  -- Spiky Collar / Lil' Bad Wolf
[71015]={97549},  -- Instant Arcane Sanctum Security Kit / Menagerie Custodian
[71016]={97550},  -- Netherspace Portal-Stone / Netherspace Abyssal
[71017]={97552},  -- Shell of Tide-Calling / Tideskipper
[71018]={97553},  -- Tainted Core / Tainted Waveling
[71019]={97554},  -- Dripping Strider Egg / Coilfang Stalker
[71020]={97555},  -- Tiny Fel Engine Key / Pocket Reaver
[71021]={97556},  -- Crystal of the Void / Lesser Voidcaller
[71022]={97557},  -- Brilliant Phoenix Hawk Feather / Phoenix Hawk Hatchling
[71023]={97558},  -- Tito's Basket / Tito
[71033]={97551},  -- Satyr Charm / Fiendish Imp
[71159]={97821},  -- Gahz'rooki's Summoning Stone / Gahz'rooki
[71199]={97959},  -- Quivering Blob / Living Fluid
[71200]={97960},  -- Dark Quivering Blob / Viscous Horror
[71201]={97961},  -- Half-Empty Food Container / Filthling
[71488]={98550},  -- Blossoming Ancient

-- 16965 5.3.0
[71655]={100870,128423},  -- Murkimus' Tyrannical Spear / Zeradar

-- 17056 5.4.0
[71693]={100905},  -- Rascal-Bot
[71700]={-143732},  -- Crafty (not available to players)
[72160]={101570},  -- Moon Moon

-- 17903 5.4.0
[71942]={101771},  -- Xu-Fu, Cub of Xuen
[72462]={102145},  -- Chi-Chi, Hatchling of Chi-Ji
[72463]={102147},  -- Yu'la, Broodling of Yu'lon
[72464]={102146},  -- Zao, Calfling of Niuzao

-- 17169 5.4.0
[73011]={103670},  -- Lil' Bling

-- 17205 5.4.0
[73350]={104162},  -- Droplet of Y'Shaarj
[73351]={104163},  -- Gooey Sha-ling
[73352]={104158},  -- Blackfuse Bombling
[73354]={104165},  -- Kovok
[73355]={104164},  -- Jademist Dancer
[73356]={104159},  -- Ruby Droplet
[73357]={104166},  -- Ominous Flame
[73359]={104169},  -- Gulp Froglet
[73364]={104161},  -- Death Adder Hatchling
[73366]={104168},  -- Spineclaw Crab
[73367]={104167},  -- Skunky Alemental
[73368]={-148065},  -- Skywisp Moth
[73532]={104160},  -- Dandelion Frolicker
[73533]={104156},  -- Ashleaf Spriteling
[73534]={104157},  -- Azure Crane Chick
[73542]={-148068},  -- Ashwing Moth
[73543]={-148069},  -- Flamering Moth

-- 17227 5.4.0
[73668]={104202},  -- Bonkers
[73688]={103637},  -- Vengeful Porcupette
[73730]={104291},  -- Swarmling of Gu'chi / Gu'chi Swarmling
[73732]={104295},  -- Harmonious Porcupette
[73738]={104307},  -- Jadefire Spirit
[73741]={104317},  -- Rotten Helper Box / Rotten Little Helper

-- 17247 5.4.0
[73809]={104332,104333},  -- Sky Lantern

-- 17481 5.4.1
[74402]={106240},  -- Alterac Brandy / Alterac Brew-Pup
[74405]={106244},  -- Murkalot's Flail / Murkalot

-- 17645 5.4.2
[74413]={106256},  -- Treasure Goblin's Pack / Treasure Goblin

-- 17807 5.4.7
[77137]={109014},  -- Dread Hatchling

-- 18125 6.0.1
[77221]={111660},  -- Iron Starlette
[78421]={113558},  -- Weebomination
[78895]={110684},  -- Leftovers / Lil' Leftovers
[79039]={110721},  -- Crazy Carrot
[79410]={111402},  -- Mechanical Axebeak

-- 18179 6.0.1
[80101]={111866},  -- Royal Peacock / Royal Peachick

-- 18297 6.0.1
[80329]={112057},  -- Lifelike Mechanical Frostboar
[81431]={112699},  -- Teroclaw Hatchling

-- 18379 6.0.1
[82464]={113216},  -- Elekk Plushie

-- 18443 6.0.1
[83562]={113554},  -- Zomstrok
[83583]={118600,119149},  -- Captured Forest Sproutling
[83584]={118599},  -- Autumnal Sproutling
[83588]={118598},  -- Sun Sproutling
[83589]={118597},  -- Kelp Sproutling
--[83592],  -- Sassy Sproutling
[83594]={118595},  -- Nightshade Sproutling

-- 18471 6.0.1
[83817]={113623},  -- Spectral Bell / Ghastly Kid

-- 18505 6.0.1
[84330]={114834},  -- Meadowstomper Calf
[84441]={114919},  -- Sea Calf
[84521]={114968},  -- Deathwatch Hatchling

-- 18522 6.0.1
[76873]={123862},  -- Hogs' Studded Collar / Hogs
[84853]={119328},  -- Soul of the Forge
[84885]={115282,119142},  -- Draenei Micro Defender
[84915]={115301},  -- Molten Corgi
[85014]={119146},  -- Bone Wasp
[85231]={116402},  -- Stonegrinder
[85281]={119148},  -- Indentured Albino River Calf / Albino River Calf
[85284]={115483},  -- Sky-Bo
[85387]={117564},  -- Fruit Hunter
[85667]={118919},  -- Red Goren Egg / Ore Eater
[86081]={116815},  -- Netherspawn, Spawn of Netherspawn
[86422]={117380},  -- Frostwolf Ghostpup
[86447]={-170270},  -- Ikky
[86879]={118207},  -- Hydraling
[87111]={119141},  -- Frostwolf Pup
[87257]={-170284,-170290},  -- Pygmy Cow (G4BC/BSG) / Pygmy Cow
[87669]={118574},  -- Hatespark the Tiny
[87704]={118578},  -- Firewing
[87705]={118577},  -- Stormwing
[88103]={118709},  -- Doom Bloom
[88134]={118741},  -- Mechanical Scorpid
[88300]={119467},  -- Puddle Terror
[88401]={119112,119143},  -- Son of Sethe
[88452]={119150},  -- Sky Fry
[88490]={119170},  -- Eye of Observation
[88573]={120050},  -- Veilwatcher Hatchling
[88692]={119431},  -- Servant of Demidos

-- 18566 6.0.1
[85527]={116064},  -- Syd the Squid
[85710]={116155},  -- Lovebird Hatchling
[85773]={116258},  -- Mystical Spring Bouquet
[85846]={116403},  -- Frightened Bush Chicken / Bush Chicken

-- 18594 6.0.1
[85872]={116439},  -- Blazing Cindercrawler
[85994]={116756},  -- Stout Alemental
[86061]={116801},  -- Cursed Birman
[86067]={116804},  -- Widget the Departed
[86420]={117354},  -- Ancient Nest Guardian

-- 18663 6.0.1
[86445]={117404},  -- Land Shark
[86532]={117528},  -- Lanticore Spawnling
[86715]={118101},  -- Zangar Spore
[86716]={118106},  -- Crimson Spore
[86717]={118104},  -- Umbrafen Spore
[86718]={118105},  -- Seaborne Spore
[86719]={118107},  -- Brilliant Spore

-- 18738 6.0.1
[88222]={118921},  -- Everbloom Peachick
[88225]={118923},  -- Sentinel's Companion

-- xxxxx 6.0.2
[88367]={119468},  -- Sunfire Kaliri

-- 18764 6.0.2
[77021]={119434},  -- Albino Chimaeraling
[87257]={120309},  -- Glass of Warm Milk / Pygmy Cow
[88574]={120051},  -- Kaliri Hatchling
[88577]={122532},  -- Bone Serpent
[88805]={118517},  -- Grommloc
[88807]={118516},  -- Argi
[88830]={120121},  -- Trunks
[91407]={122534},  -- Slithershock Elver
[91408]={122533},  -- Young Talbuk
[93432]={-177220},  -- Nethaera's Light

-- 19445 6.1.0
[90200]={122105},  -- Grotesque Statue / Grotesque
[90201]={122104},  -- Leviathan Egg / Leviathan Hatchling
[90202]={122106},  -- Shard of Supremus / Abyssius
[90203]={122107},  -- Fragment of Anger
[90204]={122108},  -- Fragment of Suffering
[90205]={122109},  -- Fragment of Desire
[90206]={122110},  -- Sultry Grimoire / Sister of Temptation
[90207]={122111},  -- Smelly Gravestone / Stinkrot
[90208]={122112},  -- Hyjal Wisp
[90212]={122113},  -- Sunblade Rune of Activation / Sunblade Micro-Defender
[90213]={122114},  -- Void Collar / Chaos Pup
[90214]={122115},  -- Servant's Bell / Wretched Servant
[90215]={122116},  -- Holy Chime / K'ute
[90345]={122125},  -- Race MiniZep Controller / Race MiniZep
[91226]={122477,-181086},  -- My Special Pet / Graves

-- 19890 6.2.0
[88415]={127703},  -- Dusty Sporewing
[88514]={127704},  -- Bloodthorn Hatchling
[88575]={127701},  -- Glowing Sporebat
[93143]={127748},  -- Cinder Pup
[93808]={126926},  -- Translucent Shell / Ghostshell Crab
[93814]={126925},  -- Blorp's Bubble / Blorp
[91823]={129205},  -- A Tiny Infernal Collar / Fel Pup
[93142]={127705},  -- Lost Netherpup
[93483]={127753},  -- Nightmare Bell

-- 19906 6.2.0
[93352]={127754},  -- Periwinkle Calf
[94623]={127749},  -- Corrupted Nest Guardian

-- 19934 6.2.0
[94867]={127856},  -- Left Shark
[94927]={127868},  -- Crusher

-- 19973 6.2.0
[95572]={128309},  -- Shard of Cyrukh

-- 20061 6.2.0
[96123]={128478},  -- Blazing Firehawk
[96126]={128477},  -- Savage Cub

-- 20271 6.2.1
[98236]={129216},  -- Vibrating Arcane Crystal / Energized Manafiend
[98237]={129217},  -- Warm Arcane Crystal / Empowered Manafiend
[98238]={129218},  -- Glittering Arcane Crystal / Empyreal Manafiend

-- 20395 6.2.2
[85009]={128427},  -- Murkidan
[85283]={128424},  -- Brightpaw
[95841]={128426},  -- Nibbles
[97229]={128770},  -- Grumpling

-- 20716 6.2.3
[103159]={134047},  -- Baby Winston

-- xxxxx 7.0.1
[96649]={128690},  -- Ashmaw Cub
[99425]={136910},  -- Alarm-o-Bot

-- 21071 7.0.1
[106181]={136920},  -- Sunborne Val'kyr
[106152]={136919},  -- Baby Elderhorn
[106210]={132519},  -- Trigger
[106232]={136922},  -- Wyrmy Tunkins
[106270]={136923},  -- Celestial Calf
[106278]={136924},  -- Felbat Pup
[106283]={136925},  -- Corgi Pup

-- 21108 7.0.3
[107206]={137298},  -- Zoom

-- 21384 7.0.3
[109216]={138810},  -- Sting Ray Pup

-- 21491 7.0.3
[111202]={139775},  -- Alliance Enthusiast

-- 21570 7.0.3
[111296]={139776},  -- Horde Fanatic
[111421]={139791},  -- Lurking Owl Kitten
[111423]={139790},  -- Untethered Wyrmling
[111425]={139789},  -- Transmutant
[111984]={140261},  -- Hungering Claw
[112015]={136903},  -- Nightmare Whelpling
[112132]={140316},  -- Firebat Pup
[112144]={140320},  -- Corgnelius
[112167]={140323},  -- Lagan

-- 21655 7.0.3
[108568]={130154},  -- Pygmy Owl
[112728]={140672},  -- Court Scribe
[112798]={140741},  -- Nightmare Lasher
[112945]={140761},  -- Nightmare Treant
[113136]={140934},  -- Benax

-- 21691 7.0.3
[113440]={141316},  -- Squirky

-- 21737 7.0.3
[113827]={141348},  -- Wonderous Wisdomball
[113855]={141352},  -- Rescued Fawn

-- 21846 7.0.3
[114063]={141530},  -- Snowfang

-- 21874 7.0.3
[113983]={141894},  -- Knight-Captain Murky
[113984]={141895},  -- Legionnaire Murky

-- 23360 7.0.3
[33975]={141532},  -- Noblegarden Bunny
[114543]={141714},  -- Igneous Flameling
[115135]={142083},  -- Giant Worm Egg / Dreadmaw
[115136]={142084},  -- Magnataur Hunting Horn / Snobold Runt
[115137]={142085},  -- Nerubian Relic / Nerubian Swarmer
[115138]={142086},  -- Red-Hot Coal / Magma Rageling
[115139]={142087},  -- Ironbound Collar / Ironbound Proto-Whelp
[115140]={142088},  -- Stormforged Rune / Runeforged Servitor
[115141]={142089},  -- Glittering Ball of Yarn / Sanctum Cub
[115142]={142090},  -- Ominous Pile of Snow / Winter Rageling
[115143]={142091},  -- Blessed Seed / Snaplasher
[115144]={142092},  -- Overcomplicated Controller / G0-R41-0N Ultratonk
[115145]={142093},  -- Wriggling Darkness / Creeping Tentacle
[115146]={142094},  -- Fragment of Frozen Bone / Boneshard
[115147]={142095},  -- Remains of a Blood Beast / Blood Boil
[115148]={142096},  -- Putricide's Alchemy Supplies / Blightbreath
[115149]={142097},  -- Skull of a Frozen Whelp / Soulbroken Whelpling
[115150]={142098},  -- Drudge Remains / Drudge Ghoul
[115152]={142099},  -- Call of the Frozen Blade / Wicked Soul
[115158]={142100},  -- Stardust
[115918]={142379},  -- Dutiful Squire
[115919]={142380},  -- Dutiful Gruntling
[116080]={142448},  -- Albino Buzzard
[117371]={143842},  -- Trashy
[118060]={143953},  -- Infinite Hatchling
[118063]={143954},  -- Paradox Spirit
[119040]={144394},  -- Tylarr Gronnden

-- 23835 7.2.0
[61087]={142223},  -- Sun Darter Hatchling
[116871]={143679},  -- Crackers
[117180]={143756},  -- Everliving Spore
[117182]={143754},  -- Cavern Moccasin
[117184]={143755},  -- Young Venomfang
[117340]={151645},  -- Model D1-BB-L3R / Dibbler
[117341]={233649},  -- Naxxy
[119498]={147539},  -- Bloodbrood Whelpling
[119499]={147540},  -- Frostbrood Whelpling
[119500]={147541},  -- Vilebrood Whelpling
[120397]={146953},  -- Scraps
[120830]={147542},  -- Ban-Fu, Cub of Ban-Lu
[121317]={147543},  -- Son of Skum
[121715]={147841},  -- Orphaned Felbat

-- 24330 7.2.5
[63724]={101426},  -- Micronax Controller / Micronax
[119794]={150739},  -- Pocket Cannon
[122612]={150741},  -- Tricorne
[122629]={150742},  -- Pet Reaper 0.9 / Foe Reaper 0.9
[124389]={151569},  -- Sneaky Marmot
[124589]={151632},  -- Mining Monkey
[124594]={151633},  -- Dig Rat
[124858]={151829},  -- Bronze Proto-Whelp
[124944]={151828},  -- Ageless Bronze Drake

-- 24920 7.3.0
[122033]={147900},  -- Twilight
[126579]={152555},  -- Ghost Shark
[127850]={152966},  -- Rough-Hewn Remote / Tinytron
[127852]={152967},  -- Experiment-In-A-Jar / Discarded Experiment
[127853]={152968},  -- Shadowy Pile of Bones / Rattlejaw
[127857]={152969},  -- Odd Twilight Egg / Twilight Clutch-Sister
[127858]={152970},  -- Lesser Circle of Binding / Bound Stream
[127859]={152972},  -- Twilight Summoning Portal / Faceless Minion
[127862]={152973},  -- Zephyr's Call / Zephyrian Prince
[127863]={152974},  -- Breezy Essence / Drafty
[127947]={152975},  -- Smoldering Treat / Blazehound
[127948]={152976},  -- Cinderweb Egg / Cinderweb Recluse
[127950]={152977},  -- Vibrating Stone / Surger
[127951]={152978},  -- Fandral's Pet Carrier / Infernal Pyreclaw
[127952]={152979},  -- Puddle of Black Liquid / Faceless Mindlasher
[127953]={152980},  -- Elementium Back Plate / Corrupted Blood
[127954]={152981},  -- Severed Tentacle / Unstable Tendril
[127956]={152963},  -- Amalgam of Destruction
[128118]={153026},  -- Cross Gazer
[128119]={153027},  -- Orphaned Marsuul
[128137]={153045},  -- Fel Lasher
[128146]={153040},  -- Felclaw Marsuul
[128157]={153054},  -- Docile Skyfin
[128158]={153055},  -- Fel-Afflicted Skyfin
[128159]={153056},  -- Grasping Manifestation
[128160]={153057},  -- Fossorial Bile Larva
[128388]={153252},  -- Rebellious Imp
[128396]={153195},  -- Uuna's Doll / Uuna

-- 25079 7.3.2
[123650]={151234},  -- Shadow

-- 25902 8.0.1
[129253]={162686},  -- REUSE
[131644]={156566},  -- Dart
[132366]={156721},  -- Mailemental
[133064]={156851},  -- Silithid Mini-Tank
[134406]={158077},  -- Francois

-- 26032 8.0.1
[129049]={153541},  -- Tottle

-- 26433 8.0.1
[138964]={160702},  -- Spawn of Merektha
[139049]={160704},  -- Filthy Slime
[139073]={158464},  -- Poda
[139081]={160708},  -- Smoochums
[139252]={160847},  -- Guardian Cobra Hatchling
[139372]={160940},  -- Vengeful Chicken
[139622]={161016},  -- Lil' Tika

-- 26476 8.0.1
[139743]={152878},  -- Enchanted Tiki Mask
[139744]={161080},  -- Direhorn Hatchling
[139770]={161081},  -- Taptaf
[139782]={161089},  -- Restored Revenant
[140125]={161214},  -- Miimii

-- 26530 8.0.1
[141941]={162578}, -- Baa'l

-- 26624 8.0.1
[143142]={163220},  -- Rooter
[143160]={163244},  -- Brutus
[143175]={163489},  -- Abyssal Eel
[143176]={163490},  -- Pair of Bee Wings / Seabreeze Bumblebee
[143177]={166791,163491},  -- Corlain Falcon
[143178]={163492},  -- Drustvar Piglet
[143179]={163493},  -- Bloody Rabbit Fang / Frenzied Cottontail
[143181]={163494},  -- Bilefang Skitterer
[143184]={163495},  -- Greatwing Macaw
[143188]={163496},  -- Strange Looking Mechanical Squirrel / Mechanical Prairie Dog
[143189]={163497},  -- Spooky Bundle of Sticks / Wicker Pup
[143191]={163498},  -- Tiny Direhorn
[143193]={163499},  -- Raptor Containment Crate / Zandalari Shinchomper
[143194]={163500},  -- Bloodfeaster Larva
[143195]={163501},  -- Tragg the Curious
[143196]={163502},  -- Lil' Ben'fon
[143197]={163503},  -- Ranishu Runt
[143198]={163504},  -- Child of Jani
[143199]={163505},  -- Toad in a Box / Swamp Toad
[143200]={163506},  -- Accursed Hexxer
[143202]={163560},  -- Saurolisk Hatchling
[143203]={163508},  -- Blue Flitter
[143204]={163509},  -- Freshwater Pincher
[143205]={163510},  -- Crimson Frog
[143206]={163511},  -- Barnacled Hermit Crab
[143207]={163512},  -- Sandstinger Wasp
[143209]={163513},  -- Cou'pa
[143211]={163514},  -- Carnivorous Lasher
[143214]={163515},  -- Azeriti
[143360]={163568},  -- Lost Platysaur
[143611]={163555},  -- Drop of Azerite / Azerite Puddle

-- 26714 8.0.1
[143464]={163634},  -- Dreadtick Leecher
[143499]={163648},  -- Fuzzy Creepling
[143503]={163650},  -- Aldrusian Sproutling
[143507]={163652},  -- Tiny Grimoire / Voidwiggler
[143515]={163677},  -- Teeny Titan Orb
[143533]={163684},  -- Scabby
[143563]={163689},  -- Angry Egg / Ragepeep
[143564]={163690},  -- Plagued Egg / Foulfeather
[143627]={163711},  -- Shard of Fozruk / Fozling
[143628]={163712},  -- Mana-Warped Egg / Squawkling
[143730]={163776},  -- Large Honeycomb Cluster / Bumbles
[143738]={163778},  -- Lil' Siege Tower (Alliance)
[143739]={163779},  -- Lil' War Machine (Horde)
[143815]={163817},  -- Sunscale Hatchling
[143816]={163818},  -- Bloodstone Tunneler
[143817]={163819},  -- Snort
[143818]={163820},  -- Muskflank Calfling
[143819]={163821},  -- Juvenile Brineshell
[143820]={163822},  -- Kunchong Hatchling
[143821]={163823},  -- Coldlight Surfrunner
[143822]={163824},  -- Voru'kar Leecher

-- 26788 8.0.1
[144004]={163974},  -- Bucketshell
[144005]={163975},  -- Sir Snips

-- 28724 8.0.1
[138741]={160588},  -- Cap'n Crackers
[138742]={160587},  -- Whomper
[143959]={163858},  -- Ball of Tentacles / Slippy
[143374]={163859},  -- Baby Crawg
[143957]={163860},  -- Wind-Up Frog / Gearspring Hopper
[143958]={163861},  -- Undulating Blue Sac / Bloated Bloodfeaster
[147221]={165722},  -- Redridge Tarantula
[147583]={165845},  -- Feathers
[147585]={165848},  -- Spawn of Krag'wa
[147586]={165846},  -- Enchanted Talon of Pa'ku / Child of Pa'ku
[147587]={165847},  -- Thundering Scale of Akunda / Thunder Lizard Runt
[147619]={165849},  -- Mechantula
[147671]={165854},  -- Mechanical Cockroach
[147679]={165855},  -- Leper Rat
[147692]={165857},  -- Alarm-O-Dog
[147838]={165894},  -- Mini Spider Tank
[147884]={165907},  -- Wicker Wraith
[148520]={166345},  -- Zandalari Raptor Egg / Dasher
[148524]={166346},  -- Trecker
[148525]={166347},  -- Tanzil
[148542]={166358},  -- Proper Parrot (not available to players)
[148781]={166449},  -- Darkshore Sentinel
[148784]={166448},  -- Binding of Cyclarus / Gust of Cyclarus
[148825]={166451},  -- Rattling Bones / Detective Ray
[148841]={166452},  -- Bottled Essence of Hydrath / Hydrath Droplet
[148843]={166453},  -- Everburning Treant
[148844]={166454},  -- Squishy Purple Goo / Void Jelly
[148846]={166455},  -- Zur'aj the Depleted
[148976]={166486},  -- Baby Stonehide
[148979]={166487},  -- Leatherwing Screecher
[148981]={166488},  -- Rotting Ghoul
[148982]={166489},  -- Needleback Pup
[148984]={166492},  -- Shadefeather Hatchling
[148985]={166491},  -- Albino Duskwatcher
[148988]={166493},  -- Firesting Buzzer
[148989]={166494},  -- Lord Woofington
[148990]={166495},  -- Tonguelasher
[148991]={166498},  -- Scritches
[148995]={166499},  -- Thunderscale Whelpling
[148997]={166500},  -- Crimson Octopode
[149205]={166528},  -- Nightwreathed Watcher
[149348]={166715},  -- Rebuilt Gorilla Bot
[149361]={166723},  -- Rebuilt Mechanical Spider
[149363]={166714},  -- Albatross Hatchling
[149372]={166716},  -- Pair of Tiny Bat Wings / Crimson Bat Pup
[149375]={166718},  -- Cobalt Raven
[149376]={166719},  -- Violet Abyssal Eel

-- 29701 8.1.5
[145946]={164969,-283740},  -- Horse Balloon
[145947]={164971,-283741},  -- Murloc Balloon
[145948]={164970,-283744},  -- Wolf Balloon
[150098]={167008,-291203},  -- Sandy Hermit Crab Shell / Mr. Crabs
[150119]={167010,-291214},  -- Beakbert
[150120]={167011,-291215},  -- Slimy Pouch / Froglet
[150126]={167009,-291223},  -- Enchanted Saurolisk Scale / Scaley
[150354]={167047,-291513},  -- Stoneclaw
[150356]={167048,-291515},  -- Wayward Spirit
[150357]={167049,-291517},  -- Celestial Gift / Comet
[150360]={167050,-291533},  -- Mogu Statue / Baoh-Xi
[150365]={167051,-291537},  -- Azure Cloud Serpent Egg / Azure Windseeker
[150372]={167052,-291547},  -- Spirit of the Spring
[150374]={167058,-291548},  -- Kor'thik Swarmling
[150375]={167053,-291549},  -- Tiny Amber Wings / Amberglow Stinger
[150377]={167054,-291553},  -- Spawn of Garalon
[150380]={167055,-291556},  -- Amber Goo Puddle / Living Amber
[150381]={167056,-291560},  -- Essence of Pride / Ravenous Prideling
[150385]={167057,-291561},  -- Happiness

-- 30918 8.2.0
[154693]={169322,-300934},  -- Adventurous Hopling Pack / Adventurous Hopling
[155248]={169676,-302003},  -- Contained Banshee Wail / Shrieker
[154849]={169377,-301048},  -- Drowned Hatchling
[151696]={167807,-294277},  -- Slimy Fangtoot
[154838]={169365,-301036},  -- Damplight Slug
[154904]={169396,-301162},  -- Echoing Oozeling
[155244]={169678,-301992},  -- Ziggy
[155579]={169879,-303608},  -- Melted Irradiated Undercoat / Irradiated Elementaling
[154831]={169358,-301029},  -- Lightless Ambusher
[154840]={169367,-301038},  -- Seafury
[151700]={167805,-294275},  -- Slimy Otter
[151673]={167806,-294276},  -- Slimy Octopode
[151632]={167810,-294280},  -- Slimy Hermit Crab
[154165]={169205,-300367},  -- Ghostly Whelpling
[154826]={169353,-301024},  -- Lustrous Glimmershell
[154832]={169359,-301030},  -- Spawn of Nalaada
[154837]={169364,-301035},  -- Prismatic Softshell
[154841]={169368,-301039},  -- Stormwrath
[154845]={169373,-301044},  -- Brinestone Algan
[154851]={169379,-301050},  -- Snowsoft Nibbler
[154852]={169380,-301051},  -- Mustyfur Snooter
[154893]={169392,-301136},  -- Bonebiter
[155829]={170072,-303784},  -- Armored Vaultbot
[155865]={170102,-303899},  -- Burnout
[151697]={167808,-294278},  -- Slimy Eel
[151651]={167809,-294279},  -- Slimy Darkhunter
[154824]={169351,-301022},  -- Sandclaw Nestseeker
[154827]={169354,-301025},  -- Brilliant Glimmershell
[154828]={169355,-301026},  -- Chitterspine Needler
[154829]={169356,-301027},  -- Caverndark Nightmare
[154830]={169357,-301028},  -- Chitterspine Devourer
[154836]={169363,-301034},  -- Amethyst Softshell
[154843]={169370,-301041},  -- Scalebrood Hydra
[154820]={169371,-301042},  -- Murgle
[154821]={169372,-301043},  -- Necrofin Tadpole
[154850]={169378,-301049},  -- Golden Snorf
[154894]={169393,-301137},  -- Arachnoid Skitterbot
[155246]={169677,-301996},  -- Crypt Fiend
[151631]={167804,-294274},  -- Slimy Sea Slug
[154445]={154445,-300387},  -- Evil Wizard Hat / Minimancer
[154819]={169348,-301015},  -- Zanj'ir Poker
[154822]={169349,-301020},  -- Kelpfin
[154823]={169350,-301021},  -- Glittering Diamondshell
[154825]={169352,-301023},  -- Pearlescent Glimmershell
[154833]={169360,-301031},  -- Mindlost Bloodfrenzy
[154834]={169361,-301032},  -- Daggertooth Frenzy
[154835]={169362,-301033},  -- Nameless Octopode
[154839]={169366,-301037},  -- Wriggler
[154842]={169369,-301040},  -- Sandkeep
[154846]={169374,-301045},  -- Budding Algan
[154847]={169375,-301046},  -- Coral Lashling
[154848]={169376,-301047},  -- Skittering Eel
[154853]={169381,-301052},  -- OOX-35/MG
[154854]={169382,-301053},  -- Lost Robogrip
[154855]={169383,-301054},  -- Utility Mechanoclaw
[154856]={169384,-301055},  -- Microbot XD
[154857]={169385,-301056},  -- Microbot 8D
[155240]={169679,-301985},  -- Gruesome Belcher
[155600]={169886,-303023},  -- Spraybot 0D

-- 31958 8.2.5
[159783]={-311289},  -- Jenafur
[158681]={172491,-309516},  -- Papi
[158685]={172493,-309522},  -- Snarling Butterfly Crate / Crimson Skipper
[157524]={173296,-307264},  -- Rikki's Pith Helmet / Rikki
[151779]={172016,-294206},  -- Lil' Nefarian
[158683]={172492,-309519},  -- Sunsoaked Flitter

-- 32185 8.2.5
[144617]={164629,-281878},  -- Test Pet (untamable)

-- 32750 8.2.5
[157715]={-307654},  -- Gillvanas
[157716]={-307655},  -- Finduin

-- 33062 8.3.0
[161997]={174475,-315355},  -- Stinky Sack / Rotbreath
[157969]={-308067},  -- Anima Wyrmling
[161951]={174456,-315285},  -- Bottle of Gloop / Gloop
[161919]={174446,-315221},  -- Fractured Obsidian Claw / Muar
[162014]={174480,-315372},  -- Windfeather Quill / Windfeather Chick
[161964]={174461,-315302},  -- Swirling Black Bottle / Anomalus
[161962]={174459,-315298},  -- Voidwoven Cat Collar / Void-Scarred Cat
[162007]={174481,-315367},  -- Cursed Dune Watcher
[161946]={174452,-315270},  -- Eye of Corruption
[162012]={174478,-315370},  -- Wicked Lurker
[163646]={175049,-318300},  -- Shadowbarb Hatchling
[151788]={-294231},  -- Dottie
[160196]={174646,-312030},  -- Void-Link Frostwolf Collar / Void-Scarred Pup
[161923]={174448,-315229},  -- Aqir Hivespawn
[161966]={174462,-315303},  -- Void Cocoon / Void-Scarred Beetle
[161967]={174463,-315304},  -- Reek
[161954]={174473,-315339},  -- K'uddly
[162004]={174476,-315360},  -- Black Chitinous Plate / Aqir Tunneler
[161921]={174447,-315225},  -- Void-Scarred Anubisath
[161992]={174474,-315353},  -- Corrupted Tentacle
[160187]={173726,-312029},  -- Box With Faintly Glowing 'Air' Holes / Void-Scarred Toad
[161924]={174449,-315231},  -- Ra'kim
[161959]={174457,-315290},  -- C'Thuffer
[161961]={174458,-315297},  -- Void-Scarred Hare
[161963]={174460,-315301},  -- Box Labeled "Danger: Void Rat Inside" / Void-Scarred Rat
[162006]={174477,-315363},  -- Pygmy Camel
[162013]={174479,-315371},  -- Jade Defender
[162670]={174829,-316628},  -- Tinyclaw
[162663]={174828,-316629},  -- Experiment 13
[162677]={174827,-316627},  -- Wailing Lasher

--	[zzzzz]={zzzzz,-zzzzz},  -- 

-- https://shadowlands.wowhead.com/spells/companions?filter=112;35432;0

-- 35432 9.0.1
[173994]={183395,-341302},  -- Projection of Remornia / Summon Remornia
[174088]={183601,-341516},  -- Jelly Cat / Summon Slime Cat
[173992]={183195,-341298},  -- Torghast Lurker / Summon Torghast Lurker
[173842]={183107,-340710},  -- Char / Pile of Ashen Dust / Summon Char
[173849]={183115,-340721},  -- Torghast Roach / Summon Companion
[174085]={183412,-341497},  -- Death Seeker / Summon Death Seeker
[173851]={183117,-340723},  -- Severs / Summon Severs
[173988]={183191,-341289},  -- Maw Crawler / Summon Maw Crawler
[173989]={183193,-341292},  -- Ashen Chomper / Contained Ashen Chomper / Summon Ashen Chomper
[173993]={183196,-341301},  -- Lavender Nibbler
[173847]={183114,-340717},  -- Carpal / Summon Carpal
[173850]={183116,-340722},  -- Phantasmal Roach / Summon Companion
[174081]={183407,-341492},  -- Dread / Contained Essence of Dread / Summon Dread
[174082]={183408,-341493},  -- Deathsworn Cockroach / Summon Deathsworn Cockroach
[173991]={183194,-341295},  -- Maw Stalker / Summon Stalker
[174084]={183410,-341495},  -- Sharpclaw / Summon Sharpclaw
[173990]={183192,-341293},  -- Frenzied Mawrat / Summon Frenzied Mawrat
[174083]={183409,-341494},  -- Decaying Mawrat / Summon Decaying Mawrat

-- 35522 9.0.1
[174181]={183621,-341825},  -- Putrid Geist
[174125]={183515,-341635},  -- Reanimated Plague

-- 35598 9.0.1
[174677]={-343161},  -- Spinebug

-- 35854 9.0.3
[175220]={184221,-344792},  -- Archivist's Quill

--	[zzzzz]={zzzzz,-zzzzz},  -- 
--	https://www.wowhead.com/spells/companions/live-only:on?filter=112;33062;0

-- [npcID]={itemID,-spellID}
}

function ArkInventory.Collection.Pet.ImportCrossRefTable( )
	
	if not ImportCrossRefTable then return end
	if not ArkInventory.Collection.Pet.IsReady( ) then return end
	
	ImportCrossRefTableAttempt = ImportCrossRefTableAttempt + 1
	
	local npc, speciesID, key1, key2
	
	for k, v in pairs( ImportCrossRefTable ) do
		
		npc = tonumber( k ) or 0
		if npc > 0 then
			
			speciesID = ArkInventory.Collection.Pet.GetSpeciesIDForCreatureID( npc )
			if speciesID then
				
				key2 = ArkInventory.ObjectIDCount( string.format( "battlepet:%s", speciesID ) )
				
				for k2, v2 in pairs( v ) do
					
					v2 = tonumber( v2 ) or 0
					
					key1 = nil
					if v2 > 0 then
						key1 = ArkInventory.ObjectIDCount( string.format( "item:%s", v2 ) )
					elseif v2 < 0 then
						key1 = ArkInventory.ObjectIDCount( string.format( "spell:%s", math.abs( v2 ) ) )
					end
					
					--ArkInventory.Output2( k2, ": ", key1, " / ", key2 )
					
					if key1 then
						
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
				
				ImportCrossRefTable[k] = nil
				
			else
				
				--ArkInventory.Output2( "unknown: npc[", npc, "], species[", speciesID, "]" )
				
			end
			
		end
		
	end
	
	--ArkInventory.Output2( "pet xref import attempt ", ImportCrossRefTableAttempt, ": ", ArkInventory.Table.Elements( ImportCrossRefTable ), " entries left" )
	
	if ImportCrossRefTableAttempt > 5 or ArkInventory.Table.Elements( ImportCrossRefTable ) == 0 then
		ArkInventory.Table.Clean( ImportCrossRefTable )
		ImportCrossRefTable = nil
	end
	
end

local function FilterGetSearch( )
	return PetJournal.searchBox:GetText( )
end

local function FilterSetSearch( s )
	PetJournal.searchBox:SetText( s )
	C_PetJournal.SetSearchFilter( s )
end

local function FilterSetCollected( value )
	C_PetJournal.SetFilterChecked( LE_PET_JOURNAL_FILTER_COLLECTED, value )
end

local function FilterGetCollected( )
	return C_PetJournal.IsFilterChecked( LE_PET_JOURNAL_FILTER_COLLECTED )
end

local function FilterGetUncollected( )
	return C_PetJournal.IsFilterChecked( LE_PET_JOURNAL_FILTER_NOT_COLLECTED )
end

local function FilterSetUncollected( value )
	C_PetJournal.SetFilterChecked( LE_PET_JOURNAL_FILTER_NOT_COLLECTED, value )
end

local function FilterGetFamilyTypes( )
	return C_PetJournal.GetNumPetTypes( )
end

local function FilterSetFamily( t )
	if type( t ) == "table" then
		for i = 1, FilterGetFamilyTypes( ) do
			C_PetJournal.SetPetTypeFilter( i, t[i] )
		end
	elseif type( t ) == "boolean" then
		for i = 1, FilterGetFamilyTypes( ) do
			C_PetJournal.SetPetTypeFilter( i, t )
			
		end
	else
		assert( false, "parameter is " .. type( t ) .. ", not a table or boolean" )
	end
end

local function FilterGetFamily( t )
	assert( type( t ) == "table", "parameter is not a table" )
	for i = 1, FilterGetFamilyTypes( ) do
		t[i] = C_PetJournal.IsPetTypeChecked( i )
	end
end

local function FilterGetSourceTypes( )
	return C_PetJournal.GetNumPetSources( )
end

local function FilterGetSource( t )
	assert( type( t ) == "table", "parameter is not a table" )
	for i = 1, FilterGetSourceTypes( ) do
		t[i] = C_PetJournal.IsPetSourceChecked( i )
	end
end

local function FilterSetSource( t )
	if type( t ) == "table" then
		for i = 1, FilterGetSourceTypes( ) do
			C_PetJournal.SetPetSourceChecked( i, t[i] )
		end
	elseif type( t ) == "boolean" then
		for i = 1, FilterGetSourceTypes( ) do
			C_PetJournal.SetPetSourceChecked( i, t )
		end
	else
		assert( false, "parameter is not a table or boolean" )
	end
end

local function FilterActionClear( )
	
	collection.filter.ignore = true
	
	FilterSetSearch( "" )
	FilterSetCollected( true )
	FilterSetUncollected( true )
	FilterSetFamily( true )
	FilterSetSource( true )
	
end

local function FilterActionBackup( )
	
	if collection.filter.backup then return end
	
	collection.filter.search = FilterGetSearch( )
	collection.filter.collected = FilterGetCollected( )
	collection.filter.uncollected = FilterGetUncollected( )
	FilterGetFamily( collection.filter.family )
	FilterGetSource( collection.filter.source )
	
	collection.filter.backup = true
	
end

local function FilterActionRestore( )
	
	if not collection.filter.backup then return end
	
	collection.filter.ignore = true
	
	FilterSetSearch( collection.filter.search )
	FilterSetCollected( collection.filter.collected )
	FilterSetUncollected( collection.filter.uncollected )
	FilterSetFamily( collection.filter.family )
	FilterSetSource( collection.filter.source )
	
	collection.filter.backup = false
	
end


function ArkInventory.Collection.Pet.OnHide( )
	ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET", "FRAME_CLOSED" )
end

function ArkInventory.Collection.Pet.IsReady( )
	return collection.isReady
end

function ArkInventory.Collection.Pet.GetCount( )
	return collection.numOwned, collection.numTotal
end

function ArkInventory.Collection.Pet.Iterate( )
	local t = collection.cache
	return ArkInventory.spairs( t, function( a, b ) return ( t[a].fullname or "" ) < ( t[b].fullname or "" ) end )
end

function ArkInventory.Collection.Pet.GetByID( arg1 )
	
	if type( arg1 ) == "number" then
		--ArkInventory.Output( "GetPet( index=", arg1, " ) " )
		for _, obj in ArkInventory.Collection.Pet.Iterate( ) do
			if obj.index == arg1 then
				return obj
			end
		end
		--ArkInventory.Output( "no pet found at index ", arg1 )
		return
	elseif type( arg1 ) == "string" then
		--ArkInventory.Output( "GetPet( guid=", arg1, " ) " )
		if collection.cache[arg1] then
			return collection.cache[arg1]
		else
			--ArkInventory.Output( "no pet found with guid ", arg1 )
		end
	end
	
end

function ArkInventory.Collection.Pet.CanSummon( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return not C_PetJournal.PetIsRevoked( obj.guid ) and not C_PetJournal.PetIsLockedForConvert( obj.guid ) and C_PetJournal.PetIsSummonable( obj.guid )
	end
end

function ArkInventory.Collection.Pet.CanRelease( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PetCanBeReleased( obj.guid )
	end
end

function ArkInventory.Collection.Pet.CanTrade( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PetIsTradable( obj.guid )
	end
end

function ArkInventory.Collection.Pet.Summon( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		C_PetJournal.SummonPetByGUID( obj.guid )
	end
end

function ArkInventory.Collection.Pet.GetCurrent( )
	local guid = C_PetJournal.GetSummonedPetGUID( )
	if guid then
		local obj = ArkInventory.Collection.Pet.GetByID( guid )
		if obj then
			return obj.guid, guid, obj
		end
	end
end

function ArkInventory.Collection.Pet.Dismiss( )
	local guid = ArkInventory.Collection.Pet.GetCurrent( )
	if guid then
		C_PetJournal.SummonPetByGUID( guid )
	end
end

function ArkInventory.Collection.Pet.GetStats( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.GetPetStats( obj.guid )
	end
end

function ArkInventory.Collection.Pet.PickupPet( arg1, arg2 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PickupPet( obj.guid, arg2 )
	end
end

function ArkInventory.Collection.Pet.IsRevoked( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PetIsRevoked( obj.guid )
	end
end

function ArkInventory.Collection.Pet.IsLockedForConvert( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PetIsLockedForConvert( obj.guid )
	end
end

function ArkInventory.Collection.Pet.IsFavorite( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PetIsFavorite( obj.guid )
	end
end

function ArkInventory.Collection.Pet.IsSlotted( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PetIsSlotted( obj.guid )
	end
end

function ArkInventory.Collection.Pet.IsHurt( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return C_PetJournal.PetIsHurt( obj.guid )
	end
end

function ArkInventory.Collection.Pet.InBattle( )
	return C_PetBattles.IsInBattle( )
end

function ArkInventory.Collection.Pet.SetName( arg1, arg2 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		C_PetJournal.SetCustomName( obj.guid, arg2 )
	end
end

function ArkInventory.Collection.Pet.IsUnlocked( )
	return C_PetJournal.IsJournalUnlocked( )
end

function ArkInventory.Collection.Pet.SetFavorite( arg1, arg2 )
	-- arg2 = 0 (remove) | 1 (set)
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		C_PetJournal.SetFavorite( obj.guid, arg2 )
	end
end

function ArkInventory.Collection.Pet.IsUsable( arg1 )
	local obj = ArkInventory.Collection.Pet.GetByID( arg1 )
	if obj then
		return ( IsUsableSpell( obj.spell ) )
	end
end

function ArkInventory.Collection.Pet.GetSpeciesIDfromGUID( guid )
	
	-- breaks apart a guid to get the battlepet speciesid
	-- Creature-[unknown]-[serverID]-[instanceID]-[zoneUID]-[npcID]-[spawnUID]
	
	-- replaced with UnitBattlePetSpeciesID( unit )
	
	local creatureID = string.match( guid or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-.-$" )
	--ArkInventory.Output( creatureID, " / ", guid )
	if creatureID then
		creatureID = tonumber( creatureID ) or 0
		return ArkInventory.Collection.Pet.GetSpeciesIDForCreatureID( creatureID )
	end
	
end

function ArkInventory.Collection.Pet.GetSpeciesIDForCreatureID( creatureID )
	if type( creatureID ) ~= "number" then return end
	if creatureID > 0 then
		return collection.creature[creatureID]
	end
end

function ArkInventory.Collection.Pet.PetTypeName( arg1 )
	return _G[string.format( "BATTLE_PET_NAME_%s", arg1 )] or ArkInventory.Localise["UNKNOWN"]
end


local PET_STRONG = { 2, 6, 9, 1, 4, 3, 10, 5, 7, 8 }
--[[
	HUMANOID vs DRAGONKIN
	DRAGONKIN vs MAGIC
	FLYING vs AQUATIC
	UNDEAD vs HUMANOID
	CRITTER vs UNDEAD
	MAGIC vs FLYING
	ELEMENTAL vs MECHANICAL
	BEAST vs CRITTER
	AQUATIC vs ELEMENTAL
	MECHANICAL vs BEAST
]]--

local PET_WEAK = { 8, 4, 2, 8, 1, 10, 5, 3, 6, 7 }
--[[
	HUMANOID vs BEAST
	DRAGONKIN vs UNDEAD
	FLYING vs DRAGONKIN
	UNDEAD vs AQUATIC
	CRITTER vs HUMANOID
	MAGIC vs MECHANICAL
	ELEMENTAL vs CRITTER
	BEAST vs FLYING
	AQUATIC vs MAGIC
	MECHANICAL vs ELEMENTAL
]]--

local function ScanAbility( abilityID )
	
	if ( not abilityID ) or ( type( abilityID ) ~= "number" ) or ( abilityID <= 0 ) then
		error( "invalid abilityID" )
		return
	end
	
	if not collection.ability[abilityID] then
		
		local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID( abilityID )
		
		collection.ability[abilityID] = {
			name = name,
			icon = icon,
			petType = petType,
			noStrongWeakHints = noStrongWeakHints,
			strong = PET_STRONG[petType],
			weak = PET_WEAK[petType],
		}
		
	end
	
	return collection.ability[abilityID]
	
end

local function LinkTrainerSpecies( speciesID )
	
	assert( speciesID, "speciesID is nil" )
	assert( type( speciesID ) == "number", "speciesID not a number" )
	assert( speciesID > 0, "species ID <= 0 " )
	
	
	local species = collection.species
	assert( species[speciesID], "speciesID is invalid" )
	
	species[speciesID].isTrainer = true
	species[speciesID].td = { }
	
	if not ArkInventory.db then
		ArkInventory.OutputWarning( "saved variables are not ready, cannot link trainer species at this time.  please try again later" )
		return
	end
	
	
	if not collection.isTrainerDataLoaded then
		--ArkInventory.Output2( "linking saved trainer species data into cache" )
		collection.trainer = ArkInventory.db.cache.trainerspecies
		local c = 0
		for k, v in pairs( collection.trainer ) do
			if speciesID ~= k then
				c = c + 1
				species[k] = v
			end
		end
		--ArkInventory.Output2( c, " trainer species entries were linked" )
		collection.isTrainerDataLoaded = true
	end
	
	local trainer = collection.trainer
	-- backup any trainer data
	local td = trainer[speciesID] and trainer[speciesID].td or { }
	-- replace any existing trainer species data with this species data 
	trainer[speciesID] = species[speciesID]
	-- add the trainer data back
	trainer[speciesID].td = td or { }
	
	--ArkInventory.Output2( "linked species ", speciesID, " to trainer species" )
	
end

local function ScanSpecies( speciesID, foundAfter )
	
	assert( speciesID, "speciesID is nil" )
	assert( type( speciesID ) == "number", "speciesID not a number" )
	assert( speciesID > 0, "species ID <= 0 " )
	
	local species = collection.species
	
	if ( not species[speciesID] ) then
		
		local name, icon, petType, creatureID, sourceText, description, isWild, canBattle, isTradable, unique, obtainable, displayID = C_PetJournal.GetPetInfoBySpeciesID( speciesID )
		
--		if name and ( name ~= "" ) then
			
			species[speciesID] = {
				speciesID = speciesID,
				name = name or ArkInventory.Localise["UNKNOWN"],
				icon = icon,
				petType = petType,
				strong = PET_STRONG[petType],
				weak = PET_WEAK[petType],
				creatureID = creatureID,
				sourceText = sourceText,
				description = description,
				isWild = isWild,
				canBattle = canBattle,
				isTradable = isTradable,
				unique = unique,
				obtainable = obtainable,
				abilityID = { },
				abilityLevel = { },
				--foundAfter = not not foundAfter,
				colour = false, -- set on mouseover
			}
			
			local _, maxAllowed = C_PetJournal.GetNumCollectedInfo( speciesID )
			species[speciesID].maxAllowed = maxAllowed
			
			if canBattle then
				
				C_PetJournal.GetPetAbilityList( speciesID, species[speciesID].abilityID, species[speciesID].abilityLevel )
				--ArkInventory.Output( "id = ", species[speciesID].abilityID )
				--ArkInventory.Output( "level = ", species[speciesID].abilityLevel )
				
				for i, abilityID in ipairs( species[speciesID].abilityID ) do
					ScanAbility( abilityID )
				end
				
			end
			
			if not obtainable or foundAfter then
				LinkTrainerSpecies( speciesID )
			end
			
--		end
		
	end
	
	return species[speciesID]
	
end

function ArkInventory.Collection.Pet.GetSpeciesInfo( speciesID )
	if not collection.isReady then return end
	if speciesID and type( speciesID ) == "number" and speciesID > 0 then
		return ScanSpecies( speciesID, true )
	end
end

local function Scan_Threaded( thread_id )
	
	local update = false
	
	local numTotal = 0
	local numOwned = 0
	
	--ArkInventory.Output( "Pets: Start Scan @ ", time( ) )
	
	FilterActionBackup( )
	FilterActionClear( )
	
	
	-- flag all pets as not being processed this scan
	for _, obj in ArkInventory.Collection.Pet.Iterate( ) do
		obj.processed = false
	end
	
	-- scan the pet frame (now unfiltered)
	
	local c = collection.cache
	
	for index = 1, C_PetJournal.GetNumPets( ) do
		
		if PetJournal:IsVisible( ) then
			--ArkInventory.Output( "ABORTED (PET JOURNAL WAS OPENED)" )
			FilterActionRestore( )
			return
		end
		
		numTotal = numTotal + 1
		
		local petID, speciesID, isOwned, customName, level, isFavorite, isRevoked, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, isTradable, isUnique, isObtainable = C_PetJournal.GetPetInfoByIndex( index )
		
		if string.sub( petName, 1, 4 ) == "Fort" then
		--	ArkInventory.Output( petID, " / ", speciesID, " / ", creatureID, " / ", petName )
		end
		-- species data (generate for all species)
		local sd = ScanSpecies( speciesID )
		if not sd then
			FilterActionRestore( )
			ArkInventory.Output( "ABORTED (NO SPECIES DATA)" )
			ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET", "NO_SPECIES_DATA" )
			return
		end
		
		-- creatureid to speciesid lookup (generate for all species)
		if not collection.creature[sd.creatureID] then
			collection.creature[sd.creatureID] = speciesID
			--ArkInventory.Output( sd.creatureID, " = ", speciesID )
		end
		
		
		if petID and isOwned then
			
			local speciesID, customName, level, xp, maxXp, displayID, isFavorite, petName, petIcon, petType, creatureID, sourceText, description, isWild, canBattle, isTradable, isUnique, isObtainable = C_PetJournal.GetPetInfoByPetID( petID )
			local needsFanfare = petID and C_PetJournal.PetNeedsFanfare( petID )
			local health, maxHealth, power, speed, quality = C_PetJournal.GetPetStats( petID )
			quality = quality - 1 -- back down to item colour
			--local link = ArkInventory.BattlepetBaseHyperlink( speciesID, level, quality, health, power, speed, customName, petID )
			local link = C_PetJournal.GetBattlePetLink( petID )
			
			
			if not canBattle then
				--ArkInventory.Output2( petName, " / ", health, " / ", maxHealth )
			end
			
			numOwned = numOwned + 1
			
			local i = petID
			
			if not c[i] then
				c[i] = { index = index }
				update = true
			end
			
			if c[i].guid ~= petID then
				c[i].guid = petID
				c[i].sd = collection.species[speciesID] -- species data for this pet
				update = true
			end
			
			local breed = BreedAvailable and GetBreedID_Journal( petID )
			if c[i].breed ~= breed then
				c[i].breed = breed
				update = true
			end
			
			if c[i].cn ~= customName then
				c[i].cn = customName
				update = true
			end
			
			local fullname = petName
			if customName then
				fullname = string.format( "%s (%s)", petName, customName )
			end
			c[i].fullname = fullname
			
			if c[i].fav ~= isFavorite then
				c[i].fav = isFavorite
				update = true
			end
			
			if c[i].isRevoked ~= isRevoked then
				c[i].isRevoked = isRevoked
				update = true
			end
			
			if c[i].needsFanfare ~= needsFanfare then
				c[i].needsFanfare = needsFanfare
				update = true
			end
			
			if c[i].level ~= level then
				c[i].level = level
				c[i].maxXp = maxXp
				c[i].maxHealth = maxHealth
				c[i].power = power
				c[i].speed = speed
				update = true
			end
			
			if c[i].xp ~= xp then
				c[i].xp = xp
				update = true
			end
			
			if c[i].health ~= health then
				c[i].health = health
				update = true
			end
			
			if c[i].quality ~= quality then
				update = true
				c[i].quality = quality
				
			end
			
			if c[i].link ~= link then
				update = true
				c[i].link = link
			end
			
			c[i].active = false
			c[i].processed = true
			
		end
		
	end
	
	
	-- cleanup any old pets that were released/caged
	for _, obj in ArkInventory.Collection.Pet.Iterate( ) do
		if not obj.processed then
			c[obj.guid] = nil
			update = true
		end
	end
		
		
	ArkInventory.ThreadYield_Scan( thread_id )
	
	FilterActionRestore( )
	
	collection.numOwned = numOwned
	collection.numTotal = numTotal
	
	--ArkInventory.Output( "Pets: End Scan @ ", time( ), " [", collection.numOwned, "] [", collection.numTotal, "]  [", update, "]" )
	
	if not collection.isReady then
		collection.isReady = true
		--ArkInventory.Output2( "pet data is now ready" )
	end
	
	ArkInventory.Collection.Pet.ImportCrossRefTable( )
	
	if update then
		ArkInventory.ScanLocation( loc_id )
--		ArkInventory.LDB.Pets:Update( )
	end
	
end

local function Scan( )
	
	local thread_id = string.format( ArkInventory.Global.Thread.Format.Collection, "pet" )
	
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


function ArkInventory:EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET( events )
	
	--ArkInventory.Output( "PET BUCKET [", events, "]" )
	
	if not ArkInventory:IsEnabled( ) then return end
	
	if ArkInventory.Global.Mode.Combat then
		-- set to scan when leaving combat
		ArkInventory.Global.LeaveCombatRun[loc_id] = true
		return
	end
	
	if not ArkInventory.isLocationMonitored( loc_id ) then
		--ArkInventory.Output( "IGNORED (PETS NOT MONITORED)" )
		return
	end
	
	if PetJournal:IsVisible( ) then
		--ArkInventory.Output( "IGNORED (PET JOURNAL IS OPEN)" )
		return
	end
	
	if not collection.isScanning then
		collection.isScanning = true
		Scan( )
		collection.isScanning = false
	else
		--ArkInventory.Output( "IGNORED (PET JOURNAL BEING SCANNED - WILL RESCAN WHEN DONE)" )
		ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET", "RESCAN" )
	end
	
end

function ArkInventory:EVENT_ARKINV_COLLECTION_PET_UPDATE( event, ... )
	
	--ArkInventory.Output( "PET UPDATE [", event, "]" )
	
	if event == "PET_JOURNAL_LIST_UPDATE" then
		
		if collection.filter.ignore then
			--ArkInventory.Output( "IGNORED (FILTER CHANGED BY ME)" )
			collection.filter.ignore = false
			return
		end
		
		ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET", event )
		
	elseif ( event == "COMPANION_UPDATE" ) then
		
		local c = ...
		if ( c == "CRITTER" ) then
			ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET", event )
		end
		
	else
		
		ArkInventory:SendMessage( "EVENT_ARKINV_COLLECTION_PET_UPDATE_BUCKET", event )
		
	end
	
end

function ArkInventory:EVENT_ARKINV_BATTLEPET_OPENING_DONE( event, ... )
	
	--ArkInventory.Output( "EVENT_ARKINV_BATTLEPET_OPENING_DONE" )
	-- /run ArkInventory:EVENT_ARKINV_BATTLEPET_OPENING_DONE( "MANUAL" )
	
	-- WARNING WARNING WARNING - THIS MUST RUN TO COLLECT SPECIES DATA FOR THE LEGENDARY / ELITE / TRAINER PETS
	
	
	local player = LE_BATTLE_PET_ENEMY or 2
	local isnpc = C_PetBattles.IsPlayerNPC( player )
	local opponents = C_PetBattles.GetNumPets( player )
	
	if ArkInventory.db.option.message.battlepet.opponent then
	--	if opponents > 1 then
			ArkInventory.Output( "--- --- --- --- --- --- ---" )
	--	end
	end
	
	if not ArkInventory.Collection.Pet.IsReady( ) then
		if ArkInventory.db.option.message.battlepet.opponent then
			ArkInventory.Output( "pet data not ready" )
		end
		return
	end
	
	for i = 1, opponents do
		
		local speciesID = C_PetBattles.GetPetSpeciesID( player, i )
		local name = C_PetBattles.GetName( player, i )
		local level = C_PetBattles.GetLevel( player, i )
		local maxHealth = C_PetBattles.GetMaxHealth( player, i )
		local power = C_PetBattles.GetPower( player, i )
		local speed = C_PetBattles.GetSpeed( player, i )
		local breed = ""
		
		if BreedAvailable then
			breed = string.format( " %s", GetBreedID_Battle( { ["petOwner"] = player, ["petIndex"] = i } ) )
		end
		
		local quality = C_PetBattles.GetBreedQuality( player, i )
		quality = ( quality and ( quality - 1 ) ) or -1
		
		local info = ""
		local count
		
		local sd = ArkInventory.Collection.Pet.GetSpeciesInfo( speciesID )
		if not sd then
			
			info = string.format( " %s%s", RED_FONT_COLOR_CODE, ArkInventory.Localise["NO_DATA_AVAILABLE"] )
			
		else
			
			if sd.isTrainer then
				
				LinkTrainerSpecies( speciesID )
				
				-- update saved trainer pet data
				local td = collection.trainer[speciesID].td
				td.level = level
				td.quality = quality
				td.colour = select( 4, ArkInventory.GetItemQualityColor( quality ) )
				sd.colour = td.colour
				td.health = maxHealth
				td.power = power
				td.speed = speed
				td.breed = breed
				
			end
			
			
			if C_PetBattles.IsWildBattle( ) then
				
				--ArkInventory.Output2( "wild battle" )
				
				if sd.isTrainer then
					-- elite/legendary, dont add anything
				elseif not sd.canBattle then
					-- opponent cannot battle (and yet it is), its one of the secondary non-capturabe opponents
					info = string.format( " %s(%s)", YELLOW_FONT_COLOR_CODE, ArkInventory.Localise["BATTLEPET_OPPONENT_IMMUNE"] )
				else
					count = true
				end
				
			elseif isnpc then
				-- npc battle, dont add anything
			else
				-- pvp battle, dont add anything, but do show collected
				count = true
			end
			
			if count and ArkInventory.db.option.message.battlepet.opponent then
				
				-- add matching pets that you have already captured
				
				local numOwned, maxAllowed = C_PetJournal.GetNumCollectedInfo( speciesID )
				
				if numOwned == 0 then
					
					if sd.obtainable then
						info = string.format( "%s- %s", RED_FONT_COLOR_CODE, ArkInventory.Localise["NOT_COLLECTED"] )
					end
					
				else
					
					if numOwned >= maxAllowed then
						
						info = string.format( "- %s", ArkInventory.Localise["BATTLEPET_OPPONENT_KNOWN_MAX"] )
						
					elseif C_PetBattles.IsWildBattle( ) then
						
						local upgrade = false
						
						for _, pd in ArkInventory.Collection.Pet.Iterate( ) do
							if ( pd.sd.speciesID == speciesID ) then
								
								local q = pd.quality
								--ArkInventory.Output( "s=[", speciesID, "], ", h, ", [", quality, "] / ", pd.link, " [", q, "]" )
								if ( quality >= q ) then
									upgrade = true
								end
								
								if string.len( info ) < 2 then
									info = string.format( "- %s", ArkInventory.Localise["BATTLEPET_OPPONENT_UPGRADE"] )
								end
								
								info = string.format( "%s  %s", info, pd.link )
								
								if pd.breed then
									info = string.format( "%s %s", info, pd.breed )
								end
								
							end
						end
						
						if not upgrade then
							info = ""
						end
						
					end
					
				end
				
			end
			
			
			--ArkInventory.Output( YELLOW_FONT_COLOR_CODE, ArkInventory.Localise["BATTLEPET"], " #", i, ": ", h, " ", YELLOW_FONT_COLOR_CODE, info )
			
		end
		--ArkInventory.Output2( { speciesID, level, quality, maxHealth, power, speed, "", name } )
		
		if ArkInventory.db.option.message.battlepet.opponent then
			local h = string.format( "%s|Hbattlepet:%s:%s:%s:%s:%s:%s:%s|h[%s]|h|r", select( 5, ArkInventory.GetItemQualityColor( quality ) ), speciesID, level, quality, maxHealth, power, speed, "", name )
			ArkInventory.Output( YELLOW_FONT_COLOR_CODE, "#", i, ": ", h, breed, " ", YELLOW_FONT_COLOR_CODE, info )
		end
		
	end
	
end


-- unit guid, from mouseover = Creature-[unknown]-[serverID]-[instanceID]-[zoneUID]-[creatureID]-[spawnUID]
-- caged battletpet (item) = battlepet:
-- pet journal = battlepet:[speciesID]:16:3:922:185:185:[guid]

--[[

battlepet:1387:1:3:152:12:11:BattlePet-0-000006589760
battlepet:1387:1:3:155:12:10:0000000000000000
item:111660:0:0:0:0:0:0:0:90:0:11:0

]]--


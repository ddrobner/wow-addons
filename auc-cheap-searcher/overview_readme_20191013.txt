   This is a search filter module for Auctioneer. It is based on the vendor searcher but was modified to allow searching for items which are listed under, at or above the sell-to-vendor price.
This addon can be used in both Classic and Retail WoW, it will detect at runtime which game version you are using and it will adjust its interface accordingly. Please note that items below 100% vendor price are always included in the list of results to preserve the original vendor searcher behaviour.  Also, items without a sell-to-vendor price are not included in the results, neither for the normal search mode nor for the transmog search mode. Wowhead currently shows 64 such items usable for transmog but the game does not allow any of them to be listed for sale in the Auction House. In addition, when Blizzard's API gives up to provide info about an item it will also be temporarily considered as having no vendor price.

   For WoW 8+ an "unknown transmog" search filter can be applied to the items listed at above-vendor prices. This is the transmog search mode. In this search mode, an item with a price that is above the sell-to-vendor threshold will be shown in the list of search results only if it is usable as such but not collected as transmog. When the filter option checkbox to only show items that belong to a transmog set is active then the entered maximum price limit is also multiplied internally by 100 to catch more possible set items.

When in transmog search mode, I recommend sorting on the Profit column at all times even if it's negative profit because percentages relative to vendor price can vary wildly, some items can be priced at 5000% or even more relative to their sell-to-vendor value but the net cost (=negative profit) of the item could be just 30...50g.

 If you want to filter out items with appearances known from another item then disable the "completionist mode" checkbox.

  The addon Can I Mog It? is also needed to help with the advanced appearance selection logic when looking for unknown random transmogs:
a) If "Can I Mog It?" is active then the searcher will use improved transmog detection logic with API calls to its functions when searching.
b) If "Can I Mog It?" is not active then fall back and use only the Blizzard default simplified transmog logic but please note that it WILL return weird results because this search mode was not designed to be terribly accurate, just "good enough". In this case a transmog search will only look for unknown transmog items for the currently active character class and level. If you want to search for missing transmogs for your other alts you should either log out and login on the correct character or install the "Can I Mog It?" addon - its database is needed for this. Also, appearances that are already collected but from another item are considered as "not known". The interface will also hide the filter option checkboxes that are only relevant for searches that use the "Can I Mog It?" helper addon (see screenshots): transmogs for other classes (alts), item sets and filtering out appearances known from other items.

 

For Classic WoW: the transmog search and its related interface options are completely disabled because transmogrification is impossible in Classic. 

 

For both Classic and WoW8+ the "extra factor" slider is used to control how high above the vendor price you want to look for items. The default setting of 20% limits the search to items listed at maximum 120% of vendor price (=100% + the slider additional value) for the selected search method.
Please note that for WoW8+ the slider will be used only when searching with transmog mode OFF because limiting the percentage can have side efects for transmog searches. (why? scroll up and read the third paragraph.)

 

 Please post problems as issue tickets on Curseforge

This addon is just a tool, decide for yourself if the item is worth buying or bidding on or just let it go.

addon license: GPL2, same as Auctioneer.
Note: old versions of this addon are tagged as archived on Curseforge and thus not normally visible on Curse/Twitch, they are not supported.
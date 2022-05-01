# Isaac: Four Souls Complete (Edited)
This Tabletop Simulator [[1]](https://store.steampowered.com/app/286160/Tabletop_Simulator/) Mod is based on the Community Mod [Isaac: Four Souls Complete](https://steamcommunity.com/sharedfiles/filedetails/?id=2526757138&searchtext=issac+four+souls+full) from Edgey [[2]](https://steamcommunity.com/id/l-l34l27_4774CK). This mod extands the original one by some quality of life changes and a lot of new features, which can be used in future versions.

## What can I find in this Depot?
- The `ttslua` scripts for the Tabletop Simulator Mod. This are the main part of this repo.
- **Working Save-Files:** This folder contains ready-to-play save files. It is recommended to use the save file with the highest number in its name.
  > Copy the `.json` file and the `.png` file and past them into your `Documents/My Games/Tabletop Simulator/Saves` folder.
- This repository also contains a Python 3 script tool for quickly modifing `TTS-JSON` files.\
  Is is called `JSON-Sniffer`. We use it to extract monster states from the description of a monster card and transform them into Lua code

## How to use this repository with Tabletop Simulator?
1. First of all follow the [Installation Instructions](https://api.tabletopsimulator.com/atom/) on the [Tabletop Simulator Page](https://api.tabletopsimulator.com/atom/) to install Atom and the Tabletop Simulator Plugin.
2. Install [Git](https://git-scm.com/) and create a GitHub account
3. Configure Atom with your local installation of Git and link your GitHub account
4. Copy the [HTTPS](https://github.com/Ediforce44/IsaacFourSoulsEdited.git) or [SSH](git@github.com:Ediforce44/IsaacFourSoulsEdited.git) of this repository
5. Click `Clone an existing GitHub repository...` in the GitHub tab of the Atom Texteditor
6. Paste the repository link and select the following folder to clone the repository in:\
   `C:\Users\Name\AppData\Local\Temp\TabletopSimulator`\
   Then press `Clone`.
    > **NOTE:** If it doesn't work and you only see the `.git` folder in Atom you have to clone the repository manually for example with the GitBash from Git or [GitKraken](https://www.gitkraken.com/) etc.
7. Now you should see all folders of this Repository in your Atom Project folder `TabletopSimualtor`.
8. The last step is to load a save file of this mod. Just follow the steps from the point **Working Save-Files** [here](#what-can-i-find-in-this-depot)
9. Open Tabletop Simulator and load the copied save file.
> **COMMON PROBLEM:** If you close Atom and open it again, the `.ttslua` files in folder `Tabletop Simulator Lua` have been deleted. If so, just select `Discard All Changes` in the Git-Tab from Atom. It needs a few seconds until all files are recovered. Beware that if you have this problem, you need to stage or commit all your changes before you close Atom. Otherwise all changes will be destroyed.

## Philosophy
The original idea was to fully automate the whole card game with interacting scripts for each monster, loot or treasure card. The downside of this idea is that a lot of funny situation in a game session get lost. For example a player forget to use a item and change the floor etc. If the game would be fully automated each player would play with his best performance and so many player interactions and communication get lost.

So the philosophy of this mod is to automate things that have to be done anyways and are just "annoying" to do by hand. This mod also tries to pick up the ideas of the original mod and extend them in some ways. For example if you click on your Loot-Counter, you will draw a loot card. This mod supports also a lot of visual representations of what is going on right now in the game. It is representet by broadcast messages, so every player is kept informed.
> **Example:**\
You play with three random players and only one uses the voice chat and the outher players use the ping mechanic. Sometimes if you read a card text etc. you will lost the overview of the playboard, especially if not all player say what say gonna do. This mod tries to compensate this issue.

## Change log
> **Extensions of original content:**
> - Clicking on a Loot-Counter will deal the `Owner` the top most loot card from the Loot-Deck
> - Clicking on a Soul-Counter will deal the `Owner` a Soul-Token card into his Soul-Zone

> **New gameplay stuff:**
> - Monster-Buttons will appear under the Monster-Zones. This Buttons manage the whole monster module. Attacking monsters and activating and deactivating of Monster-Zones can be handled with this Monster-Buttons.
> - The game detects if a monster get killed and ask the player to finish the monster. The players can take their time to treat all dying/killing effects. If the monster get finished the `active player` will get the killing reward automatically (if it is not anything special).
> - Monsters which have souls as rewards will be placed in the Soul-Zone of the `active player` if they got finished.
> - The automated rewarding feature can be turned of with a button in front of and independent for each player. This button can be locked and unlocked.
> - Shop-Buttons will appear under the Shop-Zones. This Buttons manage the whole shop and treasure module. Buying shop items and activating and deactivating of Shop-Zones can be handled with this Shop-Buttons.
> - All new buttons are only useable by the `active player`,the `owner` of the button or an `admin`.
> - Whenever an active Monster-Zone or Shop-Zone is empty, a new card will be placed in the zone.
> - A new thing called Player-Zones is added. Player-Zones represent the zone in witch a player lays down his character and items. Treasures will be put automatically in the next free slot.
> - If the Player-Zone is full, new cards will be dealt to the hand of the player, so the player can place them where they want.
> - The same thing goes for Soul-Tokens or other soul cards. The Soul-Zone will manage the automated placements of soul cards.

> **New modding stuff:**
> - New Zones are introduced for each `monster field`, `shop field`, `player field` and for the `Soul-Tokens`. They are called Monster-Zones, Shop-Zones and Player-Zones. 
> - The Monster-Buttons and Shop-Buttons belong to the corresponding zones. The Auto-Reward-Button are managed by the corresponding Soul-Zone of the player.
> - Monster-Zones are managed by the Monster-Zone for the Monster-Deck and Shop-Zones are managed by the Shop-Zone for the Treasure-Deck. The Deck-Zones contain global functions to change the state of a zone or button, etc.\
>  The individual zones contain global functions to activate/deactivate the zone or the button, etc.
> - The Soul-Zones and Player-Zones contain global functions to get the next free position in the zone and to place cards in them.
> - The Coin-Counter now containes a global function to modify the coin value.
> 
> >**The GLOBAL script contains:**
> > - Tables with GUIDs all Zones and Heart-Tokens
> > - Tables with GUIDs of all Coin-Counters and Monster-HP-Counters
> > - Table with the state of the auto-rewarding for each player
> > - Tables with HTML-Color codes for all gameplay components 
> > - Table with the RGB-Colors of the players
> > - Table with the positions of the discard piles for each deck
> > - Functions for getting references to all types of decks
> > - Functions for getting a deck from a zone or a card from a deck
> > - Functions for getting the active player, his color, his Player-Zone or a print-ready string of the active player.
> > - Function for checking if the player is authorized (has a specific color or is an admin)
> > - Function for switching the auto-rewarding mode
> > - Function for placing a Soul-Token in the active players zone.
> > - Function for filtering variables out of a Lua-Script string
> > **Note:** A function for filtering a Table out of a Lua-Script string is located in the Monster-Zone scripts

# Modding API 
## (For everybody who want to add Boosterpacks or Scripts)
In this chapter are the most important variables and functions listed for modders. Those attributes are grouped by the script in which they are implemented. \
The keys of Tables are normally written in caps. If a Table refers to something player specific the keys of the Table are the player colors `Red`, `Blue`, `Green` and `Yellow`. \
All functions with parameters and a return value will return `nil` if the parameters are missing. \
We will talk about INFO-MSGs. This are Messages which will be printed for one or more player. The message will tell them what happened and what happens.

> ## <b>Global</b>
> > ### <u><b>Tables</b></u>
> > - `CLICK_DELAY` containes the Value, which is used to determine a Double Click on something.\
> > (Current value: 0.3 sec)
> > 
> > Colors (often used for prints and broadcasts):
> > - `REAL_PLAYER_COLOR` containes HTML color codes with all four player colors. The keys are the ingame player colors **Red**, **Blue**, **Green** and **Yellow**.
> > - `REAL_PLAYER_COLOR_RGB` containes RGB percentage values for the **REAL_PLAYER_COLOR** entries. It has the same keys as **REAL_PLAYER_COLOR**.
> > - `PRINT_COLOR_PLAYER` simular to **REAL_PLAYER_COLOR**, but the keys are in caps.
> > - `PRINT_COLOR_SPECIAL` containes many types of HTML color codes for all types of game components. The keys are also written in caps.
> >
> > GUIDs of Zones:
> > - `ZONE_GUID_DECK` containes the GUIDs of all deck zones in the game.
> > - `ZONE_GUID_SHOP` containes the GUIDs of the six Shop Zones. The keys are **ONE** to **SIX**.
> > - `ZONE_GUID_MONSTER` containes the GUIDs of the six Monster Zones. The keys are **ONE** to **SIX**.
> > - `ZONE_GUID_PLAYER` containes the GUIDs of the Player Zones in front of each player. The keys are the ingame player colors **Red**, **Blue**, **Green** and **Yellow**
> > - `ZONE_GUID_SOUL` containes the GUIDs of the Soul Zones in front of each player next to their Player Zone. The keys are the ingame player colors.
> >
> > GUIDs of game components:\
> > - `HEART_TOKENS_GUID` containes Tables of GUIDs corresponding to the Heart Tokens in front of each player. The GUIDs of the Heart Tokens are in the correct order. The keys are the player colors.
> > - `FIRST_HEARTS_GUID`. The keys are the player colors.
> > - `COIN_COUNTER_GUID`. The keys are the player colors.
> > - `MONSTER_HP_COUNTER_GUID` containes the GUIDs of the HP Counters for the six Monster Zones. The keys are **ONE** to **SIX**.
> > - `COUNTER_BAGS_GUID` containes the GUIDs of the ingame bags of counters. The keys are in caps.
> >
> > Positions:
> > - `DISCARD_PILE_POSITION` containes the positions of the discard piles for each deck. The keys are in caps.
> >
> > Other Tables:
> > - `automaticRewarding` containes the *true* or *false* if the automatic rewarding is activated for a player. The keys are the player colors.
>
> > ### <u><b>Variables</b></u>
> > - `activePlayerColor` containes the player color *string* of the player who is the active player.
> 
> > ### <u><b>Getter Functions</b></u>
> > - `getDeckFromZone(zoneGUID) : object` returns the first deck or card in the zone with the GUID **zoneGUID**. If there is no deck or card, it will return *nil*.
> > - `getMonsterDeck() : object` returns the first deck or card in the Monster Zone. If there is no deck or card it will return *nil*.
> > - `getHappenDeck() : object` ...
> > - `getTreasureDeck() : object` ...
> > - `getLootDeck() : object` ...
> > - `getBonusSoulDeck() : object` ...
> > - `getFloorDeck() : object` ...
> > - `getSoulTokenDeck() : object` ...
> > - `getActivePlayerString() : string` returns the color of the active player as a *string* tinted in the same color.
> > - `getActivePlayerZone() : zone` returns the Player Zone of the active player.
> 
> > ### <u><b>Other Functions</b></u>
> > - `getCardFromDeck({deck}) : object` takes a card from the **deck** and return a reference on this card. If **deck** is a card it will return **deck**.
> > - `getPlayerString({playerColor}) : string` returns a the **playerColor** as a *string* tinted in the same color.
> > - `getCounterInZone({zone}) : object` returns the first object in **zone** with the name "Counter".
> > - `isPlayerAuthorized({playerColor or player, ownerPlayer}) : bool` returns *true* if the the player **player** or player with the **playerColor** equals **ownerPlayer**. It will return also *true* if **player** or the player with the **playerColor** is an admin.
> > - `findIntInScript({scriptString, varName}) : int` searches in the **scriptString** for a variable with the name **varName** and returns the value of it.
> > - `switchRewardingMode({playerColor or player})` switches the Rewarding Mode for **player** or the player with the **playerColor**.
> > - `colorPicker_attach({afterPickFunction, functionOwner, picker, reason}) : bool` attaches **afterPickFunction** to the **Color-Picker System**. The **Color-Picker** is explained in chapter [Color-Picker](#color-picker). \
> Only **afterPickFunction** and **functionOwner** have to be set. If picker is unset, the active player will be the picker. \
> Returns *true* if **afterPickFunction** could be attached successfully.
> > - `placeSoulToken({playerColor})` takes a Soul Token from the soul token deck and places it in the Soul Zone of the player with the color **playerColor**. Prints a INFO-MSG. If the soul zone is full the Soul Token will be dealed to the Hand Zone of the player.
> > - `placeObjectInSoulZone({playerColor, object})` places **object** in the Soul Zone of the player with color **playerColor**. If the Soul Zone is full the **object** will be dealed to the Hand Zone of the player.
> > - `placeObjectInPillZone({playerColor, object})` places **object** in the Pill Zone of the player with color **playerColor**. If the Pill Zone is full the **object** will be dealed to the Hand Zone of the player.

> ## <b>Coins</b>
> > ### <u><b>Variables</b></u>
> > - `value` is the current amount of coins. \
> > (Minimum: 0, Maximum: 999)
> 
> > ### <u><b>Functions</b></u>
> > - `modifyCoins({modifier})` adds or subtracts the **modifier** based on its sign to the current amount of coins.

> ## <b>HP (Monster)</b>
> > ### <u><b>Variables</b></u>
> > - `value` is the current HP of the active monster in the corresponding zone. \
> > (Minimum: 0, Maximum: 9)
> 
> > ### <u><b>Functions</b></u>
> > - `updateHP({HP})` sets the *value* of this HP-Counter to **HP**. **HP** has to be positiv and lower than 10.
> > - `reset()` sets the *value* of this HP-Counter to the HP-Value of the active monster in the corresponding zone, if it isn't 0. \
> > (This function uses the *active_monster_attrs* from the Monster Zone)

> ## <b>Monster Zone</b>
> > ### <u><b>Tables</b></u>
> > - `active_monster_attrs` containes the attributes of the active monster in this zone. The keys are **GUID**, **NAME**, **HP**, **ATK** and **DMG**.
> > - `active_monster_reward` containes the amount of rewards of the active monster in this zone. The keys are **CENTS**, **LOOT**, **TREASURES** and **SOULS**.
> 
> > ### <u><b>Variables</b></u>
> > - `active` is *true*, if this zone is an active monster zone.
> 
> > ### <u><b>Getter Functions</b></u>
> > - `getAttackButton() : button` returns a reference of the monster button of this zone. If the monster button is deactivated if will return *nil*.
> > - `getState() : string` returns the state of this zone. The state of a zone is the same as the state of its monster button. And the state of a monster button is its *label*. \
> If the monster button of this zone is deactivated it will return *nil*. \
> All states of a monster zone and its monster button are listet in the *Table* **ATTACK_BUTTON_STATES** in the Monster-Deck Zone script.
> 
> > ### <u><b>Technical Functions</b></u>
> > - `containsDeckOrCard() : bool` returns *true* if this zone containes a *deck* or *card*.
> > - `resetMonsterZone()` sets the state/*label* of the monster button of this zone to **ATTACK** if this zone is *active*, otherwise to **INACTIVE**. If the monster button of this zone is deactivated the button will be activated. \
> > The HP-Counter of this zone will also be reseted.
> > - `deactivateAttackButton()` let the monster button of this zone disappear. (This function removes the button)
> > - `activateAttackButton()` let the monster button reappear in the state **ATTACK** if the zone is active and **INACTIVE** otherwise. (This function creates the button)
> > - `deactivateZone()` discards all *decks* or *cards* in this zone and sets the monster attributes of this zone to zero. It activates the monster button of this zone and sets it to the state **INACTIVE**.
> > - `activateZone()` places a new monster card in this zone if there is no *deck* or *card*. It activates the monster button of this zone and sets it to the state **ATTACK**.
> > - `changeButtonState({newState}) : bool` changes the state of the monster button of this zone to **newState** and return *true*. If the monster button of this zone is deactivated or the **newState** is no valid state, it will return *false*. 
> 
> > ### <u><b>Monster Functions</b></u>
> > - `monsterDied()` sets the HP-Counter of this zone to 0 and the state of this zone to **DIED** and prints an *INFO-MSG*. Only works if the monster button of this zone is activated.
> > - `monsterReanimated()` prints an *INFO-MSG* and sets the state of this zone to the last state of this zone before **monsterDied()** was called. (So you have to use it in combination with **monsterDied()**)
> > - `finishMonster()` pays out the reward of the active monster to the active player if Auto-Rewarding for the active player is activated. /
> >   - It takes the first *card* in this zone or the topmost *card* of the first *deck* in this zone and discard the card if the reward **SOULS** is 0. Otherwise the card will be placed in the soul zone of the active player.
> >   - The `onDie()` function of the card will be executed and if it returns *true* or *nothing*, the card will be taged as **DEAD** and a new monster card will be placed in this zone it is empty.
> > - `updateAttributes({HP, GUID, NAME, ATK, DMG})` updates the Table **active_monster_attrs** to the given values. All parameters are optional except **HP**. **HP** has to be set otherwise this function does nothing. \
> The HP-Counter for this zone will also be updated. \
> If this function is called with some unset parameters, the attributes will be set their standard value. \
> (Strandard: GUID = last GUID, NAME = "", ATK = -1, DMG = -1)
> > - `updateRewards()` updates the Table **active_monster_reward** to the given values. \
> If this function is called with some unset parameters, the attributes will be set to 0.

> ## <b>Monster-Deck Zone</b>
> > ### <u><b>Tables</b></u>
> > - `CHOOSE_BUTTON_STATES` contains all valid states for the monster button of this Monster-Deck Zone. The keys are **ATTACK** and **CHOOSE**.
> > - `ATTACK_BUTTON_STATES` contains all valid states for the monster buttons of the Monster Zones and the Monster Zone itself. The keys are **INACTIVE**, **ATTACK**, **ATTACKING**, **CHOOSE**, **DIED** and **EVENT**.
> > - `MONSTER_TAGS` contains all tags which are used to tag a monster card. The keys are **NEW** and **DEAD**. \
> The tag **NEW** will be removed from a object if it enters a monster zone. The tag **DEAD** will be removed from a object if it enters the discard pile for monster cards.
>
> > ### <u><b>Techincal Functions</b></u>
> > - `containsDeckOrCard({zone}) : bool` returns *true* if the monster zone **zone** contains a *deck* or a *card*.
> > - `deactivateChooseButton()` let the monster button of this zone disappear. (This function removes the button)
> > - `activateChooseButton()` let the monster button reappear in the state **ATTACK**. (This function creates the button)
> > - `resetMonsterZone()` sets the state/*label* of the monster button of this zone to **ATTACK**. If the monster button of this zone is deactivated the button will be activated.
> > - `resetAllMonsterZones()` resets the Monster-Deck Zone and all other Monster-Zones. (Have a look at the **resetMonsterZone()** functions)
> > - `changeZoneState({zone, newState})` changes the state of the Monster Zone **zone** to **newState**. The **newState** has to a state from **ATTACK_BUTTON_STATES**. What will happen on a state change depends on the **newState**. In some cases, all other monster buttons will be activated etc.
>
> > ### <u><b>Monster Functions</b></u>
> > - `discardActiveMonsterCard({zone})` is simular to **finishMonster()** from Monster Zone. 
> >   - It takes the topmost *card* of the first *deck* in the **zone** or the first *card* in the **zone** and discards it (no matter if it has a **SOULS** attribute).
> >   - The **onDie()** functions of the taken monster card will be called and if it returns *true* a new monster card will be placed in the **zone** if the **zone** is now empty. \
> If **onDie()** returns *false* the tag **DEAD** is removed from the taken monster card.
> > - `discardMonsterObject({object})` places the **object** on to the discard pile for monster cards and adds the tag **DEAD** to the object.
> > - `placeNewMonsterCard({zone, isTargetOfAttack}) : bool` takes the topmost *card* from the monster deck, flips it and places it in the Monster Zone **zone**.
> >   - If the new card has a variable `isEvent` and if it is *true*, an INFO-MSG will be printed. \
> >  If the new card also has an variable called `type` and if it equals the *EVENT_TYPE* **CURSE**, ... TODO
> >   - If the new card is not a event and **isTargetOfAttack** is *true*, another INFO-MSG will be printed.
> >   - This function will only return *false* if it couldn't find a new monster card to place it in the **zone**.

> ## <b>Shop Zone</b>
> > ### <u><b>Variables</b></u>
> > - `active` is *true*, if this zone is an active shop zone
>
> > ### <u><b>Functions</b></u>
> > - `containsDeckOrCard() : bool` returns *true*, if this zone containes a *deck* or *card*.
> > - `deactivateZone()` discards all *decks* or *cards* in this zone. It activates the purchase button of this zone and sets it to the state **INACTIVE**.
> > - `activateZone()` places a new treasure card in this zone if there is no *deck* or *card*. It activates the purchase button of this zone and sets it to the state **PURCHASE**.
> > - `deactivatePurchaseButton()` let the purchase button of this zone disappear. (This function removes the button)
> > - `activatePurchaseButton()` let the purchase button reappear in the state **PURCHASE** if the zone is active and **INACTIVE** otherwise. (This function creates the button)

> ## <b>Shop-Deck Zone</b>
> > ### <u><b>Tables</b></u>
> > - `PURCHASE_BUTTON_STATES` contains all valid states for the purchase button of the shop zones. The keys are **PURCHASE** and **INACTIVE**.
> > - `SHOP_BUTTON_STATES` contains all valid states for the shop button of this Shop-Deck Zone. The keys are **PURCHASE** and nothing else.
>
> > ### <u><b>Functions</b></u>
> > - `deactivateShopButton()` let the shop button of this zone disappear. (This function removes the button)
> > - `activateShopButton()` let the shop button reappear in the state **PURCHASE**.
> > - `changeZoneState({zone, newState})` changes the state of the Shop Zone **zone** to **newState**. The **newState** has to be a state from **ATTACK_BUTTON_STATES**. What will happen on a state change depends on the **newState**.
> > - `placeNewTreasureCard({zone}) : bool` takes the first *card* or the topmost *card* of the first *deck* in the treasure zone. It filps this card and put it into the shop zone **zone**. It returs *false* if no card was found in the treasure zone.

> ## <b>Player Zone</b>
> > ### <u><b>Variables</b></u>
>
> > ### <u><b>Functions</b></u>

> ## <b>Pill Zone</b>
> > ### <u><b>Tables</b></u>
> > - `attachedObjects` contains all objects that are currently in this Pill Zone. The keys are the *GUIDs* of the objects. The value for a *GUID* is 1 if the corresponding object is in this Pill Zone and *nil* otherwise.
>
> > ### <u><b>Variables</b></u>
> > - `INDEX_MAX` is the maximum index in this Pill Zone. For every Pill Zone it is 2. Every index belongs to a fixed position in this zone.
>
> > ### <u><b>Functions</b></u>
> > - `placeObjectInZone({object})` places **object** in this Pill Zone. If this Pill Zone is full the **object** will be dealed to the Hand Zone of the player.

> ## <b>Soul Zone</b>
> > ### <u><b>Tables</b></u>
> > - `attachedObjects` contains all objects that are currently in this Soul Zone. The keys are the *GUIDs* of the objects. The value for a *GUID* is 1 if the corresponding object is in this Soul Zone and *nil* otherwise.
>
> > ### <u><b>Variables</b></u>
> > - `INDEX_MAX` is the maximum index in this Soul Zone. For every Soul Zone it is 4. Every index belongs to a fixed position in this zone.
>
> > ### <u><b>Functions</b></u>
> > - `placeObjectInZone({object})` places **object** in this Soul Zone. If this Soul Zone is full the **object** will be dealed to the Hand Zone of the player.

> ## <b>Souls</b>
> > ### <u><b>Variables</b></u>
>
> > ### <u><b>Functions</b></u>

## Color-Picker
## onReveal()
## onDie()

# Things to do
## TODO-List
- Fix Player Turn system (Order etc.)
- Add logic for Event-Monster-Cards

## Future work
- Automate Bonus-Souls and there counter
- The Language-Button-Problem
- Add Deck-Builder System
- Fix Player Turn system in the Floor Change script
- Add a Shop-Modifier for each player next to their Attack-Modifier. 
  > The Shop-Modifier reduces the cost of a Shop-Item. The players have to adjust their modifier based on their items. If he purchase a Shop-Item the price can be calculated and automatically subtract from their Coin-Counter.
- Replace Auto-Rewarding-Button with a Checklist of various Auto-Options a player can turn ON and OFF. (For example: Auto-Rewarding, Auto-Payment for Shop etc.)

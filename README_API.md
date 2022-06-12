<!-- omit in toc -->
# Modding API 
<!-- omit in toc -->
## (For everybody who want to add Boosterpacks or Scripts)
In this chapter are the most important variables and functions for modders listed. Those attributes are grouped by the script in which they are implemented. \
The keys of Tables are normally written in caps. If a Table refers to something player specific the keys of the Table are the player colors `Red`, `Blue`, `Green` and `Yellow`. \
All functions with parameters and a return value will return `nil` if the parameters are missing. \
We will talk about INFO-MSGs. This are Messages which will be printed for one or more player. The message will tell them what happened and what happens.

- [<b>Global</b>](#bglobalb)
- [<b>Coins</b>](#bcoinsb)
- [<b>HP (Monster)</b>](#bhp-monsterb)
- [<b>Monster Zone</b>](#bmonster-zoneb)
- [<b>Monster-Deck Zone</b>](#bmonster-deck-zoneb)
- [<b>Shop Zone</b>](#bshop-zoneb)
- [<b>Shop-Deck Zone</b>](#bshop-deck-zoneb)
- [<b>Player Zone</b>](#bplayer-zoneb)
- [<b>Pill Zone</b>](#bpill-zoneb)
- [<b>Soul Zone</b>](#bsoul-zoneb)
- [<b>Souls</b>](#bsoulsb)

## <b>Global</b>
> ### <u><b>Tables</b></u>
> Colors (often used for prints and broadcasts):
> - `REAL_PLAYER_COLOR` contains HTML color codes with all four player colors. The keys are the ingame player colors **Red**, **Blue**, **Green** and **Yellow**.
> - `REAL_PLAYER_COLOR_RGB` contains RGB percentage values for the **REAL_PLAYER_COLOR** entries. It has the same keys as **REAL_PLAYER_COLOR**.
> - `PRINT_COLOR_PLAYER` simular to **REAL_PLAYER_COLOR**, but the keys are in caps.
> - `PRINT_COLOR_SPECIAL` contains many types of HTML color codes for all types of game components. The keys are also written in caps.
>
> GUIDs of Zones:
> - `ZONE_GUID_DECK` contains the GUIDs of all deck zones in the game.
> - `ZONE_GUID_DISCARD` contains the GUIDs of all discard piles in the game.
> - `ZONE_GUID_SHOP` contains the GUIDs of the six Shop Zones. The keys are **ONE** to **SIX**.
> - `ZONE_GUID_ROOM` contains the GUIDs of the two Room Zones. The keys are **ONE** and **TWO**.
> - `ZONE_GUID_MONSTER` contains the GUIDs of the six Monster Zones. The keys are **ONE** to **SEVEN**.
> - `ZONE_GUID_PLAYER` contains the GUIDs of the Player Zones in front of each player. The keys are the ingame player colors **Red**, **Blue**, **Green** and **Yellow**
> - `ZONE_GUID_SOUL` contains the GUIDs of the Soul Zones in front of each player next to their Player Zone. The keys are the ingame player colors.
> - `ZONE_GUID_BONUSSOUL` contains the GUIDs of the Bonus Soul Zones next to the Bonus Soul Deck. The keys are **ONE** to **THREE**.
>
> GUIDs of game components:
> - `HEART_TOKENS_GUID` contains Tables of GUIDs corresponding to the Heart Tokens in front of each player. The GUIDs of the Heart Tokens are in the correct order. The keys are the player colors.
> - `FIRST_HEARTS_GUID`. The keys are the player colors.
> - `COIN_COUNTER_GUID`. The keys are the player colors.
> - `MONSTER_HP_COUNTER_GUID` contains the GUIDs of the HP Counters for the six Monster Zones. The keys are **ONE** to **SEVEN**.
> - `COUNTER_BAGS_GUID` contains the GUIDs of the ingame bags of counters. The keys are in caps.
>
> Positions:
> - `DISCARD_PILE_POSITION` contains the positions of the discard piles for each deck. The keys are in caps.
>
> Other Tables:
> - `automaticRewarding` contains the *true* or *false* if the automatic rewarding is activated for a player. The keys are the player colors.

> ### <u><b>Variables</b></u>
> - `CLICK_DELAY` is the Value, which is used to determine a Double Click on something.\
> (Current value: 0.3 sec)
> - `activePlayerColor` is the player color *string* of the player, who is the active player.
> - `startPlayerColor` is the player color *string* of the player, who will get the first turn.

> ### <u><b>Getter Functions</b></u>
> - `getDeckFromZone(zoneGUID) : object` returns the first deck or card in the zone with the GUID **zoneGUID**. If there is no deck or card, it will return *nil*.
> - `getMonsterDeck() : object` returns the first deck or card in the Monster Zone. If there is no deck or card it will return *nil*.
> > - `getHappenDeck() : object` ...
> > - `getTreasureDeck() : object` ...
> > - `getLootDeck() : object` ...
> > - `getBonusSoulDeck() : object` ...
> > - `getRoomDeck() : object` ...
> > - `getSoulTokenDeck() : object` ...
> - `getRandomPlayerColor() : string` returns a random color of a player sitting at the table.
> - `getPlayerString({playerColor}) : string` returns a the **playerColor** as a *string* tinted in the same color.
> - `getActivePlayerString() : string` returns the color of the active player as a *string* tinted in the same color.
> - `getActivePlayerZone() : zone` returns the Player Zone of the active player.
> - `getCounterInZone({zone}) : object` returns the first object in **zone** with the name "Counter".
> - `getCardFromDeck({deck}) : object` takes a card from the **deck** and return a reference on this card. If **deck** is a card it will return **deck**.
 
> ### <u><b>Technical Functions</b></u>
> - `hasGameStarted() : bool` returns *true* if the game has already been started (The Setting UP Note was deleted). Otherwise it returns *false*
> - `findIntInScript({scriptString, varName}) : int` searches in the **scriptString** for a variable with the name **varName** and returns the value of it.
> - `isPlayerAuthorized({playerColor or player, ownerPlayer}) : bool` returns *true* if the the player **player** or player with the **playerColor** equals **ownerPlayer**. It will return also *true* if **player** or the player with the **playerColor** is an admin.
> - `switchRewardingMode({playerColor or player})` switches the Rewarding Mode for **player** or the player with the **playerColor**.
> - `setNewStartPlayer({playerColor}) : bool` sets the *startPlayerColor* variable and select the appropriated turn button in the middle of the Gametable. BUT ONLY if the game hasn't been started yet. If *startPlayerColor* is already equal to **playerColor** or if anything went wrong the function returns *false*.
> - `colorPicker_attach({afterPickFunction, functionOwner, picker, reason, functionParams}) : bool` attaches **afterPickFunction** to the **Color-Picker System**. The **Color-Picker** is explained in chapter [Color-Picker](#color-picker). \
> Only **afterPickFunction** and **functionOwner** have to be set. If picker is unset, the active player will be the picker. \
> Returns *true* if **afterPickFunction** could be attached successfully.

> ### <u><b>Placing Functions</b></u>
> - `placeSoulToken({playerColor})` takes a Soul Token from the soul token deck and places it in the Soul Zone of the player with the color **playerColor**. Prints a INFO-MSG. If the soul zone is full the Soul Token will be dealed to the Hand Zone of the player.
> - `placeObjectInSoulZone({playerColor, object, index})` places **object** in the Soul Zone of the player with color **playerColor**. If the Soul Zone is full the **object** will be dealed to the Hand Zone of the player. The parameter **index** is optional. If **index** is set the **object** is placed on the **index** in the Soul Zone.
> - `placeObjectInPillZone({playerColor, object, index})` places **object** in the Pill Zone of the player with color **playerColor**. If the Pill Zone is full the **object** will be dealed to the Hand Zone of the player. The parameter **index** is optional. If **index** is set the **object** is placed on the **index** in the Pill Zone.
> - `placeObjectsInPlayerZone({playerColor, objects, index})` places **objects** in the Player Zone of the player with color **playerColor**. If the Player Zone is full the **objects** will be dealed to the Hand Zone of the player. The parameter **index** is optional. If **index** is set and **objects** contain only one object, this object will be placed on the **index** in the Player Zone.

> ### <u><b>Gameplay Functions</b></u>
> - `deactivateCharacter({playerColor})` turns all character cards in the Player Zone of the player with the color **playerColor** sideways.

## <b>Coins</b>
> ### <u><b>Variables</b></u>
> - `value` is the current amount of coins. \
> (Minimum: 0, Maximum: 999)

> ### <u><b>Technical Functions</b></u>
> - `modifyCoins({modifier})` adds or subtracts the **modifier** based on its sign to the current amount of coins.

## <b>HP (Monster)</b>
> ### <u><b>Variables</b></u>
> - `value` is the current HP of the active monster in the corresponding zone. \
> (Minimum: 0, Maximum: 9)
 
> ### <u><b>Technical Functions</b></u>
> - `updateHP({HP})` sets the *value* of this HP-Counter to **HP**. **HP** has to be positiv and lower than 10.
> - `reset()` sets the *value* of this HP-Counter to the HP-Value of the active monster in the corresponding zone, if it isn't 0. \
> (This function uses the *active_monster_attrs* from the Monster Zone)

## <b>Monster Zone</b>
> ### <u><b>Tables</b></u>
> - `active_monster_attrs` contains the attributes of the active monster in this zone. The keys are **GUID**, **NAME**, **HP**, **ATK**, **DMG**, **INDOMITABLE**.
> - `active_monster_reward` contains the amount of rewards of the active monster in this zone. The keys are **CENTS**, **LOOT**, **TREASURES** and **SOULS**.
 
> ### <u><b>Variables</b></u>
> - `active` is *true*, if this zone is an active monster zone.
 
> ### <u><b>Getter Functions</b></u>
> - `getAttackButton() : button` returns a reference of the monster button of this zone. If the monster button is deactivated if will return *nil*.
> - `getState() : string` returns the state of this zone. The state of a zone is the same as the state of its monster button. And the state of a monster button is its *label*. \
> If the monster button of this zone is deactivated it will return *nil*. \
> All states of a monster zone and its monster button are listet in the *Table* **ATTACK_BUTTON_STATES** in the Monster-Deck Zone script.
> - `getActiveMonsterCard() : object` returns a reference on the *card* with the same *GUID* as the *GUID* of the active monster of this Monster Zone. If the *card* is part of a *deck* it will be token from this *deck*. \
> If no *card* in this Monster Zone matches the *GUID* of the active monster of this zone, the function will return *nil*.
 
> ### <u><b>Technical Functions</b></u>
> - `containsDeckOrCard() : bool` returns *true* if this zone contains a *deck* or *card*.
> - `updateAttributes({HP, GUID, NAME, ATK, DMG, INDOMITABLE})` updates the Table **active_monster_attrs** to the given values. All parameters are optional except **HP**. **HP** has to be set otherwise this function does nothing. \
> The HP-Counter for this zone will also be updated. \
> If this function is called with some unset parameters, the attributes will be set their standard value. \
> (Strandard: GUID = last GUID, NAME = "", ATK = -1, DMG = -1)
> - `resetMonsterZone()` sets the state/*label* of the monster button of this zone to **ATTACK** if this zone is *active*, otherwise to **INACTIVE**. If the monster button of this zone is deactivated the button will be activated. \
> The HP-Counter of this zone will also be reseted.
> - `deactivateAttackButton()` removes/deletes the Monster Button of this zone
> - `activateAttackButton()` spawns the Monster Button of this zone in the state **ATTACK** if the zone is active and **INACTIVE** otherwise.
> - `deactivateZone()` discards all *decks* or *cards* in this zone and sets the monster attributes of this zone to zero. It deactivates the monster button of this zone and sets it to the state **INACTIVE**.
> - `activateZone({drawCard})` activates the Monster Button of this zone and sets it to the state **ATTACK**. \
> If the **drawCard** is *true* a new monster card will be placed in this zone if there is no *deck* or *card*. If **drawCard** is *false* or *nil*, no card is placed.
>    > If the new monster card is *Indomitable*, it will still be placed in this zone.
> - `changeButtonState({newState}) : bool` changes the state of the monster button of this zone to **newState** and return *true*. If the monster button of this zone is deactivated or the **newState** is no valid state, it will return *false*. 
 
> ### <u><b>Gameplay Functions</b></u>
> - `killMonster()` sets the HP-Counter of this zone to 0 and the state of this zone to **DIED** and prints an *INFO-MSG*. Only works if the monster button of this zone is activated.

## <b>Monster-Deck Zone</b>
> ### <u><b>Tables</b></u>  
> - `CHOOSE_BUTTON_STATES` contains all valid states for the monster button of this Monster-Deck Zone. The keys are **ATTACK** and **CHOOSE**.
> - `ATTACK_BUTTON_STATES` contains all valid states for the monster buttons of the Monster Zones and the Monster Zone itself. The keys are **INACTIVE**, **ATTACK**, **ATTACKING**, **CHOOSE**, **DIED** and **EVENT**.
> - `MONSTER_TAGS` contains all tags which are used to tag a monster card. The keys are **NEW**, **DEAD** and **INDOMITABLE**.
>   - The tag **NEW** will be removed from a object if it enters a monster zone.
>   - The tag **DEAD** will be removed from a object if it enters the discard pile for monster cards.
>   - The tag **INDOMITABLE** will never be removed. It is an indicator for the attribute *Indomitable* of a monster.

> ### <u><b>Techincal Functions</b></u>
> - `containsDeckOrCard({zone}) : bool` returns *true* if the monster zone **zone** contains a *deck* or a *card*.
> - `discardMonsterObject({object})` adds the tag **DEAD** to the object and places the **object** on to the discard pile for monster cards.
> - `deactivateChooseButton()` removes/deletes the Monster Button of this zone.
> - `activateChooseButton()` spawns the Monster Button if this zone in the state **ATTACK**.
> - `resetMonsterZone()` sets the state/*label* of the Monster Button of this zone to **ATTACK**. If the monster button of this zone is deactivated the button will be activated.
> - `resetAllMonsterZones()` resets the Monster-Deck Zone and all other Monster-Zones. (Have a look at the **resetMonsterZone()** functions)
> - `changeZoneState({zone, newState})` changes the state of the Monster Zone **zone** to **newState**. The **newState** has to be a state from **ATTACK_BUTTON_STATES**. What will happen on a state change depends on the **newState**. In some cases, all other monster buttons will be (de-)activated etc.

> ### <u><b>Gameplay Functions</b></u>
> - `discardActiveMonsterCard({zone})` adds the tag **DEAD** to the active monster *card* of the Monster Zone **zone** and discards it (no matter if it has a **SOULS** attribute). \
> A new monster card will be placed in the **zone** if the **zone** is now empty.
> - `placeNewMonsterCard({zone, isTargetOfAttack}) : zone` takes the topmost *card* from the monster deck, flips it and places it in the Monster Zone **zone** or the next inactive Monster Zone. \
> The function will return the zone in which the new drawn card was placed in.
>   - If the active Monster of the Monster Zone **zone** is *Indomitable* no monster is placed and the function returns *nil*.
>   - If the new drawn Monster Card has the attribute *Indomitable* it will be placed in the next inactive Monster Zone instead of **zone** and the inactive zone will be activated.\
> (If there are no more inactive zones the new card will be placed in **zone**)
>   - If the new card has a variable `isEvent` and if it is *true*, an INFO-MSG will be printed. \
>  If the new card also has an variable called `type` and if it equals the *EVENT_TYPE* **CURSE**, the Color-Picker will be used to deal the Curse Card to a players Pill Zone.
>   - If the new card is not a event and **isTargetOfAttack** is *true*, another INFO-MSG will be printed.
>   - This function will return *nil* if it couldn't find a new monster card to place it.

## <b>Shop Zone</b>
> ### <u><b>Variables</b></u>
> - `active` is *true*, if this zone is an active shop zone

> ### <u><b>Technical Functions</b></u>
> - `containsDeckOrCard() : bool` returns *true*, if this zone contains a *deck* or *card*.
> - `deactivateZone()` discards all *decks* or *cards* in this zone. It activates the shop button of this zone and sets it to the state **INACTIVE**.
> - `activateZone()` places a new treasure card in this zone if there is no *deck* or *card*. It activates the shop button of this zone and sets it to the state **PURCHASE**.
> - `deactivatePurchaseButton()` removes/deletes the shop button of this zone.
> - `activatePurchaseButton()` spawns the shop button of this zone in the state **PURCHASE** if the zone is active and **INACTIVE** otherwise.

## <b>Shop-Deck Zone</b>
> ### <u><b>Tables</b></u>
> - `PURCHASE_BUTTON_STATES` contains all valid states for the shop buttons of the shop zones. The keys are **PURCHASE** and **INACTIVE**.
> - `SHOP_BUTTON_STATES` contains all valid states for the shop button of this Shop-Deck Zone. The keys are **PURCHASE** and nothing else.

> ### <u><b>Technical Functions</b></u>
> - `deactivateShopButton()` removes/deletes the shop button of this zone.
> - `activateShopButton()` spawns the shop button of the Shop-Deck Zone in the state **PURCHASE**.
> - `changeZoneState({zone, newState})` changes the state of the Shop Zone **zone** to **newState**. The **newState** has to be a state from **PURCHASE_BUTTON_STATES**. What will happen on a state change depends on the **newState**.

> ### <u><b>Gameplay Functions</b></u>
> - `placeNewTreasureCard({zone}) : bool` takes the first *card* or the topmost *card* of the first *deck* in the treasure zone. It filps this card and put it into the shop zone **zone**. It returns *false* if no card was found in the treasure zone.

## <b>Room Zone</b>
> ### <u><b>Variables</b></u>
> - `active` is *true*, if this zone is an active room zone

> ### <u><b>Technical Functions</b></u>
> - `containsDeckOrCard() : bool` returns *true*, if this zone contains a *deck* or *card*.
> - `deactivateZone()` flips all *decks* or *cards* in this zone. It activates the room button of this zone and sets it to the state **INACTIVE**.
> - `activateZone()` flips all *decks* or *cards* in this zone and places a new room card in this zone. It activates the room button of this zone and sets it to the state **CHANGE**.
> - `deactivateRoomButton()` removes/deletes the room button of this zone.
> - `activateRoomButton()` spawns the room button of this zone in the state **CHANGE** if the zone is active and **INACTIVE** otherwise.

## <b>Room Deck Zone</b>
> ### <u><b>Tables</b></u>
> - `ROOM_BUTTON_STATES` contains all valid states for the room buttons of the room zones. The keys are **CHANGE** and **INACTIVE**.

> ### <u><b>Gameplay Functions</b></u>
> - `changeRoom(zone)` changes the room in the **zone**.
> - `placeNewRoomCard({zone}) : bool` takes the first *card* or the topmost *card* of the first *deck* in the room zone. It filps this card and put it into the room zone **zone**. It returns *false* if no card was found in the room deck zone.

## <b>Player Zone</b>
> ### <u><b>Tables</b></u>
> - `attachedObjects` contains all objects that are currently in this Player Zone. The keys are the *GUIDs* of the objects. The value for a *GUID* is 1 if the corresponding object is in this Player Zone and *nil* otherwise.
 
> ### <u><b>Variables</b></u>
> - `INDEX_MAX` is the maximum index in this Player Zone. For every Player Zone it is 14. Every index belongs to a fixed position in this zone. Index 1 to 7 belongs to the lower row and 8 to 14 belongs to the upper row.

> ### <u><b>Technical Functions</b></u>
> - `placeObjectInZone({object, index})` places **object** in this Player Zone. If this Player Zone is full the **object** will be dealed to the Hand Zone of the player. The parameter **index** is optional. If **index** is set the **object** is placed on the **index** in the Player Zone.
> - `placeMultipleObjectsInZone({objects})` places the **objects** in this Player Zone. If this Player Zone is full the **objects** will be dealed to the Hand Zone of the player. It is more efficient than calling **placeObjectInZone()** multiple times.

> ### <u><b>Gameplay Functions</b></u>
> - `deactivateCharacter()` turns every *object* in this Player Zone sideways if it has the tag **Character**.

## <b>Pill Zone</b>
> ### <u><b>Tables</b></u>
> - `attachedObjects` contains all objects that are currently in this Pill Zone. The keys are the *GUIDs* of the objects. The value for a *GUID* is 1 if the corresponding object is in this Pill Zone and *nil* otherwise.

> ### <u><b>Variables</b></u>
> - `INDEX_MAX` is the maximum index in this Pill Zone. For every Pill Zone it is 2. Every index belongs to a fixed position in this zone.

> ### <u><b>Technical Functions</b></u>
> - `placeObjectInZone({object, index})` places **object** in this Pill Zone. If this Pill Zone is full the **object** will be dealed to the Hand Zone of the player. The parameter **index** is optional. If **index** is set the **object** is placed on the **index** in the Pill Zone.

## <b>Soul Zone</b>
> ### <u><b>Tables</b></u>
> - `attachedObjects` contains all objects that are currently in this Soul Zone. The keys are the *GUIDs* of the objects. The value for a *GUID* is 1 if the corresponding object is in this Soul Zone and *nil* otherwise.

> ### <u><b>Variables</b></u>
> - `INDEX_MAX` is the maximum index in this Soul Zone. For every Soul Zone it is 4. Every index belongs to a fixed position in this zone.

> ### <u><b>Technical Functions</b></u>
> - `placeObjectInZone({object, index})` places **object** in this Soul Zone. If this Soul Zone is full the **object** will be dealed to the Hand Zone of the player. The parameter **index** is optional. If **index** is set the **object** is placed on the **index** in the Soul Zone.

## <b>Souls</b>
> ### <u><b>Variables</b></u>
> - `val` is the current amount of souls in this Soul Zone. \
> (Minimum: 0, Maximum: 4)
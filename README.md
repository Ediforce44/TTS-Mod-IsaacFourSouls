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

## TODO-List
- The Beast and Harbinger
- Fix Player Turn system (Order etc.)
- Add logic for Event-Monster-Cards

## Future work
- Automate Bonus-Souls and there counter
- The Language-Button-Problem
- Add Deck-Builder System
- Add a Shop-Modifier for each player next to their Attack-Modifier. 
  > The Shop-Modifier reduces the cost of a Shop-Item. The players have to adjust their modifier based on their items. If he purchase a Shop-Item the price can be calculated and automatically subtract from their Coin-Counter.
- Replace Auto-Rewarding-Button with a Checklist of various Auto-Options a player can turn ON and OFF. (For example: Auto-Rewarding, Auto-Payment for Shop etc.)

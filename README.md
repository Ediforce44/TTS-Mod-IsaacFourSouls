# Isaac: Four Souls Complete
This is the official repository for the Tabletop Simulator[[1]](https://store.steampowered.com/app/286160/Tabletop_Simulator/) Mod [Isaac: Four Souls Complete](https://steamcommunity.com/sharedfiles/filedetails/?id=2526757138&searchtext=issac+four+souls+full) from Edgey[[2]](https://steamcommunity.com/id/l-l34l27_4774CK) & co. This repository can be used to add new scripts or cards to the card game.

- [Isaac: Four Souls Complete](#isaac-four-souls-complete)
  - [What can I find in this Depot?](#what-can-i-find-in-this-depot)
  - [How to use this repository with Tabletop Simulator?](#how-to-use-this-repository-with-tabletop-simulator)
  - [How to use JSON-Sniffer?](#how-to-use-json-sniffer)
- [What if I want to add a Boosterpack or new Cards?](#what-if-i-want-to-add-a-boosterpack-or-new-cards)
  - [Requirements](#requirements)
  - [General](#general)
  - [Monster Cards](#monster-cards)
- [Things to do](#things-to-do)
  - [TODO-List](#todo-list)
  - [Future work](#future-work)

## What can I find in this Depot?
- The `ttslua` scripts for the Tabletop Simulator Mod. This are the main part of this repo.
- **Working Save-Files:** This folder contains ready-to-play save files. It is recommended to use the save file with the highest number in its name.
  > Copy the `.json` file and the `.png` file and past them into your `Documents/My Games/Tabletop Simulator/Saves` folder.
- This repository also contains a Python 3 script tool for quickly modifing `TTS-JSON` files.\
  Is is called `JSON-Sniffer`. We use it to automate repetitive changes to JSON-Save-Files of this mod.\
  (For Example: To extract monster states from the description of a monster card and transform them into Lua code)

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

## How to use JSON-Sniffer?
You need to install python 3 first. \
Open the command line in the folder `IFS Tools` and type in 
```
python json_sniffer.py
```
JSON-Sniffer will tell you that it needs a file name as first parameter and optionally the working modes as the next parameters.\
Just drag and drop your JSON-file into this folder or the JSON-Sniffer in the folder with the JSON-file and type in the following command into the command line.
```
python json_sniffer.py FILE_NAME WORKING_MODE_1 WORKING_MODE_2 ...
```
> **WORKING MODES:**
> - `rewards` extracts a Lua-Table called *rewards* out of the description of a monster card and adds it to the Lua-Script of the card.
> - `mark_events` adds a Lua-Variable called *isEvent* to the Lua-Script of every event mathing card. The variable has the value *true* if the card has a Lua-Variable called *type* with either the value *eventGood*, *eventBad* or *curse*. Otherwise the value of *isEvent* is *false*.
> - `tags` adds Tags to cards. 
>   - **Indomitable** if a card has `-Indomitable-` in its description.
>   - **Character** if the Nickname of this card is `character`
>   - The **--Deck Builder--** Tags are added to all monster and event cards
> - `inherit` copies all Tags from a card to the Tags of its various states. The **remove** parameter don't work with **inherit**.
> - `remove` removes all changes that the JSON-Sniffer added to a file. If you want to remove just specific modifications you can use the specific **WORKING_MODES** as parameters behind `remove`.
> > **For Example:** \
> > This removes only the *isEvent* variable and the added Tags but not the *reward* table.
> > ```
> > python json_sniffer.py FILE_NAME remove mark_events tags
> > ```

# What if I want to add a Boosterpack or new Cards?
There are some important features beside the regular API functions this mod provides. Thes chapter lists all requirements for cards to work properly with the scrpits of this mod. It also lists all features that are usefull if you want to write scpits for cards.\
The full documentation of the API of this mod is located in the file `README_API.md`.

## Requirements
>### <b>Monster Cards</b>
> - Tags
>   - Indomitable monsters should have the Tag `Indomitable`
> - Script Variables
>   - All monster should contain at least a non-local variable called `hp` which stores the HP of the monster.
>   - Monster should also contain:
>       - Variables called `atk` and `dice`. These contain the damage the monster deals and the dice roll to hit value.
>       - A variable called `soul` if the monster is at least one soul worth. The value of this variable is the soul value of this monster.
>       - A *Lua-Table* called `rewards` which has the Keys `CENTS`, `LOOT`, `TREASURES` and `SOULS`. The table should contain the amount of each which you get by defeating the monster. 
> > <b>OPTIONAL</b>
> > - A non-Event monster card can contain a Script Variable called `isEvent` with the value `false`

>### <b>Event Cards</b>
> - Script Variables
>   - All events should contain at least a non-local variable called `isEvent` with the value `true`.
>   - Events should also contain:
>     - A variable called `type` which has either the value `"eventGood"`, `"eventBad"` or `"curse"`.

>### <b>Soul Cards</b>
> Cards that are worth at least one soul are called **Soul Cards**.
> - Script Variables
>   - Soul Cards should contain at least a non-local variable called `soul` with the soul value of this card as the value.

>### <b>Character Cards</b>
> - Tags
>   - All character cards should have at least the Tag `Character`.

## General
- **The Color-Picker** is a feature which allows a player to pick a specific player color or to pick a player color at random. \
  The Color-Picker is part of the *Global* script. You can attach a specific function to the Color-Picker. Then the Color-Picker will open a UI-Context in which a player could pick a color. After the player picked a color, the attached function will be called with the selected color as a parameter. There is no limit to attached functions. The Color Picker will handle the attachments one by one. 
  > **NOTE:**\
  > If you use the Color-Picker for cards or other objects which could easily be consumed by decks or other objects, it is important that the attached functions is not part of the script of the consumed object. In this case the attached function isn't callable. \
  Therefore it is recommended to write the attached functions into the script of the Boosterpack/Extension **Container**. If you want to use the Color-Picker in regular Isaac cards just write the attached function into the script of the Isaac original **Container**.

  The core of the Color-Picker is the function **colorPicker_attach()**:
  > ```
  > colorPicker_attach({afterPickFunction, functionOwner, picker, reason, functionParams})
  > ```
  > - `afterPickFunction : string` has to be set and is the name of the attached function.
  > - `functionOwner : object` has to be set and is the *object* which contains the script with the **afterPickFunction**.
  > - `picker : string` is the player color of the player who has to pick the color. \
  > If it is *nil*, the active player will be choosen as picker.
  > - `reason : string` will be used for the INFO-MSG. It indicates the reason why the player has to choose a color. \
  > If it is *nil*, the reason has the value "Unknown".
  > - `functionParams : Table` will be passed together with the picked color as parameters to the **afterPickFunction**.

## Monster Cards
Monster cards are well supported. Many things can be scripted for them. There are Event-like functions which can be added to a Monster Card script. These functions are called **Monster-Events**. \
Just add a function with the following name to the script of a Monster Card and it will be executed in the specific situation:
- **onReveal({zone}) : bool** will be executed whenever this Monster Card will become a *active* Monster.
  - Parameter:
    - `zone` is a reference to the Monster Zone in which the monster became the active monster.
  - Return:
    - If your **onReveal()** function return *false* the Event-Reveal step will be skipped. This means if the Monster Card script contains a variable called **isEvent** with the value *true*, this card will be treated as **isEvent** has the value *false*.
    > <b>NOTE:</b> \
    > Normally you want to return *true*.

- **onDie({zone}) : bool** will be executed if the Monster Button is pressed in the state **DIED**.
    > <b>NOTE:</b> \
    > This means the **onDie()** Monster Event isn't normally 
    called if you finish an Event Card in a Monster Zone.

    > <b>NOTE:</b> \
    > The **onDie()** Monster Event appears directly after setting the position of the killed monster to the position of the discard pile or the Soul Zone of a player. \
    So you can simply set another position for the Monster Card in the **onDie()** function.
  - Parameter:
    - `zone` is a reference to the Monster Zone in which the monster lay while it was killed.
  - Return:
    - If the **onDie()** function return *false*, the Monster Card won't be tagged as **DEAD** and no new Monster will be placed in this zone if it is now empty.
    > <b>NOTE:</b> \
    > Normally you want to return *true*. The Return-False-Option is provided if you want let the **onReveal()** Monster Event appear again etc.

> **NOTE:** \
> If you want some examples for the **Monster-Events** look at the script of the Monster Card "The Harbingers".

# Things to do
## TODO-List
- Fix Player Turn system (Floors, Order etc.)
- Add Deck-Builder System

## Future work
- Design a thematic layout for the color picker
- Change the attached object system for Index-Zones like the Soul Zone, Player Zone or Pill Zone to a more usefull system:
    > - Attached objects refers to the Index in the zone in which they are played
    > - Add `getPositionFromIndex({index}))`
    > - Add `getObjectsFromIndex({index})`
- Automate Bonus-Souls and there counter
- The Language-Button-Problem
- Fix Player Turn system in the Floor Change script
- Add a Shop-Modifier for each player next to their Attack-Modifier. 
  > The Shop-Modifier reduces the cost of a Shop-Item. The players have to adjust their modifier based on their items. If he purchase a Shop-Item the price can be calculated and automatically subtract from their Coin-Counter.
- Replace Auto-Rewarding-Button with a Checklist of various Auto-Options a player can turn ON and OFF. (For example: Auto-Rewarding, Auto-Payment for Shop etc.)

-- The Baseplate of the table
----- Manages the decks and cards under the table

local function createDebugButton()
    self.createButton({
      click_function = "prepareDebug",
      function_owner = self,
      label          = "",
      position       = {5, 0.2, 0},
      rotation       = {180, 270, 180},
      width          = 300,
      height         = 300 * 17,
      color          = {1, 1, 1}
    })
end

LANGUAGE_OBJECT_POSITIONS = {
    LOOT = {
        L_BATTERY = {x = -20.95, y = -3.46,z = 5},
        L_BOMB = {x = -31.86, y = -3.45, z = 5},
        L_BUTTER_BEAN = {x = -24.57, y = -3.47, z = 0},
        L_DICE_SHARD = {x = -42.75, y = -3.47, z = 0},
        L_FOUR_CENT = {x = -42.75, y = -3.42, z = 5},
        L_LOST_SOUL = {x = -39.11, y = -3.5, z = 0},
        L_NICKEL = {x = -28.21, y = -3.46, z = 5},
        L_ONE_CENT = {x = -31.86, y = -3.44, z = 0},
        L_PILL = {x = -35.50, y = -3.46, z = 0},
        L_RUNE = {x = -39.11, y = -3.45, z = 5},
        L_SOUL_HEART = {x = -35.50, y = -3.47, z = 5},
        L_TAROT_MISC = {x = -17.27, y = -3.31, z = 5},
        L_THREE_CENT = {x = -20.95, y = -3.36, z = 0},
        L_TRINKET = {x = -24.57, y = -3.38, z = 5},
        L_TWO_CENT = {x = -28.21, y = -3.4, z = 0}
    },
    MONSTER = {
        M_BAD = {x = 0.87, y = -3.43, z = 5},
        M_BASIC = {x = -9.88, y = -3.17, z = 5},
        M_BOSS = {x = -6.26, y = -3.21, z = 5},
        M_CURSE = {x = -2.7, y = -3.44, z = 0},
        M_CURSED = {x = -6.26, y = -3.44, z = 0},
        M_EPIC = {x = -2.7, y = -3.44, z = 5},
        M_GOOD = {x = 0.86, y = -3.4,z = 0},
        M_HOLY_CHARMED = {x = -9.88, y = -3.41, z = 0}
    },
    TREASURE = {
        T_ACTIVE = {x = 8.13, y = -3.14, z = 5},
        T_ONE_USE = {x = 19., y = -3.44, z = 5},
        T_PAID = {x = 15.39, y = -3.41, z = 5},
        T_PASSIVE = {x = 11.75, y = -2.92, z = 5},
        T_SOUL = {x = 22.64, y = -3.48, z = 5}
    },
    ROOM = {
        R_ALL = {x = 29.5, y = -3.21, z = 5}
    },
    BONUS_SOUL = {
        BS_ALL = {x = 36, y = -3.46, z = 5}
    },
    MONSTER_SEP = {
        MS_ALL = {x = 42, y = -3.5, z = 5}
    }
}

OBJECTS_UNDER_TABLE = {
    US = "356efe",
    RU = "ac9ceb",
    ES = "5a30af",
    FR = "6f6751",
    EL_BAG = "3316b6",
    CP_BAG = "143ff6",
    EMC_BAG = "6c3662",
    DUMMY_TREASURE = "c93b7d",
    DUMMY_LOOT = "35efd9",
    DUMMY_MONSTER = "617e0e",
    DUMMY_BONUS_SOUL = "c16c3c",
    R_EDEN = "1adaea",
    R_EDEN_2 = "44f74a",
    AA_EDEN = "25f5c0",
    AA_EDEN_2 = "1d42c4",
    RET_EDEN = "cebc17",
    P_EDEN = "34fe47",
    P_EDEN_2 = "a31f35",
    P_EDEN_3 = "9a744b"
}

LANGUAGE_OBJECTS = {
    US = {
        TREASURE = {
            T_ACTIVE  = "554bc6",
            T_PASSIVE = "c856de",
            T_PAID    = "88bfef",
            T_ONE_USE = "9978de",
            T_SOUL    = "8c1c9e"
        },
        LOOT = {
            L_TAROT_MISC    = "1e2ba2",
            L_TRINKET       = "905e6c",
            L_PILL          = "cd1278",
            L_RUNE          = "3bc855",
            L_BUTTER_BEAN   = "b3a842",
            L_BOMB          = "7f356d",
            L_BATTERY       = "a2ce3b",
            L_DICE_SHARD    = "a10518",
            L_SOUL_HEART    = "e36afb",
            L_LOST_SOUL     = "82651f",
            L_NICKEL        = "be9b22",
            L_FOUR_CENT     = "7066cd",
            L_THREE_CENT    = "3f64ec",
            L_TWO_CENT      = "a7dd09",
            L_ONE_CENT      = "13c535"
        },
        MONSTER = {
            M_EPIC        = "b8031a",
            M_BOSS        = "faa9c2",
            M_BASIC       = "bce971",
            M_CURSED      = "5e7c02",
            M_HOLY_CHARMED= "abc623",
            M_GOOD        = "f92197",
            M_BAD         = "d2fd58",
            M_CURSE       = "aecf91"
        },
        ROOM = {
            R_ALL   = "7c6d90"
        },
        BONUS_SOUL = {
            BS_ALL  = "6b5923"
        },
        MONSTER_SEP = {
            MS_ALL = "2f818b"
        }
    },
    RU = {
        TREASURE = {
            T_ACTIVE  = "c2b313",
            T_PASSIVE = "bee8da",
            T_PAID    = "ea08ae",
            T_ONE_USE = "5aa37f",
            T_SOUL    = "0c7644"
        },
        LOOT = {
            L_TAROT_MISC    = "c98157",
            L_TRINKET       = "1f497c",
            L_PILL          = "2ea6fe",
            L_RUNE          = "127198",
            L_BUTTER_BEAN   = "9dafb1",
            L_BOMB          = "ffe4df",
            L_BATTERY       = "b621b8",
            L_DICE_SHARD    = "939d60",
            L_SOUL_HEART    = "7393d0",
            L_LOST_SOUL     = "7f0cb1",
            L_NICKEL        = "5a8229",
            L_FOUR_CENT     = "43a2db",
            L_THREE_CENT    = "5de503",
            L_TWO_CENT      = "41164a",
            L_ONE_CENT      = "571f03"
        },
        MONSTER = {
            M_EPIC        = "6ebe2d",
            M_BOSS        = "cbdd46",
            M_BASIC       = "bc5d83",
            M_CURSED      = "fec70e",
            M_HOLY_CHARMED= "48ee37",
            M_GOOD        = "60b972",
            M_BAD         = "135197",
            M_CURSE       = "e74578"
        },
        ROOM = {
            R_ALL   = "e2f488"
        },
        BONUS_SOUL = {
            BS_ALL  = "77a365"
        },
        MONSTER_SEP = {
            MS_ALL = "2a3272"
        }
    },
    ES = {
        TREASURE = {
            T_ACTIVE  = "3a39c0",
            T_PASSIVE = "c245e4",
            T_PAID    = "b4f6d2",
            T_ONE_USE = "054560",
            T_SOUL    = "c97e30"
        },
        LOOT = {
            L_TAROT_MISC    = "090e03",
            L_TRINKET       = "e1f3c5",
            L_PILL          = "2f9e5b",
            L_RUNE          = "1de45f",
            L_BUTTER_BEAN   = "7901e8",
            L_BOMB          = "3dfc41",
            L_BATTERY       = "f4edad",
            L_DICE_SHARD    = "b6004b",
            L_SOUL_HEART    = "ec73cb",
            L_LOST_SOUL     = "bb3cf3",
            L_NICKEL        = "77d2b2",
            L_FOUR_CENT     = "c7a49f",
            L_THREE_CENT    = "0686ae",
            L_TWO_CENT      = "e88b23",
            L_ONE_CENT      = "ec2c81"
        },
        MONSTER = {
            M_EPIC        = "969a9c",
            M_BOSS        = "88586b",
            M_BASIC       = "79615e",
            M_CURSED      = "33433f",
            M_HOLY_CHARMED= "8ae1a7",
            M_GOOD        = "1dd9cc",
            M_BAD         = "8bcdb7",
            M_CURSE       = "cdcb48"
        },
        ROOM = {
            R_ALL   = "4a7cd0"
        },
        BONUS_SOUL = {
            BS_ALL  = "8fcabc"
        },
        MONSTER_SEP = {
            MS_ALL = "11585a"
        }
    },
    FR = {
        TREASURE = {
            T_ACTIVE  = "8d0702",
            T_PASSIVE = "7c052e",
            T_PAID    = "c7a948",
            T_ONE_USE = "1b6735",
            T_SOUL    = "dbd4a3"
        },
        LOOT = {
            L_TAROT_MISC    = "43b38a",
            L_TRINKET       = "adb699",
            L_PILL          = "24e356",
            L_RUNE          = "9e9432",
            L_BUTTER_BEAN   = "05ea00",
            L_BOMB          = "e36dc0",
            L_BATTERY       = "e9a1a0",
            L_DICE_SHARD    = "98846f",
            L_SOUL_HEART    = "03f5a2",
            L_LOST_SOUL     = "6a356b",
            L_NICKEL        = "1af1ca",
            L_FOUR_CENT     = "ab4337",
            L_THREE_CENT    = "84ec0f",
            L_TWO_CENT      = "f62474",
            L_ONE_CENT      = "e5965e"
        },
        MONSTER = {
            M_EPIC        = "38eadd",
            M_BOSS        = "c204a4",
            M_BASIC       = "b8fb25",
            M_CURSED      = "5d6c2f",
            M_HOLY_CHARMED= "a507d2",
            M_GOOD        = "f4746c",
            M_BAD         = "851433",
            M_CURSE       = "604dbb"
        },
        ROOM = {
            R_ALL   = "bb9dbd"
        },
        BONUS_SOUL = {
            BS_ALL  = "7f0b55"
        },
        MONSTER_SEP = {
            MS_ALL = "67fbb7"
        }
    }
}

local function isBaseRaised()
    return self.getPosition().y > 0
end

function prepareDebug()
    local basePosition = self.getPosition()
    local newPosition = nil
    if isBaseRaised() then
        self.interactable = false
        for _, guid in pairs(OBJECTS_UNDER_TABLE) do
            local obj = getObjectFromGUID(guid)
            if obj then
                obj.interactable = false
                local newObjPosition = obj.getPosition():setAt('y', obj.getPosition().y - 15)
                obj.setPosition(newObjPosition)
            end
        end
        newPosition = basePosition:setAt('y', basePosition.y - 15)
        self.setPosition(newPosition)
    else
        self.interactable = false
        for _, guid in pairs(OBJECTS_UNDER_TABLE) do
            local obj = getObjectFromGUID(guid)
            if obj then
                obj.interactable = true
                local newObjPosition = obj.getPosition():setAt('y', self.getPosition().y + 16)
                obj.setPosition(newObjPosition)
            end
        end
        newPosition = basePosition:setAt('y', basePosition.y + 15)
        self.setPosition(newPosition)
    end
    return newPosition
end

function getDummyDeckGuids()
    local dummyGuids = {}
    dummyGuids["TREASURE"] = OBJECTS_UNDER_TABLE.DUMMY_TREASURE
    dummyGuids["LOOT"] = OBJECTS_UNDER_TABLE.DUMMY_LOOT
    dummyGuids["MONSTER"] = OBJECTS_UNDER_TABLE.DUMMY_MONSTER
    dummyGuids["BONUS_SOUL"] = OBJECTS_UNDER_TABLE.DUMMY_BONUS_SOUL
    return dummyGuids
end

function getDummyDeck(params)
    if params.deckID == nil then
        Global.call("printWarning", {text = "Wrong parameter in Table Base function getDummyDeck()."})
        return nil
    end
    local guid = OBJECTS_UNDER_TABLE["DUMMY_" .. tostring(params.deckID)]
    if guid == nil then
        return nil
    end
    return getObjectFromGUID(guid)
end

function onLoad()
    if not Global.call("hasGameStarted") then
        for language, objTable in pairs(LANGUAGE_OBJECTS) do
            for _, objGUIDs in pairs(objTable) do
                for objName, guid in pairs(objGUIDs) do
                    OBJECTS_UNDER_TABLE[language .. "_" .. objName] = guid
                end
            end
        end
        createDebugButton()
    end
    self.interactable = false

    for _, guid in pairs(OBJECTS_UNDER_TABLE) do
        local obj = getObjectFromGUID(guid)
        if obj then
            obj.interactable = false
            obj.setLock(false)
        end
    end
end

function returnLanguageObjects()
    for language, objTable in pairs(LANGUAGE_OBJECTS) do
        local languageBag = getObjectFromGUID(OBJECTS_UNDER_TABLE[language])
        for _, objGUIDs in pairs(objTable) do
            for _, guid in pairs(objGUIDs) do
                local object = getObjectFromGUID(guid)
                if object then
                    languageBag.putObject(object)
                end
            end
        end
    end
end

function extractLanguageObjects(params)
    if params.language == nil then
        Global.call("printWarning", {text = "Wrong parameter in Table Base function extractLanguageObjects()."})
        return
    end

    local language = params.language
    local languageBag = getObjectFromGUID(OBJECTS_UNDER_TABLE[language])
    if languageBag.getQuantity() == 0 then
        return
    end
    for category, objGUIDs in pairs(LANGUAGE_OBJECTS[language]) do
        for type, guid in pairs(objGUIDs) do
            languageBag.takeObject({
                position    = Vector(LANGUAGE_OBJECT_POSITIONS[category][type]):setAt('y', self.getPosition().y + 0.5),
                smooth      = false,
                rotation    = {0, 180, 180},
                guid        = guid,
                callback_function = function(object) object.interactable = isBaseRaised() end
            })
        end
    end
end

function shufflePreDecks(params)
    local preDecks = nil

    if params.language == nil then
        if params.preDecks == nil then
            Global.call("printWarning", {text = "Wrong parameters in Table Base function 'shufflePreDecks()'."})
            return
        else
            preDecks = params.preDecks
        end
    else
        preDecks = LANGUAGE_OBJECTS[params.language]
    end

    for _, preDeck in pairs(preDecks) do
        for _, guid in pairs(preDeck) do
            local obj = getObjectFromGUID(guid)
            if obj.tag == "Deck" then
                obj.shuffle()
            end
        end
    end
end

function getPreDeckGUIDs(params)
    local language = Global.getVar("gameLanguage")
    if params then
        language = params.language
    end
    if (language == nil) or (language == "None") then
        language = Global.getTable("GAME_LANGUAGE").US
    end
    return LANGUAGE_OBJECTS[language]
end

function setPreDeckGUIDs(deckType, newPreDeckTable)
    local language = Global.getVar("gameLanguage")
    if params then
        language = params.language
    end
    if (language == nil) or (language == "None") then
        language = Global.getTable("GAME_LANGUAGE").US
    end
    LANGUAGE_OBJECTS[language][deckType] = newPreDeckTable
end

--Ignores filter options
function getRandomTreasure(params)
    local amount = 1
    if params then
        if params.amount ~= nil then
            amount = params.amount
        end
    end

    local treasureCardsAmount = 0
    local treasurePreDecks = getPreDeckGUIDs().TREASURE
    for _, guid in pairs(treasurePreDecks) do
        local treasureDeck = getObjectFromGUID(guid)
        if treasureDeck then
            if treasureDeck.type == "Card" then
                treasureCardsAmount = treasureCardsAmount + 1
            else
                treasureCardsAmount = treasureCardsAmount + treasureDeck.getQuantity()
            end
        end
    end

    local selectedCardsInfoTable = {}
    for i = 1, amount do
        table.insert(selectedCardsInfoTable, i, {})
        local randomIndex = nil
        local isIndexNew = false
        while(not isIndexNew) do
            randomIndex = math.random(treasureCardsAmount)
            isIndexNew = true
            for _, cardInfo in pairs(selectedCardsInfoTable) do
                if randomIndex == cardInfo.random then
                    isIndexNew = false
                end
            end
        end
        local randomIndexDeck = randomIndex
        for id, guid in pairs(treasurePreDecks) do
            local deck = getObjectFromGUID(guid)
            if deck.type == "Card" then
                if randomIndexDeck == 1 then
                    selectedCardsInfoTable[i]["guid"] = deck.getGUID()
                    selectedCardsInfoTable[i]["deckID"] = id
                    selectedCardsInfoTable[i]["random"] = randomIndex
                    break
                else
                    randomIndexDeck = randomIndexDeck - 1
                end
            else
                if randomIndexDeck > deck.getQuantity() then
                    randomIndexDeck = randomIndexDeck - deck.getQuantity()
                else
                    selectedCardsInfoTable[i]["guid"] = deck.getObjects()[randomIndexDeck].guid
                    selectedCardsInfoTable[i]["deckID"] = id
                    selectedCardsInfoTable[i]["random"] = randomIndex
                    break
                end
            end
        end
    end

    local selectedCards = {}
    for i, cardInfo in pairs(selectedCardsInfoTable) do
        local deck = getObjectFromGUID(treasurePreDecks[cardInfo.deckID])
        if deck.type == "Card" then
            table.insert(selectedCards, deck)
        else
            local newDeck = nil
            if deck.getQuantity() == 2 then
                newDeck = deck.remainder
            end
            local card = deck.takeObject({guid = cardInfo.guid})
            if card == nil then
                card = deck.takeObject()
            end
            if card ~= nil then
                if newDeck then
                    treasurePreDecks[cardInfo.deckID] = newDeck.getGUID()
                    setPreDeckGUIDs("TREASURE", treasurePreDecks)
                end
                table.insert(selectedCards, card)
            end
        end
    end

    return selectedCards
end
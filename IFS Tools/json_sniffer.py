import sys
import json
import re

def matchesBag(object):
    name = object["Name"]
    return ((name == "Custom_Model_Bag") or (name == "Bag") or (name == "Infinite_Bag") or (name == "Custom_Model_Infinite_Bag"))

def getRewardPattern(rewardType):
    return re.compile("((((\n|[+])([0-9]{1,2})\s)|([0-9]{1,2}))(" + rewardType + "s?))|((" + rewardType + "s?)\s?([0-9]{1,2}))", re.I)

def getReward(rewardType, rewardsString):
    amount = 0
    m = getRewardPattern(rewardType).search(rewardsString)
    if m != None:
        amount = int(re.search("[0-9]{1,2}", m.group(0)).group(0))
    return amount

def rewardsVarExist(JSON_string):
    pattern = re.compile("rewards\s?=\s?")
    return pattern.search(JSON_string) != None

def translateRewards(rewardsString):
    rewardsLua = "rewards = "
    JSON_string = rewardsString
    cents = loot = treasures = souls = 0
    pattern = re.compile("(?=reward(s?):)(.*\n?)*", re.I)
    m = pattern.search(JSON_string)
    if m != None:
        JSON_string = m.group(0)
        m = re.search("(?<=:\s)(.*\n?)*", JSON_string)
        if m == None:
            m = re.search("(?<=:)(.*\n?)*", JSON_string)
        if m != None:
            JSON_string = m.group(0)
        else:
            return ""
    else:
        return ""
    #print(JSON_string)
    loot = getReward("loot", JSON_string)
    cents = getReward("¢", JSON_string)
    if cents == 0:
        cents = getReward("cent", JSON_string)
        if cents == 0:
            cents = getReward("\\uffe0", JSON_string)
    treasures = getReward("treasure", JSON_string)
    souls = getReward("soul", JSON_string)
    
    rewardsLua = rewardsLua + "{CENTS = " + str(cents) + ", LOOT = " + str(loot) + ", TREASURES = " + str(treasures) \
        + ", SOULS = " + str(souls) + "}"
    return rewardsLua

def hasEventType(JSON_string):
    pattern = re.compile("(?=(event)?[_]?type\s?=\s?)(.*\n?)", re.I)
    eventTypePattern = re.compile("[(curse)|(goodEvent)|(badEvent)|(eventGood)|(eventBad)]", re.I)
    m = pattern.search(JSON_string)
    if m != None:
        eventTypeString = m.group(0)
        m = eventTypePattern.search(eventTypeString)
        if m != None:
            return True
    return False

def eventVarExist(JSON_string):
    pattern = re.compile("isEvent\s?=\s?")
    return pattern.search(JSON_string) != None

def getEventVar(isEvent):
    eventVarString = "isEvent = "
    if isEvent:
        eventVarString = eventVarString + "true"
    else:
        eventVarString = eventVarString + "false"
    return eventVarString

def addEventVar(eventValue, JSON_data):
    JSON_data["LuaScript"] = JSON_data["LuaScript"] + "\n" + getEventVar(eventValue)

def removeEventVar(JSON_data):
    JSON_data["LuaScript"] = re.sub("\n(" + getEventVar(True) + ")|(" + getEventVar(False) + ")", "", JSON_data["LuaScript"])

def isIndomitable(description):
    pattern = re.compile("(.)*[-]\s?Indomitable\s?[-]?(.)*", re.I | re.DOTALL)
    return pattern.match(description)

# WARNING: No Prefix resistance. 
#   - Returns also True if JSON_data has a Tag which containes tag as a prefix
def tagExist(refTag, JSON_data):
    try:
        tags = JSON_data["Tags"]
    except:
        return False
    else:
        pattern = re.compile(refTag, re.I)
        for tag in tags:
            if pattern.match(tag):
                return True
                

def addTag(tagToAdd, JSON_data):
    try:
        tags = JSON_data["Tags"]
    except:
        JSON_data["Tags"] = [tagToAdd]
    else:
        tags.insert(0, tagToAdd)

def removeTag(tagToRemove, JSON_data):
    try:
        tags = JSON_data["Tags"]
    except:
        return
    else:
        tags.remove(tagToRemove)
        if not tags:
            del JSON_data["Tags"]

def matchesMonsterPattern(nickname):
    pattern = re.compile("(.*)monster(.*)", re.I)
    return pattern.match(nickname)


# ---------------------------------------------------------------------------------------------------------------------
#                                                   Maincode
# ---------------------------------------------------------------------------------------------------------------------

def handleRewards(card):
    if remove:
        rewardString = translateRewards(card["Description"])
        if not rewardString == "":
            card["LuaScript"] = re.sub("\n" + rewardString, "", card["LuaScript"])
    elif not rewardsVarExist(card["LuaScript"]):
        rewardString = translateRewards(card["Description"])
        if not rewardString == "":
            card["LuaScript"] = card["LuaScript"] + "\n" + rewardString
    if "States" in card:
            for stateClass in card["States"]:
                altState = card["States"][stateClass]
                handleRewards(altState)

def handleEventVar(card):
    if remove:
        removeEventVar(card)
    elif not eventVarExist(card["LuaScript"]):
        if hasEventType(card["LuaScript"]):
            addEventVar(True, card)
        else:
            addEventVar(False, card)
    if "States" in card:
        for stateClass in card["States"]:
            altState = card["States"][stateClass]
            handleEventVar(altState)

def handleIndomitableTag(card):
    if isIndomitable(card["Description"]):
        if remove:
            removeTag("Indomitable", card)
        elif not tagExist("Indomitable", card):
            addTag("Indomitable", card)
    if "States" in card:
            for stateClass in card["States"]:
                altState = card["States"][stateClass]
                handleIndomitableTag(altState)

def handleCharacterTag(card):
    if card["Description"] == "character":
        if remove:
            removeTag("Character", card)
        elif not tagExist("Character", card):
            addTag("Character", card)
    if "States" in card:
            for stateClass in card["States"]:
                altState = card["States"][stateClass]
                handleCharacterTag(altState)

def handleBag(bag):
    for content in bag["ContainedObjects"]:
        contentType = content["Name"]
        if contentType == "Card":
            if tags:
                handleIndomitableTag(content)
                handleCharacterTag(content)
            if mark_events:
                handleEventVar(content)
        elif contentType == "Deck":
            if rewards:
                if (content["Nickname"] == "") or matchesMonsterPattern(content["Nickname"]):
                    for card in content["ContainedObjects"]:
                        handleRewards(card)
            for card in content["ContainedObjects"]:
                if tags:
                    handleIndomitableTag(card)
                    handleCharacterTag(card)
                if mark_events:
                    handleEventVar(card)
        elif matchesBag(content):
            handleBag(content)

def main(argv, argc):
    if argc < 2:
        print("To little parameters:\n\t1: File name of the file you want to sniff.\n\tRest: The mode. (rewards, tags, mark_events, remove)")
        return
    fileName = str(argv[1])
    m = re.search("\.json", fileName)
    if m != None:
        fileName = fileName[:m.start()]
    try:
        JSON_file = open(fileName + ".json", "r", encoding = "utf8")
    except:
        print("The File with the name '" + fileName + "' doesn't exist.\n")
        return

    global rewards
    rewards = False
    global tags
    tags = False
    global mark_events
    mark_events = False

    global remove
    remove = False

    if argc > 2:
        removeAll = None
        for i in range(2,argc):
            mode = argv[i]
            if mode == "rewards":
                rewards = True
                if removeAll:
                    removeAll = False
            elif mode == "tags":
                tags = True
                if removeAll:
                    removeAll = False
            elif mode == "mark_events":
                mark_events = True
                if removeAll:
                    removeAll = False
            elif mode == "remove":
                remove = True
                removeAll = True
            else:
                print("WARNING: Can't find the working mode '" + mode + "'.")
        if removeAll == True:
            rewards = True
            tags = True
            mark_events = True
    else:
        rewards = True
        tags = True
        mark_events = True

    JSON_data = json.load(JSON_file)

    # Original    
    for val in JSON_data["ObjectStates"]:
        if rewards:
            if val["Name"] == "Deck" and val["Nickname"] == "Monsters cards":
                for card in val["ContainedObjects"]:
                    handleRewards(card)
        
        if tags:
            if val["Name"] == "Deck" and val["Nickname"] == "Monsters cards":
                for card in val["ContainedObjects"]:
                    handleIndomitableTag(card)
            if val["Name"] == "Custom_Model_Bag" and val["Description"] == "character-pack":
                for card in val["ContainedObjects"]:
                    handleCharacterTag(card)

        if mark_events:
            if val["Name"] == "Deck" and val["Nickname"] == "Happening cards":
                for card in val["ContainedObjects"]:
                    handleEventVar(card)

            elif val["Name"] == "Deck" and val["Nickname"] == "Monsters crads":
                for card in val["ContainedObjects"]:
                    handleEventVar(card)
    
    # Expansions
    for val in JSON_data["ObjectStates"]:
        # Expansion Bag
        if val["Name"] == "Custom_Model_Infinite_Bag" or val["Name"] == "Infinite_Bag":
            handleBag(val)
                                    
    newFileName = fileName
    if remove:
        newFileName += "_Unsniffed.json"
    else:
        newFileName += "_Sniffed.json"
    newFile = open(newFileName, "w+")
    newFile.write(json.dumps(JSON_data, indent=2))
    newFile.close()
    JSON_file.close()

if __name__ == "__main__":
    main(sys.argv, len(sys.argv))
    
    
import sys
import json
import re

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
    JSON_data["LuaScript"] = re.sub("\n[(" + getEventVar(True) + ")|(" + getEventVar(False) + ")]", "", JSON_data["LuaScript"])

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
    
    rewards = False
    tags = False
    mark_events = False

    remove = False

    if argc > 2:
        removeAll = None
        for i in range(2,argc-1):
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
        #print(val["Name"])
        if rewards:
            if val["Name"] == "Deck" and val["Nickname"] == "Monsters cards":
                for card in val["ContainedObjects"]:
                    #print(card["GUID"])
                    if not rewardsVarExist(card["LuaScript"]):
                        card["LuaScript"] = card["LuaScript"] + "\n" + translateRewards(card["Description"])
                    elif remove:
                        card["LuaScript"] = re.sub("\n" + translateRewards(card["Description"]), "", card["LuaScript"])
        
        if tags:
            if val["Name"] == "Deck" and val["Nickname"] == "Monsters cards":
                for card in val["ContainedObjects"]:
                    if isIndomitable(card["Description"]):
                        if not tagExist("Indomitable", card):
                            addTag("Indomitable", card)
                        elif remove:
                            removeTag("Indomitable", card)

        if mark_events:
            if val["Name"] == "Deck" and val["Nickname"] == "Happening cards":
                for card in val["ContainedObjects"]:
                    if not eventVarExist(card["LuaScript"]):
                        addEventVar(True, card)
                    elif remove:
                        removeEventVar(card)

            elif val["Name"] == "Deck" and val["Nickname"] == "Monsters crads":
                for card in val["ContainedObjects"]:
                    if not eventVarExist(card["LuaScript"]):
                        addEventVar(False, card)
                    elif remove:
                        removeEventVar(card)
    
    # Expansions
    for val in JSON_data["ObjectStates"]:
        # Expansion Bag
        if val["Name"] == "Custom_Model_Infinite_Bag":
            for expansion in val["ContainedObjects"]:
                if expansion["Name"] == "Custom_Model_Bag" or expansion["Name"] == "Bag":
                    for content in expansion["ContainedObjects"]:
                        # Only Decks with no Nickname or 'monster' in their Nickname
                        if rewards or mark_events or tags:
                            if (content["Nickname"] == "" or matchesMonsterPattern(content["Nickname"])):
                                if content["Name"] == "Deck":
                                    for card in content["ContainedObjects"]:
                                        if rewards and (not rewardsVarExist(card["LuaScript"])):
                                            card["LuaScript"] = card["LuaScript"] + "\n" + translateRewards(card["Description"])
                                        # This marks more cards as it should, because too many decks have no Nickname
                                        if mark_events:
                                            if not eventVarExist(card["LuaScript"]):
                                                addEventVar(False, card)
                                            elif remove:
                                                removeEventVar(card)
                                        if tags:
                                            if isIndomitable(card["Description"]) and (not tagExist("Indomitable", card)):
                                                addTag("Indomitable", card)
                                            elif remove:
                                                removeTag("Indomitable", card)

                        if mark_events:
                            if content["Name"] == "Deck":
                                for card in content["ContainedObjects"]:
                                    if hasEventType(card["LuaScript"]):
                                        if not eventVarExist(card["LuaScript"]):
                                            addEventVar(True, card)
                                        elif remove:
                                            removeEventVar(card)
                                    
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
    
    
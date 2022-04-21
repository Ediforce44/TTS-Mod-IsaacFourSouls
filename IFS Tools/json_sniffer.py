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
    pattern = re.compile("(=?(event)?[_]?type\s?=\s?)(.*\n?)", re.I)
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

def addEventVar(isEvent):
    eventVarString = "isEvent = "
    if isEvent:
        eventVarString = eventVarString + "true"
    else:
        eventVarString = eventVarString + "false"
    return eventVarString

def matchesMonsterPattern(nickname):
    pattern = re.compile("(.*)monster(.*)", re.I)
    return pattern.match(nickname)

def main(argv, argc):
    if argc < 2:
        print("To little parameters:\n\rPlease pass the file name of the file you want to sniff as parameter.\n")
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
    mark_events = False

    if argc > 2:
        mode = argv[2]
        if mode == "rewards":
            rewards = True
        elif mode == "mark_events":
            mark_events = True
        else:
            rewards = True
            mark_events = True
    else:
        rewards = True
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

        if mark_events:
            if val["Name"] == "Deck" and val["Nickname"] == "Happening cards":
                for card in val["ContainedObjects"]:
                    if not eventVarExist(card["LuaScript"]):
                        card["LuaScript"] = card["LuaScript"] + "\n" + addEventVar(True)
            elif val["Name"] == "Deck" and val["Nickname"] == "Monsters crads":
                for card in val["ContainedObjects"]:
                    if not eventVarExist(card["LuaScript"]):
                        card["LuaScript"] = card["LuaScript"] + "\n" + addEventVar(False)
    
    # Expansions
    for val in JSON_data["ObjectStates"]:
        # Expansion Bag
        if val["Name"] == "Custom_Model_Infinite_Bag":
            for expansion in val["ContainedObjects"]:
                if expansion["Name"] == "Custom_Model_Bag" or expansion["Name"] == "Bag":
                    for content in expansion["ContainedObjects"]:

                        if rewards or mark_events:
                            if (content["Nickname"] == "" or matchesMonsterPattern(content["Nickname"])):
                                if content["Name"] == "Deck":
                                    for card in content["ContainedObjects"]:
                                        if rewards and (not rewardsVarExist(card["LuaScript"])):
                                            card["LuaScript"] = card["LuaScript"] + "\n" + translateRewards(card["Description"])
                                        # This marks more cards as it should, because too many decks have no Nickname
                                        if mark_events and (not eventVarExist(card["LuaScript"])):
                                            card["LuaScript"] = card["LuaScript"] + "\n" + addEventVar(False)    

                        if mark_events:
                            if content["Name"] == "Deck":
                                for card in content["ContainedObjects"]:
                                    if hasEventType(card["LuaScript"]) and (not eventVarExist(card["LuaScript"])):
                                        card["LuaScript"] = card["LuaScript"] + "\n" + addEventVar(True)
                                    

    newFile = open(fileName + "_Sniffed.json", "w+")
    newFile.write(json.dumps(JSON_data, indent=2))
    newFile.close()
    JSON_file.close()

if __name__ == "__main__":
    main(sys.argv, len(sys.argv))
    
    
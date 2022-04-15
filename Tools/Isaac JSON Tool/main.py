import sys
import json
import re

def getPattern(rewardType):
    return re.compile("((((\n|[+])([0-9]{1,2})\s)|([0-9]{1,2}))(" + rewardType + "s?))|((" + rewardType + "s?)\s?([0-9]{1,2}))", re.I)

def getReward(rewardType, rewardsString):
    amount = 0
    m = getPattern(rewardType).search(rewardsString)
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

def matchesMonsterPattern(nickname):
    pattern = re.compile("(.*)monster(.*)", re.I)
    return pattern.match(nickname)

def main(argv, argc):
    if argc < 2:
        print("\033[91mTo little parameters:\033[0m\n\r\033[93mPlease pass the file name of the file you want to sniff as parameter.\033[0m\n")
        return
    fileName = str(argv[1])
    m = re.search("\.json", fileName)
    if m != None:
        fileName = fileName[:m.start()]
    try:
        JSON_file = open(fileName + ".json", "r", encoding = "utf8")
    except:
        print("\033[91mThe File with the name '" + fileName + "' doesn't exist.\033[0m\n")
        return
    
    JSON_data = json.load(JSON_file)
    
    for val in JSON_data["ObjectStates"]:
        #print(val["Name"])
        if val["Name"] == "Deck" and val["Nickname"] == "Monsters cards":
            for card in val["ContainedObjects"]:
                #print(card["GUID"])
                if not rewardsVarExist(card["LuaScript"]):
                    card["LuaScript"] = card["LuaScript"] + "\n" + translateRewards(card["Description"])
    
    for val in JSON_data["ObjectStates"]:
        # Expansions
        if val["Name"] == "Custom_Model_Infinite_Bag":
            for expansion in val["ContainedObjects"]:
                if expansion["Name"] == "Custom_Model_Bag" or expansion["Name"] == "Bag":
                    for content in expansion["ContainedObjects"]:
                        if (content["Nickname"] == "" or matchesMonsterPattern(content["Nickname"])):
                            if content["Name"] == "Deck":
                                for card in content["ContainedObjects"]:
                                    if not rewardsVarExist(card["LuaScript"]):
                                        card["LuaScript"] = card["LuaScript"] + "\n" + translateRewards(card["Description"])

    newFile = open(fileName + "_Reward.json", "w+")
    newFile.write(json.dumps(JSON_data, indent=2))
    newFile.close()
    JSON_file.close()

if __name__ == "__main__":
    main(sys.argv, len(sys.argv))
    
    
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
    
    rewardsLua = rewardsLua + "{cents = " + str(cents) + ", loot = " + str(loot) + ", treasure = " + str(treasures) \
        + ", souls = " + str(souls) + "}"
    return rewardsLua

def matchesMonsterPattern(nickname):
    pattern = re.compile("(.*)monster(.*)", re.I)
    return pattern.match(nickname)

if __name__ == "__main__":
    fileName = str(sys.argv[1])
    JSON_file = open(fileName + ".json", "r", encoding = "utf8")
    JSON_data = json.load(JSON_file)
    for val in JSON_data["ObjectStates"]:
        #print(val["Name"])
        if val["Name"] == "Deck" and val["Nickname"] == "Monsters cards":
            for card in val["ContainedObjects"]:
                #print(card["GUID"])
                card["LuaScript"] = card["LuaScript"] + "\n" + translateRewards(card["Description"])
        # Expansions
        if val["Name"] == "Custom_Model_Infinite_Bag":
            for expansion in val["ContainedObjects"]:
                if expansion["Name"] == "Custom_Model_Bag" or expansion["Name"] == "Bag":
                    for content in expansion["ContainedObjects"]:
                        if (content["Nickname"] == "" or matchesMonsterPattern(content["Nickname"])):
                            if content["Name"] == "Deck":
                                for card in content["ContainedObjects"]:
                                    card["LuaScript"] = card["LuaScript"] + "\n" + translateRewards(card["Description"])
    newFile = open(fileName + "_Reward.json", "w+")
    newFile.write(json.dumps(JSON_data, indent=2))
    newFile.close()
    JSON_file.close()
    
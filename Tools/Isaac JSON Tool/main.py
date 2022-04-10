import json
import re

def translateRewards(rewardsString):
    rewardsLua = "rewards = "
    cents = loot = treasure = souls = 0
    
    m = re.search("(?<=(REWARD|Reward):\s)(.*\n?)*", rewardsString)
    if m != None:
        print(m.group(0))
    else:
        m = re.search("(?<=(REWARDS|Rewards):\s)(.*\n?)*", rewardsString)
        if m != None:
            print(m.group(0))
    
    rewardsLua = rewardsLua + "{cents = " + str(cents) + ", loot = " + str(loot) + ", treasure = " + str(treasure) \
        + ", souls = " + str(souls) + "}"
    return rewardsLua

if __name__ == "__main__":
    print("test")
    JSON_file = open("TS_Save_44.json", "r", encoding = "utf8")
    JSON_data = json.load(JSON_file)
    JSON_data = JSON_data["ObjectStates"]
    for val in JSON_data:
        #print(val["Name"])
        if val["Name"] == "Deck" and val["Nickname"] == "Monsters cards":
            for card in val["ContainedObjects"]:
                print(translateRewards(card["Description"]))
    JSON_file.close()
    
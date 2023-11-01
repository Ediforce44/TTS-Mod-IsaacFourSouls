import sys
import json
import re

originDict={
    "WARP_ZONE": "rwz",
    "ALT_ART": "aa",
    "TARGET": "t",
    "GISH": "gi",
    "TAPEWORM": "tw",
    "DICK_KNOTS": "dk",
    "UNBOXING_OF_ISAAC": "box",
    "PROMO": "p"
}

def findDecks(jsonObj, listOfDecks):
    deckObjs = []
    if (jsonObj["Name"] == "Bag") and ("ContainedObjects" in jsonObj):
        for object in jsonObj["ContainedObjects"]:
            deckObjs += findDecks(object, listOfDecks)
    elif (jsonObj["Name"] == "Deck") and (jsonObj["GUID"] in listOfDecks):
        deckObjs.append(jsonObj)
    return deckObjs

def pressCardNameInFormat(cardName, tags=[]):
    formatedName = ""
    for tag in tags:
        if tag in originDict:
            formatedName = originDict[tag]
    formatedName += "-"
    formatedName += re.sub("\W", "", re.sub("\s", "_", cardName.lower()))
    return formatedName

 
def insertGmNote(card):
    gmNote = ""
    if "Tags" in card:
        gmNote = pressCardNameInFormat(card["Nickname"], card["Tags"])
    else:
        gmNote = pressCardNameInFormat(card["Nickname"])
    card["GMNotes"] = gmNote

def main(argv, argc):
    if argc < 3:
        print("This tool will transform the name all cards from specific decks to GM-Note entries, which are matching the FOUR SOULS CARD IDs format.")
        print("Too few parameters:\n\t1: File name of the file you want to sniff.\n\t2...: GUIDs of the decks separated by spaces")
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

    deckNames = argv[2:]

    JSON_data = json.load(JSON_file)

    for object in JSON_data["ObjectStates"]:
        deckObjects = findDecks(object, deckNames)
        if len(deckObjects) != 0:
            for deckObj in deckObjects:
                for cardObj in deckObj["ContainedObjects"]:
                    insertGmNote(cardObj)
        
                                    
    newFileName = fileName
    newFileName += "_Converted.json"
    newFile = open(newFileName, "w+")
    newFile.write(json.dumps(JSON_data, indent=2))
    newFile.close()
    JSON_file.close()

if __name__ == "__main__":
    main(sys.argv, len(sys.argv))
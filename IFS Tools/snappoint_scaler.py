import sys
import json
import re

def scaleSnapPoint(snapPoint, xConv, yConv, zConv):
    snapPoint["Position"]["x"] *= xConv
    snapPoint["Position"]["y"] *= yConv
    snapPoint["Position"]["z"] *= zConv

def main(argv, argc):
    if argc < 5:
        print("This tool will scale position of the Global snappoints of your TTS save file.\n OR: You can input a JSON file with a entry called 'Start', which is a list of snappoint.")
        print("Too few parameters:\n\t1: File name of the file, which contains a list of snappoints.\n\t2: Value for scaling x\n\t3: Value for scaling y \n\t4: Value for scaling z")
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

    xConv = float(argv[2])
    yConv = float(argv[3])
    zConv = float(argv[4])

    JSON_data = json.load(JSON_file)

    if "Start" in JSON_data:
        for snapPoint in JSON_data["Start"]:
            scaleSnapPoint(snapPoint, xConv, yConv, zConv)
    else:
        for snapPoint in JSON_data["SnapPoints"]:
            scaleSnapPoint(snapPoint, xConv, yConv, zConv)
                                    
    newFileName = fileName
    newFileName += "_SScaled.json"
    newFile = open(newFileName, "w+")
    newFile.write(json.dumps(JSON_data, indent=2))
    newFile.close()
    JSON_file.close()

if __name__ == "__main__":
    main(sys.argv, len(sys.argv))
    
    
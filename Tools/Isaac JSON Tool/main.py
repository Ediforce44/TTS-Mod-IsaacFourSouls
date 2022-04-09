import json

if __name__ == "__main__":
    print("test")
    JSON_file = open("TS_Save_44.json", "r", encoding = "utf8")
    JSON_data = json.load(JSON_file)
    counter = 0
    JSON_data = JSON_data["ObjectStates"]
    for val in JSON_data:
        item = json.loads(json.dumps(val))
        if item["Name"] == "Deck":
            print(item["Nickname"])
            counter += 1
    print(counter)
    JSON_file.close()
    
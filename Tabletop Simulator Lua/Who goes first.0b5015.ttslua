--Candy Land [Fully Scripted] by Ramun Flame

function onload()
    speedTable  = {
        {"Slow", 60, 120},
        {"Normal", 30, 60},
        {"Fast", 15, 30},
        {"Super", 5, 10},
        {"Extreme", 1, 2},
        {"Instant", 0, 1}
    }
    
    sizeTable  = {
        {"Ant", 1},
        {"Mini", 2},
        {"Small", 4},
        {"Medium", 8},
        {"Large", 12},
        {"Larger", 15},
        {"Huge", 20},
        {"Whale",25}
    }
    firstPlayerVersion = true
    if firstPlayerVersion then
        sizeIndex = 2
        speedIndex = 5
        autoTurn = true
    else
        sizeIndex = 4
        speedIndex = 2
        autoTurn = false
    end
    
    self.setScale({sizeTable[sizeIndex][2],1,sizeTable[sizeIndex][2]})
    speed = speedTable[speedIndex][2]
    popupTime = speedTable[speedIndex][3]
    autoGame = false
    manual = false
    
    itemTable = {
        {"Ginderbread Man", 9},
        {"Candy Cane", 20},
        {"Jello", 42},
        {"Peanut", 69},
        {"Lollypop", 92},
        {"Ice Cream", 102},
        {"End",134}
    }
    cardNames = {}

    path = createBoard()
    
    self.createButton({--0
        click_function = "none", function_owner = self,
        label = "AutoTurn", position = {-0.35,0.3,-1.1},
        width = 0, height = 0, font_size = 70, font_color={1, 1, 1}
    })
    self.createButton({--1
        click_function = "none", function_owner = self,
        label = "AutoTurn", position = {-0.35,0.3,-1.1},
        width = 0, height = 0, font_size = 70
    })
    
    local toggleText = "OFF"
    if autoTurn then
        toggleText = "ON"
    end
        
    self.createButton({--2
        click_function = "autoSwitch", function_owner = self,
        label = toggleText, position = {0.1,0.3,-1.1},
        width = 150, height = 70, font_size = 70, tooltip = "Toggle AutoTurn: Will go to next turn automatically if turned on."
    })
    
    self.createButton({--3
        click_function = "none", function_owner = self,
        label = "AutoGame", position = {-0.35,0.3,-1.3},
        width = 0, height = 0, font_size = 70, font_color={1, 1, 1}
    })
    self.createButton({--4
        click_function = "none", function_owner = self,
        label = "AutoGame", position = {-0.35,0.3,-1.3},
        width = 0, height = 0, font_size = 70
    })
    
    local toggleRText = "OFF"
    if autoGame then
        toggleRText = "ON"
    end
        
    self.createButton({--5
        click_function = "autoRSwitch", function_owner = self,
        label = toggleRText, position = {0.125,0.3,-1.3},
        width = 150, height = 70, font_size = 70, tooltip = "Toggle AutoGame: Will play again automatically when game ends if turned on."
    })
    
    self.createButton({--6
        click_function = "none", function_owner = self,
        label = speedTable[speedIndex][1], position = {0.8,0.3,-1.1},
        width = 0, height = 0, font_size = 70, font_color={1, 1, 1}
    })
    self.createButton({--7
        click_function = "none", function_owner = self,
        label = "-" .. speedTable[speedIndex][1] .. "-", position = {0.8,0.3,-1.1},
        width = 0, height = 0, font_size = 70, tooltip = ""
    })
    
    self.createButton({--8
        click_function = "decreaseSpeed", function_owner = self,
        label = "<<", position = {0.4,0.3,-1.1},
        width = 100, height = 70, font_size = 70, tooltip = "Decrease Game Speed"
    })
    
    self.createButton({--9
        click_function = "increaseSpeed", function_owner = self,
        label = ">>", position = {1.2,0.3,-1.1},
        width = 100, height = 70, font_size = 70, tooltip = "Increase Game Speed"
    })
    
    self.createButton({--10
        click_function = "none", function_owner = self,
        label = sizeTable[sizeIndex][1], position = {0.8,0.3,-1.3},
        width = 0, height = 0, font_size = 70, font_color={1, 1, 1}
    })
    self.createButton({--11
        click_function = "none", function_owner = self,
        label = "-" .. sizeTable[sizeIndex][1] .. "-", position = {0.8,0.3,-1.3},
        width = 0, height = 0, font_size = 70
    })
    
    self.createButton({--12
        click_function = "decreaseSize", function_owner = self,
        label = "<-", position = {0.4,0.3,-1.3},
        width = 100, height = 70, font_size = 70, tooltip = "Decrease Game Size"
    })
    
    self.createButton({--13
        click_function = "increaseSize", function_owner = self,
        label = "->", position = {1.2,0.3,-1.3},
        width = 100, height = 70, font_size = 70, tooltip = "Increase Game Size"
    })
    
    if firstPlayerVersion then
        self.createButton({
            click_function = "spawnPieces", function_owner = self,
            label = "Who goes\nfirst?", position = {0,0.3,0},
            width = 1200, height = 700, font_size = 250, tooltip = "Make sure all players are seated."
        })
    else
        self.createButton({
            click_function = "spawnPieces", function_owner = self,
            label = "Start Game", position = {0,0.3,1.3},
            width = 1200, height = 250, font_size = 200, tooltip = "Make sure all players are seated."
        })
        self.createButton({
            click_function = "manualMode", function_owner = self,
            label = "Manual Mode", position = {0,0.3,1.7},
            width = 800, height = 100, font_size = 100, tooltip = "Spawn cards/pieces for current players, and play without scripts."
        })
    end
end

function none() end

function autoSwitch()
    if autoTurn then
        autoTurn = false
        self.editButton({index=2, label = "OFF"})
    else
        if currentTurn then
            nextTurn()
        end
        autoTurn = true
        self.editButton({index=2, label = "ON"})
    end
end

function autoRSwitch()
    if autoGame then
        autoGame = false
        self.editButton({index=5, label = "OFF"})
    else
        if gameEnd then
            playAgain()
        end
        autoGame = true
        self.editButton({index=5, label = "ON"})
    end
end

function increaseSpeed()
    speedIndex = speedIndex + 1
    speed = speedTable[speedIndex][2]
    popupTime = speedTable[speedIndex][3]
    self.editButton({index=findButton(speedTable[speedIndex-1][1]), label = speedTable[speedIndex][1]})
    self.editButton({index=findButton("-" .. speedTable[speedIndex-1][1] .. "-"), label = "-" .. speedTable[speedIndex][1] .. "-"})
    if speedIndex == tablelength(speedTable) then
        self.editButton({index=findButton(">>"), label = "", height=0, width=0})
    elseif speedIndex == 2 then
        self.editButton({index=findButton(""), label = "<<", height=70, width=100})
    end
end

function decreaseSpeed()
    speedIndex = speedIndex - 1
    speed = speedTable[speedIndex][2]
    popupTime = speedTable[speedIndex][3]
    self.editButton({index=findButton(speedTable[speedIndex+1][1]), label = speedTable[speedIndex][1]})
    self.editButton({index=findButton("-" .. speedTable[speedIndex+1][1] .. "-"), label = "-" .. speedTable[speedIndex][1] .. "-"})
    if speedIndex == 1 then
        self.editButton({index=findButton("<<"), label = "", height=0, width=0})
    elseif speedIndex == tablelength(speedTable)-1 then
        self.editButton({index=findButton(""), label = ">>", height=70, width=100})
    end
end

function scaleAll()
    resetPositions(true, true)
    self.setScale({sizeTable[sizeIndex][2],1,sizeTable[sizeIndex][2]})
    if playerList ~= nil then
        local snappoints = self.getSnapPoints()
        for i, player in ipairs(playerList) do
            player.pawn.setScale(self.getScale()*0.022)
            player.pawn.setCustomObject({thickness = self.getScale().x*0.022})
        end
    end
    if deck ~= nil then
        deck.setScale(self.getScale()*0.13)
    end
    if discard ~= nil then
        discard.setScale(self.getScale()*0.13)
    end
end

function resetPositions(decks, pawns)
    local p = self.getPosition()
    local s = self.getScale()
    if pawns then
        if playerList ~= nil then
            local snappoints = self.getSnapPoints()
            for i, player in ipairs(playerList) do
                if player.space > 0 then
                    player.pawn.setPosition(self.positionToWorld(snappoints[player.space].position))
                    player.pawn.setRotation(snappoints[player.space].rotation)
                else
                    player.pawn.setPosition({(s.x*(-0.97-(0.04*(i-1))))+p.x, 2+(0.17*s.x)+p.y, (s.z*-0.92)+p.z})
                    player.pawn.setRotation({90,270,0})
                end
            end
        end
    end
    
    if decks then
        if deck ~= nil then
            deckPos = {(s.x*-1.2)+p.x,p.y,(s.z*1.22)+p.z}
            deck.setPosition(deckPos)
            deck.setRotation({180,180,0})
        end
        if discard ~= nil then
            discardPos = {(s.x*-0.85)+p.x,p.y,(s.z*1.22)+p.z}
            discard.setPosition(discardPos)
            discard.setRotation({0,180,0})
        end
    end
end

function onObjectDrop(colorName, obj)
    if obj == self  then
        resetPositions(true, false)
    end 
end

function increaseSize()
    sizeIndex = sizeIndex + 1
    scaleAll()
    self.editButton({index=findButton(sizeTable[sizeIndex-1][1]), label = sizeTable[sizeIndex][1]})
    self.editButton({index=findButton("-" .. sizeTable[sizeIndex-1][1] .. "-"), label = "-" .. sizeTable[sizeIndex][1] .. "-"})
    if sizeIndex == tablelength(sizeTable) then
        self.editButton({index=findButton("->"), label = "-", height=0, width=0})
    elseif sizeIndex == 2 then
        self.editButton({index=findButton("-"), label = "<-", height=70, width=100})
    end
end

function decreaseSize()
    sizeIndex = sizeIndex - 1
    scaleAll()
    self.editButton({index=findButton(sizeTable[sizeIndex+1][1]), label = sizeTable[sizeIndex][1]})
    self.editButton({index=findButton("-" .. sizeTable[sizeIndex+1][1] .. "-"), label = "-" .. sizeTable[sizeIndex][1] .. "-"})
    if sizeIndex == 1 then
        self.editButton({index=findButton("<-"), label = "-", height=0, width=0})
    elseif sizeIndex == tablelength(sizeTable)-1 then
        self.editButton({index=findButton("-"), label = "->", height=70, width=100})
    end
end

function deleteAllButtons()
    for i = tablelength(self.getButtons()) - 1, 0, -1 do
        self.removeButton(i)
    end
end

function findButton(name)
    for i, button in ipairs(self.getButtons()) do
        if button.label == name then
            return button.index
        end
    end
    return false
end

function manualMode()
    manual = true
    deleteAllButtons()
    spawnPieces()
end

function startGame()
    gameEnd = false
    totalTurns = 0
    currentTurn = math.random(1, tablelength(playerList))
    Wait.frames(function() createNextTurnButton() end, 60)
end

function spawnPieces()
    menuCleanup()
    cleanUp()
    spawnDeck(deckFace, deckBack)
    piecesLoading = 0
    createPlayerList()
    if manual == false then
        Wait.frames(function() waitForLoading() end, 60)
    end
end

function waitForLoading()
    if piecesLoading == 0 then
        Wait.frames(function() startGame() end, 60)
    else
        Wait.frames(function() waitForLoading() end, 60)
    end
end

function createPlayerList()
    local playerColors = {
        {"Red", "http://cloud-3.steamusercontent.com/ugc/156902491451109929/0EDF98992F964C668BE5691D86852B9556595819/"},
        {"Orange", "http://cloud-3.steamusercontent.com/ugc/1022826195186145852/691FF11FB43CE5E731613D1A913E4F1A815692FA/"},
        {"Yellow", "http://cloud-3.steamusercontent.com/ugc/156902491451103590/51AC1304BC9247521C05CDD65BF984EEC2B38D21/"},
        {"Green", "http://cloud-3.steamusercontent.com/ugc/156902491451089663/B1D0D56E0A00DEE5C368AC97E833E7133918588F/"},
        {"Teal", "http://cloud-3.steamusercontent.com/ugc/1022826195186142404/40CAD87129531A4F59E0242B33BA6FBFFDEF9C55/"},
        {"Blue", "http://cloud-3.steamusercontent.com/ugc/156902491451102051/67B42061A5AEABF9B244DBDFF750AE05AFB72EF5/"},
        {"Purple", "http://cloud-3.steamusercontent.com/ugc/156902491451104990/B9BB440FECE5DCDAA744CD3F7AFCF727DC385E35/"},
        {"Pink", "http://cloud-3.steamusercontent.com/ugc/1049848592670955309/1694CC9B97E82176BA28431A4BB696603773056B/"},
        {"White", "http://cloud-3.steamusercontent.com/ugc/1049848592670953406/C7DA925756009BE41C07710601377CCCACEE8013/"},
        {"Brown", "http://cloud-3.steamusercontent.com/ugc/1022826195186147137/28DD76656FEB75956FC21C52BE06CF0CB666899B/"}
    }

    playerList = {}
    for _, player in ipairs(Player.getPlayers()) do
        for i, color in ipairs(playerColors) do
            if player.color == color[1] then
                piecesLoading = piecesLoading + 1
                createPlayer(color[1], color[2], player.steam_name)
                break
            end
        end
    end
end

function createPlayer(col, img, n)
    local p = self.getPosition()
    local s = self.getScale()
    local player = {
        name = n,
        color = col, 
        space = 0,
        turns = 0,
        loseTurn = false
    }
    local pos = {(s.x*(-0.97-(0.04*tablelength(playerList))))+p.x, (s.x*0.17)+p.y, (s.z*-0.92)+p.z}
    local var = spawnObject({ 
        type                = "Custom_Token",
        position            = pos, 
        scale               = self.getScale()*0.022,
        rotation            = {90,270,0}, 
        callback_function   = function(obj, player) obj.setName(n) piecesLoading = piecesLoading - 1 end
    })
    var.setCustomObject({image = img, thickness = self.getScale().x*1.1})
    player.pawn = var
    table.insert(playerList, player)
end

function tablelength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function createNextTurnButton()
    if autoTurn then
        nextTurn()
        --setTurn(playerList[currentTurn].color)
    else
        local playerColor = playerList[currentTurn].color
        local fontColor = "White"
        if playerColor == "White" then
            fontColor = "Black"
        end
        setTurn(playerList[currentTurn].color)
        self.createButton({
            click_function = "nextTurn", function_owner = self,
            label = "Take " .. playerList[currentTurn].name .. "'s Turn", position = {0,0.3,1.2},
            width = 1300, height = 100, font_size = 100, font_color = fontColor, color = playerColor
        })
    end
end

function createBoard()
    local colorTable  = {"Green","Red","Purple","Yellow","Blue","Orange"}
    local board = {}
    local value = 0
    local offset = 0
    
    for i = 1, 134, 1 do 
        item = addItem(i)
        if item then
            board[i] = item
            offset = offset + 1
        else
            value = (i-offset)%6 + 1
            board[i] = colorTable[value]
        end
    end
    
    return board
end

function addItem(index)
    for i, item in ipairs(itemTable) do
        if index == item[2] then
            return item[1]
        end
    end
end

function spawnDeck()
    local faceImg = "http://i.imgur.com/IGvZhkq.png"
    local backImg = "http://i.imgur.com/aaSng6y.png"
    local p = self.getPosition()
    local s = self.getScale()
    
    deck = spawnObject({ 
        type                = "DeckCustom",
        position            = {(s.x*-1.2)+p.x,1.3+p.y,(s.z*1.22)+p.z}, 
        scale               = self.getScale()*0.13,
        rotation            = {0,180,180}, 
        callback_function   = function(obj) nameCards(obj) obj.randomize() end
    })
    deck.setCustomObject({face = faceImg, back = backImg, number = 66})
end

function nameCards(object)
    local deckContents = {
        {"Red Single", 8},
        {"Red Double", 10},
        {"Purple Single", 18},
        {"Purple Double", 20},
        {"Yellow Single", 28},
        {"Yellow Double", 30},
        {"Blue Single", 38},
        {"Blue Double", 40},
        {"Orange Single", 48},
        {"Orange Double", 50},
        {"Green Single", 58},
        {"Green Double", 60},
        {"Candy Cane", 61},
        {"Ginderbread Man", 62},
        {"Peanut", 63},
        {"Lollypop", 64},
        {"Jello", 65},
        {"Ice Cream", 66}
    }
    object.setName("Candy Deck")
    local t = 1
    for i, card in ipairs(object.getObjects()) do
        table.insert(cardNames,{card.guid,deckContents[t][1]})
        if i == deckContents[t][2] then
            t = t + 1
        end
    end
end

function getCardName(c)
    for i, card in ipairs(cardNames) do
        if c.guid == card[1] then
            return card[2]
        end
    end
    return "Red Single[Error]"
end

function drawCard()
    local card = nil
    local cardName = ""
    if deck ~= nil then
        if tablelength(deck.getObjects()) == 2 then
            lastCard = deck.getObjects()[2].guid
        end
        card = deck.takeObject()
        cardName = getCardName(card)
        card.setName(cardName)
        toDiscard(card, false)
    else
        card = getObjectFromGUID(lastCard)
        cardName = getCardName(card)
        card.setName(cardName)
        toDiscard(card, true)
    end
    
    return cardName
end

function toDiscard(object, shuffle)
    local p = self.getPosition()
    local s = self.getScale()
    deckPos = {(s.x*-1.2)+p.x,p.y,(s.z*1.22)+p.z}
    discardPos = {(s.x*-0.85)+p.x,p.y,(s.z*1.22)+p.z}
    if discard ~= nil then
        discard = group({discard, object})[1]
        discard.setName("Candy Deck Discard")
        if shuffle then
            shuffleDiscard()
        end
    else
        discard = object
    end
    if discard ~= null then
        discard.setPosition(discardPos)
        discard.setRotation({0,180,0})
    end
    if deck ~= nil then
        deck.setPosition(deckPos)
        deck.setRotation({180,180,0})
    end
end

function shuffleDiscard()
    local p = self.getPosition()
    local s = self.getScale()
    local pos = {(s.x*-1.2)+p.x,1.3+p.y,(s.z*1.22)+p.z}
    if deck ~= nil then
        discard.setRotation({180,180,0})
        deck = group({deck, discard})[1]
    else
        deck = discard
    end
    discard = nil
    deck.setName("Candy Deck")
    deck.setRotation({180,180,0})
    if speed > 1 then
        deck.setPositionSmooth(pos, false, speed < 10)
    else
        deck.setPosition(pos)
    end
    deck.randomize()
end

function move(dest, player, direct)
    local goTo = player.space
    if direct then
        goTo = dest
    elseif player.space < dest then
        goTo = goTo + 1
    else
        goTo = goTo - 1
    end
    local snappoints = self.getSnapPoints()
    local pos = self.positionToWorld(snappoints[goTo].position)
    pos.y = pos.y + (0.17 * self.getScale().x)
    if speed > 1 then
        player.pawn.setPositionSmooth(pos, false, speed < 10)
        player.pawn.setRotationSmooth(snappoints[goTo].rotation, false, speed < 10)
    else
        player.pawn.setPosition(pos)
        player.pawn.setRotation(snappoints[goTo].rotation)
    end
    player.space = goTo
    if goTo ~= dest then
        Wait.frames(function() move(dest,player) end, speed)
    else
        player.pawn.setRotationSmooth({0, snappoints[goTo].rotation.y + 180,0}, false, false)
    end
end

function nextSpace(dest, cardName)
    for j, item in ipairs(itemTable) do
        if item[1] == cardName then
            return item[2]
        end
    end
    t = string.match(cardName, "Single")
    for i, spc in ipairs(path) do
        if string.match(cardName, spc) and i > dest then
            if t then
                return i
            else
                t = true
            end
        end
    end
    
    return 134
end

function takeShortcuts(player)
    if player.space == 5 then
        broadcastToAll(player.name .. " takes a shortcut through the Rainbow Trail!", player.color)
        move(59, player, true)
        Wait.frames(function() createNextTurnButton() end, popupTime)
    elseif player.space == 35 then
        broadcastToAll(player.name .. " takes a shortcut through the Gumdrop Pass!", player.color)
        move(45, player, true)
        Wait.frames(function() createNextTurnButton() end, popupTime)
    else
        loseTurn(player)
    end
end

function loseTurn(player)
    if player.space == 46 or player.space == 86 or player.space == 117 then
        broadcastToAll(player.name .. " is stuck on a licorice space! Lose one turn...", player.color)
        player.loseTurn = true
        Wait.frames(function() createNextTurnButton() end, popupTime)
    else
        createNextTurnButton()
    end
end

function nextTurn()
    if findButton("Take " .. playerList[currentTurn].name .. "'s Turn") then
        self.removeButton(findButton("Take " .. playerList[currentTurn].name .. "'s Turn"))
    end
    takeTurn(playerList[currentTurn])
    if currentTurn < tablelength(playerList) then
        currentTurn = currentTurn + 1
    else
        currentTurn = 1
    end
end

function takeTurn(player)
    if player.loseTurn then
        broadcastToAll(player.name .. " is stuck on a licorice space! Skipping turn...", player.color)
        player.loseTurn = false
        Wait.frames(function() createNextTurnButton() end, popupTime)
    else
        local cardName = drawCard()
        local dest = nextSpace(player.space,cardName)
        local spaces = dest-player.space
        totalTurns = totalTurns + 1
        player.turns = player.turns + 1
        if spaces > 0 then
            broadcastToAll("Turn " .. totalTurns .. " : " .. player.name .. " draws a " .. cardName .. " card to move forward " .. spaces .. " spaces.", player.color)
        else
            spaces = spaces * -1
            broadcastToAll("Turn " .. totalTurns .. " : " .. player.name .. " draws a " .. cardName .. " card to move backward " .. spaces .. " spaces.", player.color)
        end
        move(dest, player, speed == 0)
        local wait = (spaces * speed) + popupTime
        if dest == 134 then
            Wait.frames(function() playerWin(player) end, wait)
        else
            Wait.frames(function() takeShortcuts(player) end, wait)
        end
    end
end

function setTurn(color)
    --Turns.enable = true
    --Turns.turn_color = color
    Global.call("setNewStartPlayer", {playerColor = color})
end

function playerWin(player)
    setTurn(player.color)
    broadcastToAll(player.name .. " won the game in " .. player.turns .. " turns. Congratulations!", player.color)
    if autoGame then
        Wait.frames(function() playAgain() end, 120)
    else
        gameEnd = true
        self.createButton({
            click_function = "playAgain", function_owner = self,
            label = "Play Again?", position = {-0.65,0.3,1.2},
            width = 650, height = 100, font_size = 100, tooltip = "Play again with same players."
        })
        self.createButton({
            click_function = "spawnPieces", function_owner = self,
            label = "New Game", position = {0.7,0.3,1.2},
            width = 600, height = 100, font_size = 100, tooltip = "Check for seated players and start new game."
        })
    end
end

function playAgain()
    local p = self.getPosition()
    local s = self.getScale()
    local pos = 0
    local rot = {90,270,0}
    menuCleanup()
    if discard ~= nil then
        shuffleDiscard()
    end
    for i, player in ipairs(playerList) do
        player.space = 0
        player.turns = 0
        pos = {(s.x*(-0.97-(0.04*(i-1))))+p.x, (s.x*0.17)+p.y, (s.z*-0.92)+p.z}
        if speed > 0 then
            player.pawn.setPositionSmooth(pos, true, speed < 10)
            player.pawn.setRotationSmooth(rot, true, speed < 10)
        else
            player.pawn.setPosition(pos)
            player.pawn.setRotation(rot)
        end
    end
    Wait.frames(function() startGame() end, 60)
end

function menuCleanup()
    deleteButton("Play Again?")
    deleteButton("New Game")
    deleteButton("Start Game")
    deleteButton("Manual Mode")
    deleteButton("Who goes\nfirst?")
end

function deleteButton(name)
    local buttonIndex = findButton(name)
    if buttonIndex then
        self.removeButton(buttonIndex)
    end
end

function destroy(obj)
    if obj ~= nil then
        obj.destroy()
    end
end

function cleanUp()
    destroy(deck)
    destroy(discard)
    if playerList ~= nil then
        for i, player in ipairs(playerList) do
            destroy(player.pawn)
        end
    end
end

function onDestroy()
    cleanUp()
end
function onLoad()
    self.createButton({
    click_function = "openTrapDoor",
    function_owner = self,
    position = {0, 0.11,0},
    rotation = {0, 90, 0},
    width = 2000,
    height = 2000,
    color = {69, 69, 69, 0},})
end

function openTrapDoor()
    nextState = self.getStateId()+1
    numberOfStates = self.getStatesCount()
    if nextState > numberOfStates then
        self.setState(1)
    else
        self.setState(nextState)
    end
end

function onCollisionEnter()
    self.reset()
end
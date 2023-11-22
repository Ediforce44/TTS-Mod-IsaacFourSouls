--- Edited by Ediforce44
owner_color = "Green"
zone_guid = Global.getTable("ZONE_GUID_SOUL")[owner_color]       --EbyE44

MIN_VALUE = 0
MAX_VALUE = 10

value = 0

function deal_soul_token(object, color)         --EbyE44
    if not Global.call("isPlayerAuthorized", {playerColor = color, ownerColor = owner_color}) then
        return
    end
    Global.call("placeSoulToken", {playerColor = owner_color})
end

function onUpdate()
    local soulCount = getSoulCountInZone()
    if soulCount ~= value then
        value = soulCount
        updateValue()
    end
end

function getSoulCountInZone()
    return getObjectFromGUID(zone_guid).getVar("souls_in_this_zone") or 0
end

local function createAll()
    local ttText = "[b]Soul Counter[/b][i]\nClick: Place Soul Token[/i]"

    self.createButton({
      label=tostring(value),
      click_function="deal_soul_token",
      tooltip=ttText,
      function_owner=self,
      position={0,0.05,0},
      height=1000,
      width=1000,
      alignment = 3,
      scale={x=1, y=1, z=1},
      font_size=820,
      font_color={255,255,255,100},
      color={0,0,0,0}
      })

    self.createInput({
        value = self.getName(),
        input_function = "editName",
        tooltip=ttText,
        label = "Counter",
        function_owner = self,
        alignment = 3,
        position = {0,0.05,1.7},
        width = 1000,
        height = 350,
        font_size = 310,
        scale={x=1, y=1, z=1},
        font_color= {255,255,255,100},
        color = {0,0,0,0}
        })
end

function onLoad(saved_data)

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        light_mode = loaded_data[1]
        value = loaded_data[2]
    end

    createAll()
end


function onSave()
    return JSON.encode({value = value})
end

function removeAll()
    self.removeInput(0)
    self.removeButton(0)
end

function reloadAll()
    removeAll()
    createAll()
end

function updateValue()
    self.editButton({
        index = 0,
        label = tostring(value),
    })
end
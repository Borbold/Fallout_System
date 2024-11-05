function onLoad()
    locColors = "White Red Green Blue Brown Teal Yellow Orange Purple Pink"
    putObjects, locGUID = {}, 0
    avatar = getObjectFromGUID(self.getGMNotes())
end

function onCollisionEnter(info)
    local obj = info.collision_object
    if locGUID == 0 or locGUID ~= obj.getGUID() then locGUID = obj.getGUID()
    else return end
    
    local l1 = '"ImageURL":'
    local l2 = '"ImageSecondaryURL"'
    local objJSON = obj.getJSON()
    local URLImage = objJSON:sub(objJSON:find(l1) + #l1, objJSON:find(l2) - 1)
    URLImage = URLImage:match([["([^"]+)]])
    local locPos = self.positionToLocal(obj.getPosition())
    if locPos.y > 0 then
        local name = obj.getName():gsub("%[.-%]","")
        local arg = {name = name, description = obj.getDescription(), color = self.getName(), image = URLImage}
        table.insert(putObjects, arg)
        
        CallGlobal(putObjects)
        avatar.call("UpdateInformation", putObjects)
    end
end

function onCollisionExit(info)
    local obj = info.collision_object
    if locGUID ~= 0 then locGUID = 0
    else return end

    local locPos = self.positionToLocal(obj.getPosition())
    if locPos.y > 0 then
        local nameObj = obj.getName():gsub("%[.-%]","")
        local id
        for i = 1, #putObjects do
            if nameObj == putObjects[i].name then
                id = i
                break
            end
        end
        table.remove(putObjects, id)
        CallGlobal(#putObjects == 0 and {{color = self.getName()}} or putObjects)
        avatar.call("UpdateInformation", #putObjects == 0 and {{}} or putObjects)
    end
end

function CallGlobal(putObjects)
    for c in locColors:gmatch("%S+") do
        if self.getName() == c then
            Global.call("UpdateInformation", putObjects)
            break
        end
    end
end
function UpdateSave()
    local dataToSave = {
        ["allObjMeta"] = allObjMeta
    }
    local savedData = JSON.encode(dataToSave)
    self.script_state = savedData
end

function onLoad(savedData)
    allObjMeta = {}
    if(savedData ~= "") then
        local loadedData = JSON.decode(savedData)
        allObjMeta = loadedData.allObjMeta or allObjMeta
    end
end

function SetObjMetaBag(parametrs)
    local pos, rot
    for i = 1, #parametrs.positions do
        pos = parametrs.positions[i].x.." "..parametrs.positions[i].y.." "..parametrs.positions[i].z
        rot = parametrs.rotations[i].x.." "..parametrs.rotations[i].y.." "..parametrs.rotations[i].z

        Wait.time(|| table.insert(allObjMeta, {parametrs.objGUID[i], pos, rot, self.getGUID()}), 0.4, end)
    end
    UpdateSave()
end

function GetObjectMetaBag()
    return allObjMeta
end
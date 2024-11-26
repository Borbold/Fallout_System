function UpdateSave()
    local dataToSave = {
        ["allObjMeta"] = allObjMeta
    }
    local savedData = JSON.encode(dataToSave)
    self.script_state = savedData
end

function onLoad(savedData)
    local loadedData = JSON.decode(savedData)
    allObjMeta = loadedData and loadedData.allObjMeta or {}

    local headers = {
        Authorization = "token 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",
        ["Content-Type"] = "application/json",
        Accept = "application/json",
    }

    local resText = ""
    WebRequest.custom("https://github.com/Borbold/Sugule-shop/blob/main/Test.txt",
            "GET", true, nil, headers, function(request)
        if request.is_error then
            log(request.error)
            return
        end

        local responseData = JSON.decode(request.text)
        for i,v in ipairs(responseData.payload.blob.rawLines) do
            resText = resText..v.."\n"
        end
    end)
end

function SetObjMetaBag(parametrs)
    local pos, rot
    for i = 1, #parametrs.positions do
        pos = parametrs.positions[i].x.." "..parametrs.positions[i].y.." "..parametrs.positions[i].z
        rot = parametrs.rotations[i].x.." "..parametrs.rotations[i].y.." "..parametrs.rotations[i].z

        table.insert(allObjMeta, {parametrs.objGUID[i], pos, rot, self.getGUID()})
    end
    UpdateSave()
end

function GetObjectMetaBag()
    return allObjMeta
end

function GetCostItem(nameItem)
    local findName, locDesc, idObj = false, "", 0
    for w in resText:gmatch("[^\n%.]+") do
        if(findName and w:find("cost:")) then
            return {itemCost = tonumber(w:gsub("%D", ""), 10), descObj = locDesc:sub(1, #locDesc - 1)}
        end
        if(findName) then locDesc = locDesc..w.."\n" end
        if(w == nameItem) then idObj = id findName = true break end
    end
    return {}
end
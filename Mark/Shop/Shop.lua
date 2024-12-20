function UpdateSave()
    local dataToSave = {
        ["allStoresGUID"] = allStoresGUID
    }
    local savedData = JSON.encode(dataToSave)
    self.script_state = savedData
end

function onLoad(savedData)
    CreateGlobalVariable()
    if(savedData ~= "") then
        local loadedData = JSON.decode(savedData)
        allStoresGUID = loadedData.allStoresGUID or {}
        if(#allStoresGUID > 0) then
            for id,storeGUID in ipairs(allStoresGUID) do
                local storeName = getObjectFromGUID(storeGUID).getName()
                Wait.time(|| XMLReplacementAdd(id, storeName), 0.3 + id/5)
            end
        end
    end
end

function CreateGlobalVariable()
    readyScriptUnderItem, readyScriptUnderBag = "", ""
    Wait.time(function()
      WebRequest.get("https://raw.githubusercontent.com/Borbold/Fallout_System/refs/heads/main/Mark/Shop/Item.lua", function(request)
        if request.is_error then
            log(request.error)
        else
          readyScriptUnderItem = request.text
        end
      end)
      WebRequest.get("https://raw.githubusercontent.com/Borbold/Fallout_System/refs/heads/main/Mark/Shop/Bag.lua", function(request)
        if request.is_error then
            log(request.error)
        else
          readyScriptUnderBag = request.text
        end
      end)
    end, 1)

    --[[local headers = {
        ["Content-Type"] = "application/json",
        Accept = "application/json",
    }
    Wait.time(function()
      WebRequest.custom("https://github.com/Borbold/Fallout_System/blob/main/Mark/Shop/Item.lua", "GET", true, nil, headers, function(requestItem)
          if requestItem.is_error then
              print("Request item failed: " .. requestItem.error)
              return
          end

          local responseData = JSON.decode(requestItem.text)
          for i,v in ipairs(responseData.payload.blob.rawLines) do
            readyScriptUnderItem = readyScriptUnderItem..v.."\n"
          end

          if(requestItem.is_done) then
            WebRequest.custom("https://github.com/Borbold/Fallout_System/blob/main/Mark/Shop/Bag.lua", "GET", true, nil, headers, function(requestBag)
              if requestBag.is_error then
                  print("Request bag failed: " .. requestBag.error)
                  return
              end

              local responseData = JSON.decode(requestBag.text)
              for i,v in ipairs(responseData.payload.blob.rawLines) do
                readyScriptUnderBag = readyScriptUnderBag..v.."\n"
              end
            end)
          end
      end)
    end, 1)]]

    allObjectsItemGUID = {}
    watchTag = {"sell item", "coin pouch"}
    CoinPouchGUID = ""
end

function AddNewItem(_, _, id)
    id = StringInNumber(id)
    CreateBag(nil, nil, nil, id)
end

function PercentageSubjects(_, _, id)
    local percent = StringInNumber(self.UI.getAttribute(id, "text"))
    percent = ((percent - 25) > 0 and (percent - 25)) or 100
    self.UI.setAttribute(id, "text", percent.."%")
end

function onCollisionEnter(info)
    local obj = info.collision_object
    if(#watchTag ~= 2 or obj.getPosition().y < self.getPosition().y) then return end

    if(obj.hasTag(watchTag[1])) then
      table.insert(allObjectsItemGUID, obj.getGUID())
    elseif(obj.hasTag(watchTag[2])) then
      Wait.time(|| SetNumberCoinsObjects(obj.getGUID()), 0.2)
    end
    obj.addTag("Picked object shop")
end

function onObjectPickUp(_, obj)
    if(not obj.hasTag("Picked object shop") or obj.getPosition().y < self.getPosition().y) then return end

    if(allObjectsItemGUID and #allObjectsItemGUID > 0) then
      if(obj.hasTag(watchTag[1])) then
        for i, v in ipairs(allObjectsItemGUID) do
          if(v == obj.getGUID()) then
            table.remove(allObjectsItemGUID, i)
            break
          end
        end
      elseif(obj.hasTag(watchTag[2])) then
        Wait.time(|| SetNumberCoinsObjects(""), 0.2)
      end
    end
    obj.removeTag("Picked object shop")
end
function SetNumberCoinsObjects(CoinPouchGUID)
    for _, g in ipairs(allObjectsItemGUID) do
      Wait.time(|| getObjectFromGUID(g).call("SetCoinPouchGUID", {guid = CoinPouchGUID}), 0.5)
    end
end

function onObjectDestroy(info)
    DeleteItem(info.getGUID())
    DeleteBag(info.getGUID())
end
function DeleteItem(guid)
    for i, v in ipairs(allObjectsItemGUID) do
      if(v == guid) then
        table.remove(allObjectsItemGUID, i)
        break
      end
    end
end
function DeleteBag(guid)
    for index, g in ipairs(allStoresGUID) do
      if(g == guid) then
        XMLReplacementDelete((index - 1)*2 + 1)
        table.remove(allStoresGUID, index)
        UpdateSave()
        break
      end
    end
end

function CreateBag(_, _, _, id)
  if(#allObjectsItemGUID > 0) then
    Wait.time(|| CreateScriptInItem(), 0.5)
    Wait.time(|| PutObjectsInBag(id), 0.8)
  end
end
function CreateScriptInItem()
  print("Adding scripts from item")
  for _, guid in ipairs(allObjectsItemGUID) do
    getObjectFromGUID(guid).setLuaScript(readyScriptUnderItem)
  end
end
function PutObjectsInBag(id)
  local spawnBag = nil
  if(id == nil) then
    local selfPosition = self.getPosition()
    local spawnParametrs = {
      type = "Bag",
      position = {x = selfPosition.x, y = selfPosition.y + 2, z = selfPosition.z - 7},
      rotation = {x = 0, y = 0, z = 0},
      scale = {x = 0.5, y = 0.5, z = 0.5},
      sound = false,
      snap_to_grid = true,
    }
    spawnBag = spawnObject(spawnParametrs)
    Wait.time(|| CreateScriptInBag(spawnBag), 0.2)
    Wait.time(function() table.insert(allStoresGUID, spawnBag.getGUID()) XMLReplacementAdd(#allStoresGUID) UpdateSave() end, 0.3)
  else
    spawnBag = getObjectFromGUID(allStoresGUID[id])
  end

  local locBoardObjectsPos, locBoardObjectsRot, locObjGUID = {}, {}, {}
  for _, v in ipairs(allObjectsItemGUID) do
    local locObj = getObjectFromGUID(v)

    spawnBag.putObject(locObj)

    table.insert(locBoardObjectsPos, locObj.getPosition() - self.getPosition())
    table.insert(locBoardObjectsRot, locObj.getRotation())
    Wait.time(|| table.insert(locObjGUID, locObj.getGUID()), 0.2)
  end
  Wait.time(|| SetObjMeta(spawnBag, locObjGUID, locBoardObjectsPos, locBoardObjectsRot), 0.4)
end
function CreateScriptInBag(bag)
  print("Adding scripts from bag")
  bag.setLuaScript(readyScriptUnderBag)
end
function SetObjMeta(bag, objGUID, locBoardObjectsPos, locBoardObjectsRot)
  local parametrs = {rotations = locBoardObjectsRot, positions = locBoardObjectsPos, objGUID = objGUID}
  bag.call("SetObjMetaBag", parametrs)
end

function ShowcaseMerchandise(_, _, id)
  id = StringInNumber(id)
  local storeGUID = allStoresGUID[id]
  local store = getObjectFromGUID(storeGUID)
  local allObjMeta = store.call("GetObjectMetaBag")
  -- Нет ли разложенных вещей
  if(not next(allObjectsItemGUID)) then
    local percentItemShow = StringInNumber(self.UI.getAttribute("percent"..id, "text"))
    local max = #allObjMeta
    local newMax = math.ceil(max*percentItemShow/100)
    local takeParametrs, objRot, objPos, meta = {}, {}, {}, {}
    local objGUID, newId = "", 1
    for idObj = 1, max do
      if(idObj > newMax) then goto continue end
      newId = max == newMax and idObj or math.random(1, max)
      ::stepBack::
      meta = allObjMeta[newId]
      objGUID = meta[1]
      if(getObjectFromGUID(objGUID) ~= nil) then
        newId = newId + 1 < max and newId + 1 or 1
        goto stepBack
      end

      objPos = {}
      for digital in meta[2]:gmatch("%S+") do
        table.insert(objPos, digital)
      end
      objPos = {objPos[1] + self.getPosition().x, objPos[2] + self.getPosition().y, objPos[3] + self.getPosition().z}
    
      objRot = {}
      for digital in meta[3]:gmatch("%S+") do
        table.insert(objRot, digital)
      end

      takeParametrs = {
        smooth = false,
        guid = objGUID,
        position = {x = objPos[1], y = objPos[2], z = objPos[3]},
        rotation = {x = objRot[1], y = objRot[2], z = 0},
        callback_function = ItemLeaveContainer(store, objGUID)
      }
      store.takeObject(takeParametrs)
      ::continue::
    end
  end
end

function ItemLeaveContainer(container, guid)
    Wait.time(function()
        local item = getObjectFromGUID(guid)
        local itemCost = -1
        
        if(item.getGMNotes():find("cost:")) then
            local costStr = ""
            item.getGMNotes():gsub("[^\n%.]+", function(str) if(str:find("cost:")) then costStr = str return end end)
            itemCost = StringInNumber(costStr)
        else
            local info = container.call("GetCostItem", item.getName())
            itemCost = info.itemCost
            item.setDescription(info.descObj)
        end

        if(itemCost < 0) then
            print([[{ru}Предмету не задана стоимость(либо стоимость предмета ниже нуля) После задания стоимости пересоздайте магазин, дабы цена вступила в силу{en}The item has no value set (or the value of the item is below zero) After setting the value, recreate the store so that the price takes effect.]])
        else
          item.call("CreateButton", itemCost)
        end
    end, 0.5)
end

function HidecaseMerchandise(_, _, id)
  local storeGUID = allStoresGUID[StringInNumber(id)]
  local store = getObjectFromGUID(storeGUID)
  if(store) then
    local allObjMeta = store.call("GetObjectMetaBag")
    for _, objGUID in ipairs(allObjectsItemGUID) do
      for _, objMeta in ipairs(allObjMeta) do
        if(store and objGUID == objMeta[1] and storeGUID == objMeta[4]) then
          getObjectFromGUID(objGUID).call("EndTrade")
          store.putObject(getObjectFromGUID(objMeta[1]))
        end
      end
    end
  end
  self.UI.setAttribute("discountField", "text", "")
end

function UpdateNameStore(player, input, id)
  if(player.color ~= "Black") then return end
  self.UI.setAttribute(id, "text", input)
  local detachedBag = getObjectFromGUID(allStoresGUID[StringInNumber(id)])
  if(detachedBag) then detachedBag.setName(input) end
end

function GiveDiscount(_, input)
  if(input == "") then return end

  local numInput = tonumber(input)
  if(numInput > 0) then
    broadcastToColor("{ru}Стоимость предметов была увеличена на {en}The cost of the items has been increased by "..numInput.."%", "Black")
  else
    broadcastToColor("{ru}Стоимость предметов была уменьшена на {en}The cost of the items has been decreased by "..math.abs(numInput).."%", "Black")
  end

  for _,guid in ipairs(allObjectsItemGUID) do
    local item = getObjectFromGUID(guid)
    if(item) then
      item.call("GiveDiscountItem", {discount = input})
    else
      print("Error")
    end
  end
end

function XMLReplacementAdd(storeId, storeName)
    local shopName = {
      tag = "Row",
      attributes = {
        preferredHeight = 80
      },
      children = {
        {
          tag = "Cell",
          attributes = {
          },
          children = {
            {
              tag = "InputField",
              attributes = {
                id = "storename",
                placeholder = "storename",
                text = "",
                color = "#1f1f1fda",
                textColor = "#ffffff",
                onEndEdit = "UpdateNameStore",
                tooltip = "Shop name",
                tooltipPosition = "Above",
                tooltipOffset = "90",
                tooltipWidth='180'
              }
            }
          },
        }
      }
    }
    local shopButton = {
      tag = "Row",
      attributes = {
        preferredHeight = 80
      },
      children = {
        {
          tag = "Cell",
          attributes = {
          },
          children = {
            {
              tag = "Button",
              attributes = {
                id = "up",
                text = "↑",
                onClick = "ShowcaseMerchandise"
              }
            },
            {
              tag = "Button",
              attributes = {
                id = "down",
                text = "↓",
                onClick = "HidecaseMerchandise"
              }
            },
            {
              tag = "Button",
              attributes = {
                id = "add",
                text = "+",
                onClick = "AddNewItem",
                tooltip = "Add new items to the store",
                tooltipPosition = "Right",
                tooltipOffset = "160",
                visibility = "Black"
              }
            },
            {
              tag = "Button",
              attributes = {
                id = "percent",
                text = "100%",
                onClick = "PercentageSubjects",
                tooltip = "Percentage of the number of items that will be laid out in random order",
                tooltipPosition = "Right",
                tooltipOffset = "60",
                visibility = "Black"
              }
            },
          },
        }
      }
    }

    local xmlTable = {}
    xmlTable = self.UI.getXmlTable()
    -- Ловим нужный Panel в Shop.xml
    local tableLayoutShop = xmlTable[3].children[1].children[1].children

    local id = shopName.children[1].children[1].attributes.id
    shopName.children[1].children[1].attributes.id = id..storeId
    shopName.children[1].children[1].attributes.text = storeName or ""
    table.insert(tableLayoutShop, shopName)

    for i = 1, 4 do
      local id = shopButton.children[1].children[i].attributes.id
      shopButton.children[1].children[i].attributes.id = id..storeId
    end
    table.insert(tableLayoutShop, shopButton)
    self.UI.setXmlTable(xmlTable)

    Wait.time(|| EnlargeHeightPanelStat(#allStoresGUID), 0.2)
end
function XMLReplacementDelete(storeId)
  local xmlTable = {}
  xmlTable = self.UI.getXmlTable()
  -- Ловим нужный Panel в Shop.xml
  local tableLayoutShop = xmlTable[3].children[1].children[1].children
  
  table.remove(tableLayoutShop, storeId)
  table.remove(tableLayoutShop, storeId)
  self.UI.setXmlTable(xmlTable)

  Wait.time(|| EnlargeHeightPanelStat(#allStoresGUID), 0.2)
end

function EnlargeHeightPanelStat(countStatisticIndex)
  if(countStatisticIndex > 3) then
    local cellSpacing = self.UI.getAttribute("tableLayoutShop", "cellSpacing")
    local preferredHeight = shopName.attributes.preferredHeight + shopButton.attributes.preferredHeight
    local newHeightPanel = countStatisticIndex*preferredHeight + countStatisticIndex*cellSpacing*2
    Wait.time(|| self.UI.setAttribute("tableLayoutShop", "height", newHeightPanel), 0.2)
  end
end
function StringInNumber(str)
  return tonumber(str:gsub("%D", ""), 10)
end
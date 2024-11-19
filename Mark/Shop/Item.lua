function CreateButton(buyTooltip)
    self.createButton({
        click_function = "SelectItem", function_owner = self,
        position = {0.75, 0.15, 0.75}, height = 250, width = 250,
        color = {1, 0.9, 0.9, 1}, tooltip = buyTooltip
    })
    self.createButton({
        click_function = "ClearLuaScript", function_owner = self,
        position = {-0.75, 0.15, -0.75}, height = 250, width = 250,
        color = {1, 0, 0, 0.5}, tooltip = "Удалить скрипт из данного объекта"
    })
end
function ClearLuaScript(obj, color, altClick)
    if(color == "Black") then
        Wait.time(function()
            self.setLuaScript("")
            broadcastToColor("Скрипт удален. Положите объект в мешок и вытащите, дабы изменения вступили в силу", "Black")
        end, 1)
    end
end

function onLoad()
    itemCostDiscount = nil
    thingsInBasket, countItem, itemCost = {}, 0, -1
    WebRequest.get("https://raw.githubusercontent.com/Borbold/Sugule-shop/refs/heads/main/Test1", function(request)
        if request.is_error then
            log(request.error)
        else
            local descFlag = 0
            for w in request.text:gmatch("[^\n%.]+") do
                if(descFlag == 2) then self.setDescription(w) descFlag = descFlag - 1
                elseif(descFlag == 1) then itemCost = tonumber(w) descFlag = descFlag - 1 end
                if(w == self.getName()) then descFlag = 2 end
            end
            if(itemCost < 0) then
                print("Предмету не задана стоимость(либо стоимость предмета ниже нуля)")
                print("После задания стоимости пересоздайте магазин, дабы цена вступила в силу")
            else
                Wait.time(|| CreateButton("Купить за "..itemCost), 0.4)
            end
        end
    end)
end

function GiveDiscountItem(parametrs)
    itemCostDiscount = itemCost + itemCost*parametrs.discount/100
end

function EndTrade()
    thingsInBasket, countItem = {}, 0
    itemCostDiscount, coinPouch = nil, nil
end

function SetCoinPouchGUID(parametrs)
    local coinPouchGUID = parametrs.guid
    coinPouch = getObjectFromGUID(coinPouchGUID)
end

function SelectItem(obj, playerColor, altClick)
    if(altClick and countItem > 0) then
        if(CoinPouch) then
            coinPouch.call("UpdateCountMoney", {value = itemCostDiscount or itemCost})
            broadcastToColor("Вы отказались от товара", playerColor)
            broadcastToColor("Сейчас у вас: " .. coinPouch.call("GetAvailableMoney"), playerColor)

            local delItem = thingsInBasket[countItem]
            destroyObject(delItem)
            table.remove(thingsInBasket, countItem)
            countItem = countItem - 1
        end
        return
    end
    if(coinPouch) then
        local availableMoney = coinPouch.call("GetAvailableMoney")
        if(coinPouch and itemCost <= availableMoney) then
            coinPouch.call("UpdateCountMoney", {value = -(itemCostDiscount or itemCost)})
            broadcastToColor("Вы приобрели товар", playerColor)
            broadcastToColor("У вас осталось: " .. coinPouch.call("GetAvailableMoney"), playerColor)

            SpawnNewItemObject()
        else
            broadcastToColor("Вам не хватает средств", playerColor)
        end
    else
        print("А чем расплачиваться собрались?")
    end
end
function SpawnNewItemObject()
    local selfPosition = coinPouch.getPosition()
    local spawnParametrs = {
        json = self.getJSON(),
        position = {x = selfPosition.x - 2.5, y = selfPosition.y + countItem + 2, z = selfPosition.z},
        scale = {x = 1, y = 1, z = 1},
        sound = false,
        snap_to_grid = true,
    }
    local spawnItem = spawnObjectJSON(spawnParametrs)
    spawnItem.setLuaScript("")
    table.insert(thingsInBasket, spawnItem)
    countItem = countItem + 1
end
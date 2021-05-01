﻿function UpdateSave()
  local dataToSave = {
    ["majorValue"] = majorValue, ["maxSkillPoint"] = maxSkillPoint,
    ["baffValue"] = baffValue, ["levelGUID"] = levelGUID,
    ["debaffValue"] = debaffValue,
    ["startValue"] = startValue,
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  Wait.time(function()
    Wait.time(|| Confer(savedData), 0.2)
  end, 0.5)
end

function Confer(savedData)
  RebuildAssets()
  local loadedData = JSON.decode(savedData or "")
  majorValue = loadedData.majorValue or {5, 5, 5, 5, 5, 5, 5}
  baffValue = loadedData.baffValue or {0, 0, 0, 0, 0, 0, 0}
  debaffValue = loadedData.debaffValue or {0, 0, 0, 0, 0, 0, 0}
  startValue = loadedData.startValue or {5, 5, 5, 5, 5, 5, 5}
  maxSkillPoint = loadedData.maxSkillPoint or 40
  levelGUID = loadedData.levelGUID
  ChangeUI()
  SetBasicInformation()
end
-- Базовая инфа
function InputBasicInformation(player, input, id)
  if not CheckColor(player.color) then return end

  local currentDescription = {}
  for word in self.getDescription():gmatch("%S+") do
    table.insert(currentDescription, word)
  end

  local newDescription = ""
  newDescription = newDescription .. (id:find("1") and input or currentDescription[1] or "...") .. "\n"
  newDescription = newDescription .. (id:find("2") and input or currentDescription[2] or "...") .. "\n"
  newDescription = newDescription .. (id:find("3") and input or currentDescription[3] or "...") .. "\n"
  newDescription = newDescription .. (id:find("4") and input or currentDescription[4] or "...") .. "\n"
  newDescription = newDescription .. (id:find("5") and input or currentDescription[5] or "...") .. "\n"
  newDescription = newDescription .. (id:find("6") and input or currentDescription[6] or "...") .. "\n"
  newDescription = newDescription .. (id:find("7") and input or currentDescription[7] or "...") .. "\n"
  self.setDescription(newDescription)
end
function SetBasicInformation()
  local currentDescription = {}
  for word in self.getDescription():gmatch("%S+") do
    table.insert(currentDescription, word)
  end
  for i,w in ipairs(currentDescription) do
    if #w > 0 then
      self.UI.setAttribute("info" .. i, "text", w)
    end
  end
end
-- Навыки
function Minus(player, value, id)
  id = id:lower()
  ChangeSkills(-1, id:sub(6), player.color)
end
function Plus(player, value, id)
  id = id:lower()
  ChangeSkills(1, id:sub(5), player.color)
end
function ChangeSkills(value, id, playerColor)
  if not CheckColor(playerColor) then return end

  if id:sub(0, #id - 1) == "baff" then
    id = tonumber(id:sub(5))
    baffValue[id] = baffValue[id] + value
  elseif id:sub(0, #id - 1) == "debaff" then
    id = tonumber(id:sub(7))
    debaffValue[id] = debaffValue[id] + value
  elseif id:sub(0, #id - 1) == "start" then
    id = tonumber(id:sub(6))

    local sumStartV = 0
    for _,v in ipairs(startValue) do
      sumStartV = sumStartV + v
    end
    if sumStartV + value > maxSkillPoint then return end

    startValue[id] = startValue[id] + value
  end

  for i = 1, 7 do
    majorValue[i] = baffValue[i] - debaffValue[i] + startValue[i]
  end

  ChangeUI()
end

function ChangeUI()
  local currentSkillPoint = 0
  for i = 1, 7 do
    self.UI.setAttribute("major" .. i, "text", majorValue[i])
    self.UI.setAttribute("baff" .. i, "text", baffValue[i])
    self.UI.setAttribute("debaff" .. i, "text", debaffValue[i])
    self.UI.setAttribute("start" .. i, "text", startValue[i])
    currentSkillPoint = currentSkillPoint + startValue[i]
  end
  self.UI.setAttribute("rateDevelopment", "text", majorValue[5]*2 + 5)
  self.UI.setAttribute("currentSkillPoint", "text", maxSkillPoint - currentSkillPoint)
  self.UI.setAttribute("maxSkillPoint", "text", maxSkillPoint)
  UpdateSave()
end

function ChangeMaxSkillPoint(player, input)
  if input == "" then return end
  maxSkillPoint = tonumber(input)
  ChangeUI()
end

function CheckColor(playerColor)
  if not levelGUID then SearchLevel() end
  if getObjectFromGUID(levelGUID).call("CheckPlayer", playerColor) then return true end
end
function SearchLevel()
  for _,obj in pairs(getObjects()) do
    if obj.getName() == "Level" and obj.getColorTint() == self.getColorTint() then
      levelGUID = obj.getGUID()
      return
    end
  end
end

function Reset(player)
  majorValue = {5, 5, 5, 5, 5, 5, 5}
  baffValue = {0, 0, 0, 0, 0, 0, 0}
  debaffValue = {0, 0, 0, 0, 0, 0, 0}
  startValue = {5, 5, 5, 5, 5, 5, 5}
  maxSkillPoint = 40
  for i = 1, 7 do
    InputBasicInformation(player, "...", tostring(i))
  end
  SetBasicInformation()
  ChangeUI()
end

function RebuildAssets()
  local backG = 'https://cdn.discordapp.com/attachments/800324103848198174/836970662971047986/info.png'
  local assets = {
    {name = 'uiBackGr', url = backG},
  }
  self.UI.setCustomAssets(assets)
end
﻿function UpdateSave()
  local dataToSave = {
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  Wait.time(function()
    colorPlayer = {
      ["White"] = {r = 1, g = 1, b = 1},
      ["Red"] = {r = 0.86, g = 0.1, b = 0.09},
      ["Blue"] = {r = 0.12, g = 0.53, b = 1},
      ["Green"] = {r = 0.19, g = 0.7, b = 0.17},
      ["Yellow"] = {r = 0.9, g = 0.9, b = 0.17},
      ["Orange"] = {r = 0.96, g = 0.39, b = 0.11},
      ["Brown"] = {r = 0.44, g = 0.23, b = 0.09},
      ["Purple"] = {r = 0.63, g = 0.12, b = 0.94},
      ["Pink"] = {r = 0.96, g = 0.44, b = 0.81},
      ["Teal"] = {r = 0.13, g = 0.69, b = 0.61},
      ["Black"] = {r = 0.25, g = 0.25, b = 0.25}
    }
    Wait.time(|| Confer(savedData), 0.2)
  end, 0.5)
end

function Confer(savedData)
  RebuildAssets()
  local loadedData = JSON.decode(savedData or "")
  currentLVL = loadedData and loadedData.currentLVL or 1
  currentEXP = loadedData and loadedData.currentEXP or 0
  infoGUID = loadedData.infoGUID
  maxEXP = currentLVL*50
  ChangeUI()
end
-- Уровень
function MinusLVL(player)
  ChangeLVL(-1, _, player.color)
end
function PlusLVL(player)
  ChangeLVL(1, _, player.color)
end
function ChangeLVL(value, remainingEXP, playerColor)
  if not CheckPlayer(playerColor) then return end

  currentLVL = currentLVL + value
  if currentLVL <= 0 then currentLVL = 1 end
  maxEXP = currentLVL*50
  if remainingEXP then currentEXP = remainingEXP end
  ChangeUI()
end
-- Опыт
function MinusEXP(player)
  ChangeEXP(-1, player.color)
end
function PlusEXP(player)
  ChangeEXP(1, player.color)
end
function ChangeEXP(value, playerColor)
  if not CheckPlayer(playerColor) then return end

  currentEXP = currentEXP + self.UI.getAttribute("ratioEXP", "text")*value
  if currentEXP < maxEXP and currentEXP >= 0 then
    ChangeUI()
  else
    if currentEXP < 0 then
      ChangeLVL(-1, (currentLVL - 1)*50 + currentEXP, playerColor)
    elseif currentEXP > 0 then
      ChangeLVL(1, currentEXP - maxEXP, playerColor)
    end
  end
end

function ResetInfo(player)
  if not infoGUID then SearchInfo() end
  getObjectFromGUID(infoGUID).call("Reset", player)
end
function SearchInfo()
  for _,obj in pairs(getObjects()) do
    if obj.getName() == "Info" and obj.getColorTint() == self.getColorTint() then
      infoGUID = obj.getGUID()
      return
    end
  end
end

function Reset(player)
  if CheckPlayer(player.color, true) then
    ResetInfo(player)
    currentLVL, currentEXP = 1, 0
    ChangeUI()
  end
end
function ChangeUI()
  local avarageValueEXP = currentEXP*100/maxEXP

  self.UI.setAttribute("LVL", "text", currentLVL)
  self.UI.setAttribute("EXP", "text", currentEXP .. "/" .. maxEXP)
  self.UI.setAttribute("barEXP", "percentage", avarageValueEXP)
  local newPositionFillImage = (avarageValueEXP - 100)/100*self.UI.getAttribute("barEXP", "width")
  self.UI.setAttribute("fillProgressBarImage", "offsetXY", newPositionFillImage .. " 0")
  UpdateSave()
end

function InputRatioEXP(player, input)
  if input == "" then input = "0" end
  self.UI.setAttribute("ratioEXP", "text", input)
end

function CheckPlayer(playerColor, onlyGM)
	if DenoteSth(playerColor, onlyGM) then return true end
  broadcastToColor("Не тр-рогай СвечУу-у!!! Пидор", playerColor, {1, 0.52, 0.45})
end
function DenoteSth(playerColor, onlyGM)
  if playerColor == "Black" then return true
  elseif onlyGM then return false end

  for iColor,_ in pairs(colorPlayer) do
    if CheckColor(iColor) and iColor == playerColor then
	    return true
    end
  end
end
function CheckColor(color)
  local colorObject = {
    ["R"] = Round(self.getColorTint()[1], 2),
    ["G"] = Round(self.getColorTint()[2], 2),
    ["B"] = Round(self.getColorTint()[3], 2)
  }
	if colorObject.R == colorPlayer[color].r and
     colorObject.G == colorPlayer[color].g and
     colorObject.B == colorPlayer[color].b then
    return true
  end
end
function Round(num, idp)
  return math.ceil(num*(10^idp))/10^idp
end

function RebuildAssets()
  local backG = 'https://cdn.discordapp.com/attachments/800324103848198174/837859529118449684/ozod.png'
  local lampOn = 'https://cdn.discordapp.com/attachments/800324103848198174/837859524814962738/lampon.png'
  local lampOff = 'https://cdn.discordapp.com/attachments/800324103848198174/837859531408277514/lampoff.png'

  local assets = {
    {name = 'uiBackGrou', url = backG},
    {name = 'uiLampOn', url = lampOn},
    {name = 'uiLampOff', url = lampOff},
  }
  self.UI.setCustomAssets(assets)
end
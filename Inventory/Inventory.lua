﻿function UpdateSave()
  local dataToSave = {
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
  ChangeUI()
end

function onCollisionEnter(info)
  local newObject = info.collision_object
  --destroyObject(info.collision_object)
  print(newObject.CustomImage)
  print(newObject.CustomImage.ImageURL)
  
  local cusAss = self.UI.getCustomAssets()
  table.insert(cusAss, {name = 'testICON', url = 'newObject.CustomImage.ImageURL'})
  self.UI.setCustomAssets(cusAss)
end

function ChangeUI()
  UpdateSave()
end

function RebuildAssets()
  local backG = 'https://i.imgur.com/WQiHEAd.png'
  local example1 = 'https://cdn.discordapp.com/attachments/800324103848198174/838979483075608596/moto_glasses.png'
  local example2 = 'https://cdn.discordapp.com/attachments/800324103848198174/838979481347031070/red_mask.png'
  local assets = {
    {name = 'uiBackGroundW', url = backG},
    {name = 'example1', url = example1},
    {name = 'example2', url = example2},
  }
  self.UI.setCustomAssets(assets)
end

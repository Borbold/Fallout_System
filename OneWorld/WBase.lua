--[[ l1 = nil  l3 = nil  lh = nil  u = nil

function onPickedUp()  u = self.held_by_color  l1 = nil  l3 = nil
  if math.abs(Player[u].lift_height - 0.03) > 0.005 then lh = Player[u].lift_height  end  Player[u].lift_height = 0.03
end

function onDropped()
  local x = getObjectFromGUID(Global.getVar("oW4TTale")).getPosition()
  local p = self.getPosition()  self.setPosition({p[1], x[2]+0.3, p[3]})  self.setPositionSmooth({p[1], x[2], p[3]})  l1 = p[1] l3 = p[3]
end

function onCollisionEnter()  if u and lh then Player[u].lift_height = lh  u = nil  lh = nil  end  end

function onDestroy()  if u and lh then Player[u].lift_height = lh  u = nil  lh = nil  end  end --oW_4TT ]]

-- ^^^  DO NOT ALTER OR REMOVE THESE LINES ABOVE  ^^^

o = nil

function onCollisionEnter(a)
    if not Global.getVar("oWisOn") or o == a.collision_object or o == 1 then return end
    o = a.collision_object  local ow = getObjectFromGUID(Global.getVar("oW4TTale"))
    local g = string.sub(o.getName(), 1, 4)  if g == "SET_" then g = "OWx_" end
    local i = "https://raw.githubusercontent.com/ColColonCleaner/TTSOneWorld/main/x.png"
    if self.getDescription() == "" and g == "SBx_" and o.name == "Custom_Token" then newBase()
      elseif self.getDescription() == "" and g == "OWx_" and o.name == "Bag" then doImport()
      elseif self.getDescription() != "" and o.getCustomObject().image == i then addLink()
      else
        if g == "SBx_" or g == "OWx_" then broadcastToAll("!! Clear Hub to Import !!", {0.95, 0.95, 0.95})
        else local v = ow.getVar("vBase")  local s = v.getLuaScript()  local n = string.len(s)
          while string.sub(s, n) != "@" do  s = string.sub(s, 1, n-1)  n = n-1  end
          g = o.guid  local n = string.find(s, g)  local b = ""  local q = "DO NOT PACK: "  if g then b = " ("..g..")" end
          if n then  q = "WILL PACK: "  s = string.sub(s, 1, n-1)..string.sub(s, n+7)  else  s = s..g.."@"  end
          v.setLuaScript(s)  broadcastToAll(q..a.collision_object.name..b, {0.943, 0.745, 0.14})
        end
    end
    Wait.time(|| ow.call("popWB"), 0.2)
end

function newBase()
  local ow = getObjectFromGUID(Global.getVar("oW4TTale"))  local s = ow.getVar("aBag").getLuaScript()
  if string.find(s, "-"..o.guid ..",") then broadcastToAll("Duplicate GUID.", {0.943, 0.745, 0.14})
    else ow.call("putBase", {o.guid}) end
end

function doImport()
  local ow = getObjectFromGUID(Global.getVar("oW4TTale"))
  if ow.getVar("aBag").getDescription() == "_OW_aBaG" then
    broadcastToAll("!! Can Not Import to an Empty World !!", {0.95, 0.95, 0.95})  return end
  if string.sub(o.getName(), 1, 4) == "SET_" then
    o.setDescription("")  local v = {}  v = o.getObjects()  local n = 1
    while v[n] do
      if string.sub(v[n].name, 1, 4) == "SBx_" then
        ow.setVar("currentBase", "i_"..o.guid)  o.setDescription(v[n].guid)  break
      end n = n+1
    end
    if o.getDescription() == "" then broadcastToAll("Creating Hidden Base...", {0.943, 0.745, 0.14})
      local t = {}  t.position = {-10, -45, 0}  t.callback = "cbCTBase"  t.callback_owner = self  local i = {}
      i.image = "https://raw.githubusercontent.com/ColColonCleaner/TTSOneWorld/main/table_wood.jpg"  i.thickness = 0.1
      t.type = "Custom_Token"  local o = {}  o = spawnObject(t)  o.setCustomObject(i)  return    end
  end
  broadcastToAll("Importing Art...", {0.943, 0.745, 0.14})  local t = {}  t.position = {-10, -45, 0}
  t.guid = string.sub(o.getDescription(), 1, 6)  t.callback = "preImport"
  t.callback_owner = ow  t.smooth = false  o.takeObject(t)
end
function cbCTBase(a)
  local ow = getObjectFromGUID(Global.getVar("oW4TTale"))  ow.setVar("currentBase", "c_"..o.guid)
  o.setDescription(a.guid)  a.setName("SBx_"..string.sub(o.getName(), 5))  ow.call("preImport", {a})
end

function addLink()
  local ow = getObjectFromGUID(Global.getVar("oW4TTale"))
  if ow.call("isPVw") then  o.destruct()  return end
  if o.getDescription() == self.getDescription() then
    o.destruct()  broadcastToAll("Link to Self.", {0.943, 0.745, 0.14})  return end
  local l1 = o.getVar("l1")  local l3 = o.getVar("l3")  local p = {}
  if not l1 then  p = o.getPosition()  l1 = p[1]  l3 = p[3]  end
  p = self.getPosition()  local h = 4.8  local v = 8.5
  local r1 = ow.getVar("r1")  local r3 = ow.getVar("r3")
  if p[2] < 1 then broadcastToAll("For Better Control, Raise HUB to Table.", {0.95, 0.95, 0.95})  end
  local y = math.modf((l1-p[1]+v/2)*100/v)  if y < 0 then y = 0 elseif y > 99 then y = 99 end
  local x = math.modf((l3-p[3]+h/2)*100/h)  if x < 0 then x = 0 elseif x > 99 then x = 99 end
  if r1 == 180 then x = 99 - x end  if r3 == 180 then y = 99 - y end  local n = y
  if ow.getVar("r90") == 1 then  y = 99 - x  x = n  end
  y = string.sub("0"..y, string.len(y))  x = string.sub("0"..x, string.len(x))
  ow.setVar("lnk", ow.getVar("lnk")..x..y.."@"..o.getDescription()..",")  o.destruct()  ow.call("jotBase")
  SetLinks()
end

function SetLinks()
  local rot = self.getRotation().z == 0 and 1 or -1
  local xmlTable = {
    {
      tag = "Panel",
      attributes = {
        position = "0 0 "..(-6*rot),
        width = "500",
        height = "300",
        rotation = "0 "..self.getRotation().z.." 0"
      },
      children = {}
    }
  }

  if self.getDescription() == "" then return end
  ow = getObjectFromGUID(Global.getVar("oW4TTale"))
  local r1 = ow.getVar("r1")  local r3 = ow.getVar("r3")  local t = ow.getVar("lnk")  local v, h
  if ow.getVar("r90") == 1 then h = self.getScale().x / 1.85 * 4.65  v = self.getScale().z / 1.85 * 2.63
  else v = self.getScale().z / 1.85 * 4.65  h = self.getScale().x / 1.85 * 2.63  end
  for i = 0, string.len(t)/12-1 do
    local n = i*12 + 1
    local x = (tonumber(string.sub(t, n, n + 1))*h/100 - (h/2 - 0.016))*100
    local y = ((v/2 - 0.018) - tonumber(string.sub(t, n + 2, n + 3))*v/100)*100
    local newButton = {
      tag = "Button",
      attributes = {
        id = "link"..i,
        image = "https://raw.githubusercontent.com/ColColonCleaner/TTSOneWorld/main/x.png",
        width = 20,
        height = 20,
        offsetXY = (-y*rot).." "..(x*rot),
        onClick = "ButtonLink"
      }
    }
    table.insert(xmlTable[1].children, newButton)
  end

  self.UI.setXmlTable(xmlTable)
end

function makeLink()
  local r2 = getObjectFromGUID(Global.getVar("oW4TTale")).getVar("r2")  local x = self.getPosition()
  x[1] = x[1]-(5.5 * r2)  x[2]=x[2]+2.5  local p = {}  p.type = "Custom_Token"  p.position = {x[1], x[2], x[3]}
  p.rotation = {0, 90, 0}  p.scale = {0.1, 0.1, 0.1}  p.callback = "cbMLink"  p.callback_owner = self
  local o = spawnObject(p)  local i = {}  i.thickness = 0.01
  i.image = "https://raw.githubusercontent.com/ColColonCleaner/TTSOneWorld/main/x.png"  o.setCustomObject(i)
end
function cbMLink(a)
  local ow = getObjectFromGUID(Global.getVar("oW4TTale"))  a.setDescription(ow.getVar("nl"))
  local bn = ow.call("ParceData", {ow.getVar("nl")})  a.setName(bn)  ow.setVar("nl", nil)
  local s = self.getLuaScript()  s = string.sub(s, 6, string.find(s, "oW_4TT")-4)  a.setLuaScript(s)
end

function getLink(a)
  local ow = getObjectFromGUID(Global.getVar("oW4TTale"))
  if ow.getVar("butActive") then ow.call("EditMode") return end
  local l = string.sub(ow.getVar("lnk"), a[1]*12+6, a[1]*12+11)
  local bn = string.sub(ow.call("ParceData", {l}), 1, 21)
  if bn != ow.UI.getAttribute("mTxt", "text") then ow.call("SetUIText", bn) ow.setVar("linkToMap", l) ow.call("SetUI")
  else ow.call("GetBase", {l}) end
end

function ButtonLink(_, _, id) getLink({tonumber(id:gsub("%D", ""), 10)}) end
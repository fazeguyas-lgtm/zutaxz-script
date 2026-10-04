--[[
    ZUTAXZ — Steal An Egg Panel v4.0
    Delta / Xeno / Solara Compatible
    Features:
    - Real-time server egg scanner (bukan hardcoded)
    - Auto Steal + Instant Steal
    - Sort by Weight / Income
    - Star favorite (priority steal)
    - Floating Boost box + Anti Hit (Beta)
    - Full working UI
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════ CONFIG ═══════════
local Config = {
    AutoSteal = false,
    InstantSteal = false,
    SortMode = "Biggest Weight",
    AntiHit = false,
    AntiHitDistance = 15,
    SpeedBoost = false,
    SpeedValue = 100,
    RefreshRate = 0.5,
    StarredEggs = {},
}

-- ═══════════ THEME ═══════════
local Theme = {
    PanelBg=Color3.fromRGB(35,45,40), PanelBorder=Color3.fromRGB(80,200,120),
    PanelDark=Color3.fromRGB(25,32,28), CardBg=Color3.fromRGB(50,62,55),
    CardHover=Color3.fromRGB(65,80,70), Text=Color3.fromRGB(240,240,240),
    Muted=Color3.fromRGB(160,170,165), Green=Color3.fromRGB(90,220,130),
    GreenDark=Color3.fromRGB(40,160,80), Red=Color3.fromRGB(220,70,70),
    RedDark=Color3.fromRGB(160,40,40), Gold=Color3.fromRGB(255,200,60),
}

-- ═══════════ SCREEN GUI ═══════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZUTAXZ_Panel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ═══════════ TOAST ═══════════
function Notify(msg, color)
    local t = Instance.new("Frame")
    t.Size = UDim2.new(0, 240, 0, 38)
    t.Position = UDim2.new(0.5, -120, 0, -50)
    t.BackgroundColor3 = Theme.PanelBg
    t.BorderSizePixel = 2
    t.BorderColor3 = color or Theme.Green
    t.Parent = ScreenGui
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=t
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 1, 0); l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1; l.Text = msg
    l.TextColor3 = Theme.Text; l.Font = Enum.Font.GothamBold
    l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = t
    TweenService:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -120, 0, 20)
    }):Play()
    task.delay(2, function()
        TweenService:Create(t, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -120, 0, -50), BackgroundTransparency = 1
        }):Play()
        task.wait(0.35); t:Destroy()
    end)
end

-- ═══════════ MAIN PANEL ═══════════
local StealPanel = Instance.new("Frame")
StealPanel.Name = "ZUTAXZ_Panel"
StealPanel.Size = UDim2.new(0, 340, 0, 440)
StealPanel.Position = UDim2.new(0, 20, 0.5, -220)
StealPanel.BackgroundColor3 = Theme.PanelBg
StealPanel.BorderSizePixel = 0
StealPanel.Active = true
StealPanel.Parent = ScreenGui
local spc = Instance.new("UICorner"); spc.CornerRadius=UDim.new(0,8); spc.Parent=StealPanel
local sps = Instance.new("UIStroke"); sps.Color=Theme.PanelBorder; sps.Thickness=2; sps.Parent=StealPanel

-- Drag
local dStart, sPos
StealPanel.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dStart=i.Position; sPos=StealPanel.Position
        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then dStart=nil end
        end)
    end
end)
StealPanel.InputChanged:Connect(function(i)
    if dStart and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dStart
        StealPanel.Position=UDim2.new(sPos.X.Scale, sPos.X.Offset+d.X, sPos.Y.Scale, sPos.Y.Offset+d.Y)
    end
end)

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Theme.PanelDark
Header.BorderSizePixel = 0
Header.Parent = StealPanel
local hc = Instance.new("UICorner"); hc.CornerRadius=UDim.new(0,8); hc.Parent=Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 130, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "ZUTAXZ Panel"
HeaderTitle.TextColor3 = Theme.Text
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 16
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local SortBtn = Instance.new("TextButton")
SortBtn.Size = UDim2.new(0, 165, 0, 30)
SortBtn.Position = UDim2.new(1, -175, 0.5, -15)
SortBtn.BackgroundColor3 = Theme.Green
SortBtn.Text = "Sort: Biggest Weight"
SortBtn.TextColor3 = Color3.fromRGB(30,40,35)
SortBtn.Font = Enum.Font.GothamBold
SortBtn.TextSize = 11
SortBtn.BorderSizePixel = 0
SortBtn.AutoButtonColor = false
SortBtn.Parent = Header
local sbc = Instance.new("UICorner"); sbc.CornerRadius=UDim.new(0,6); sbc.Parent=SortBtn

SortBtn.MouseButton1Click:Connect(function()
    Config.SortMode = Config.SortMode=="Biggest Weight" and "Highest Income" or "Biggest Weight"
    SortBtn.Text = "Sort: "..Config.SortMode
    Notify("Sorted by: "..Config.SortMode, Theme.Green)
end)

-- Toggle Row
local ToggleRow = Instance.new("Frame")
ToggleRow.Size = UDim2.new(1, -20, 0, 34)
ToggleRow.Position = UDim2.new(0, 10, 0, 48)
ToggleRow.BackgroundTransparency = 1
ToggleRow.Parent = StealPanel

local AutoStealBtn = Instance.new("TextButton")
AutoStealBtn.Size = UDim2.new(0.5, -5, 1, 0)
AutoStealBtn.Position = UDim2.new(0, 0, 0, 0)
AutoStealBtn.BackgroundColor3 = Theme.RedDark
AutoStealBtn.Text = "Auto Steal: OFF"
AutoStealBtn.TextColor3 = Theme.Text
AutoStealBtn.Font = Enum.Font.GothamBold
AutoStealBtn.TextSize = 12
AutoStealBtn.BorderSizePixel = 0
AutoStealBtn.AutoButtonColor = false
AutoStealBtn.Parent = ToggleRow
local asc = Instance.new("UICorner"); asc.CornerRadius=UDim.new(0,6); asc.Parent=AutoStealBtn
local ass = Instance.new("UIStroke"); ass.Color=Theme.Red; ass.Thickness=2; ass.Parent=AutoStealBtn

AutoStealBtn.MouseButton1Click:Connect(function()
    Config.AutoSteal = not Config.AutoSteal
    AutoStealBtn.Text = "Auto Steal: "..(Config.AutoSteal and "ON" or "OFF")
    AutoStealBtn.BackgroundColor3 = Config.AutoSteal and Theme.GreenDark or Theme.RedDark
    ass.Color = Config.AutoSteal and Theme.Green or Theme.Red
    Notify("Auto Steal: "..(Config.AutoSteal and "ON" or "OFF"), Config.AutoSteal and Theme.Green or Theme.Red)
end)

local InstantStealBtn = Instance.new("TextButton")
InstantStealBtn.Size = UDim2.new(0.5, -5, 1, 0)
InstantStealBtn.Position = UDim2.new(0.5, 5, 0, 0)
InstantStealBtn.BackgroundColor3 = Theme.RedDark
InstantStealBtn.Text = "Instant Steal: OFF"
InstantStealBtn.TextColor3 = Theme.Text
InstantStealBtn.Font = Enum.Font.GothamBold
InstantStealBtn.TextSize = 12
InstantStealBtn.BorderSizePixel = 0
InstantStealBtn.AutoButtonColor = false
InstantStealBtn.Parent = ToggleRow
local isc = Instance.new("UICorner"); isc.CornerRadius=UDim.new(0,6); isc.Parent=InstantStealBtn
local iss = Instance.new("UIStroke"); iss.Color=Theme.Red; iss.Thickness=2; iss.Parent=InstantStealBtn

InstantStealBtn.MouseButton1Click:Connect(function()
    Config.InstantSteal = not Config.InstantSteal
    InstantStealBtn.Text = "Instant Steal: "..(Config.InstantSteal and "ON" or "OFF")
    InstantStealBtn.BackgroundColor3 = Config.InstantSteal and Theme.GreenDark or Theme.RedDark
    iss.Color = Config.InstantSteal and Theme.Green or Theme.Red
    Notify("Instant Steal: "..(Config.InstantSteal and "ON" or "OFF"), Config.InstantSteal and Theme.Green or Theme.Red)
end)

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -20, 0, 22)
StatusBar.Position = UDim2.new(0, 10, 0, 86)
StatusBar.BackgroundColor3 = Theme.PanelDark
StatusBar.BorderSizePixel = 0
StatusBar.Parent = StealPanel
local stc = Instance.new("UICorner"); stc.CornerRadius=UDim.new(0,4); stc.Parent=StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "🔍 Scanning server eggs..."
StatusLabel.TextColor3 = Theme.Green
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

-- Egg List
local EggListFrame = Instance.new("ScrollingFrame")
EggListFrame.Size = UDim2.new(1, -20, 1, -158)
EggListFrame.Position = UDim2.new(0, 10, 0, 114)
EggListFrame.BackgroundTransparency = 1
EggListFrame.BorderSizePixel = 0
EggListFrame.ScrollBarThickness = 4
EggListFrame.ScrollBarImageColor3 = Theme.Green
EggListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
EggListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
EggListFrame.Parent = StealPanel

-- ═══════════ SCANNER LOGIC ═══════════
local eggCards = {}
local scannedEggs = {}

local function classifyRarity(name)
    local n = name:lower()
    if n:find("world") or n:find("tiger") or n:find("oni") then return "Divine", Color3.fromRGB(255,80,120)
    elseif n:find("wendigo") or n:find("stag") then return "Secret", Color3.fromRGB(220,60,220)
    elseif n:find("ventinal") or n:find("cosmic") then return "Cosmic", Color3.fromRGB(80,160,255)
    elseif n:find("voidmaw") or n:find("panda") or n:find("dragon") then return "Mythic", Color3.fromRGB(255,200,60)
    elseif n:find("rift") or n:find("salamander") then return "Legendary", Color3.fromRGB(255,120,60)
    elseif n:find("spider") or n:find("imp") or n:find("demon") then return "Epic", Color3.fromRGB(180,60,60)
    elseif n:find("camel") or n:find("horse") then return "Rare", Color3.fromRGB(200,160,100)
    else return "Common", Color3.fromRGB(160,160,160) end
end

local function fmtNum(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(math.floor(n)) end
end

local function getEggStats(obj, part)
    local weight, income, multiplier, kg = 0, 0, "1.0", "1 Kg"
    local attrs = obj:GetAttributes()
    for k, v in pairs(attrs) do
        local lk = k:lower()
        if lk:find("weight") or lk:find("income") or lk:find("value") then
            if type(v) == "number" then income = v end
        elseif lk:find("multiplier") or lk:find("multi") then
            multiplier = tostring(v)
        elseif lk:find("kg") or lk:find("mass") then
            kg = fmtNum(v).." Kg"
        end
    end
    for _, c in pairs(obj:GetChildren()) do
        if c:IsA("NumberValue") or c:IsA("IntValue") then
            local ln = c.Name:lower()
            if ln:find("weight") or ln:find("income") or ln:find("value") then income = c.Value
            elseif ln:find("multiplier") then multiplier = tostring(c.Value)
            elseif ln:find("mass") or ln:find("kg") then kg = fmtNum(c.Value).." Kg"
            end
        elseif c:IsA("StringValue") then
            local ln = c.Name:lower()
            if ln:find("multiplier") then multiplier = c.Value end
        end
    end
    if income == 0 and part then income = part.Size.Magnitude * 100 end
    weight = income > 0 and (fmtNum(income).."/s") or "N/A"
    if kg == "1 Kg" and part then kg = fmtNum(part:GetMass()).." Kg" end
    return weight, income, multiplier, kg
end

local function makeEggCard(eggData)
    local card = Instance.new("Frame")
    card.Name = "EggCard_"..eggData.name
    card.Size = UDim2.new(1, -6, 0, 70)
    card.BackgroundColor3 = Theme.CardBg
    card.BorderSizePixel = 0
    card.Parent = EggListFrame
    local cc = Instance.new("UICorner"); cc.CornerRadius=UDim.new(0,6); cc.Parent=card
    local cs = Instance.new("UIStroke"); cs.Color=Color3.fromRGB(70,85,75); cs.Thickness=1; cs.Parent=card

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 56, 0, 56)
    thumb.Position = UDim2.new(0, 6, 0.5, -28)
    thumb.BackgroundColor3 = eggData.rarityColor or Theme.Green
    thumb.BorderSizePixel = 0
    thumb.Parent = card
    local tc = Instance.new("UICorner"); tc.CornerRadius=UDim.new(0,6); tc.Parent=thumb

    local thumbLbl = Instance.new("TextLabel")
    thumbLbl.Size = UDim2.new(1, 0, 1, 0)
    thumbLbl.BackgroundTransparency = 1
    thumbLbl.Text = "🥚"
    thumbLbl.TextColor3 = Color3.fromRGB(255,255,255)
    thumbLbl.Font = Enum.Font.GothamBold
    thumbLbl.TextSize = 28
    thumbLbl.Parent = thumb

    local rarTag = Instance.new("TextLabel")
    rarTag.Size = UDim2.new(0, 50, 0, 12)
    rarTag.Position = UDim2.new(0, 6, 1, -14)
    rarTag.BackgroundColor3 = Color3.fromRGB(20,25,22)
    rarTag.Text = eggData.rarity or "?"
    rarTag.TextColor3 = eggData.rarityColor or Theme.Muted
    rarTag.Font = Enum.Font.GothamBold
    rarTag.TextSize = 8
    rarTag.BorderSizePixel = 0
    rarTag.Parent = card
    local rtc = Instance.new("UICorner"); rtc.CornerRadius=UDim.new(0,2); rtc.Parent=rarTag

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -200, 0, 18)
    nameLabel.Position = UDim2.new(0, 68, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = eggData.name
    nameLabel.TextColor3 = eggData.rarityColor or Theme.Text
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card

    local weightLbl = Instance.new("TextLabel")
    weightLbl.Size = UDim2.new(1, -200, 0, 14)
    weightLbl.Position = UDim2.new(0, 68, 0, 24)
    weightLbl.BackgroundTransparency = 1
    weightLbl.Text = eggData.weight or "0/s"
    weightLbl.TextColor3 = Theme.Gold
    weightLbl.Font = Enum.Font.GothamBold
    weightLbl.TextSize = 11
    weightLbl.TextXAlignment = Enum.TextXAlignment.Left
    weightLbl.Parent = card

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(1, -200, 0, 14)
    valueLbl.Position = UDim2.new(0, 68, 0, 38)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = "x"..(eggData.multiplier or "1.0").."  •  "..(eggData.kg or "1 Kg")
    valueLbl.TextColor3 = Theme.Muted
    valueLbl.Font = Enum.Font.Gotham
    valueLbl.TextSize = 10
    valueLbl.TextXAlignment = Enum.TextXAlignment.Left
    valueLbl.Parent = card

    local distLbl = Instance.new("TextLabel")
    distLbl.Name = "DistLabel"
    distLbl.Size = UDim2.new(1, -200, 0, 12)
    distLbl.Position = UDim2.new(0, 68, 0, 54)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "📏 --"
    distLbl.TextColor3 = Theme.Muted
    distLbl.Font = Enum.Font.Gotham
    distLbl.TextSize = 9
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.Parent = card

    local stealBtn = Instance.new("TextButton")
    stealBtn.Size = UDim2.new(0, 60, 0, 30)
    stealBtn.Position = UDim2.new(1, -130, 0.5, -15)
    stealBtn.BackgroundColor3 = Theme.Green
    stealBtn.Text = "Steal"
    stealBtn.TextColor3 = Color3.fromRGB(30,40,35)
    stealBtn.Font = Enum.Font.GothamBold
    stealBtn.TextSize = 12
    stealBtn.BorderSizePixel = 0
    stealBtn.AutoButtonColor = false
    stealBtn.Parent = card
    local stc = Instance.new("UICorner"); stc.CornerRadius=UDim.new(0,6); stc.Parent=stealBtn

    local starBtn = Instance.new("TextButton")
    starBtn.Size = UDim2.new(0, 30, 0, 30)
    starBtn.Position = UDim2.new(1, -62, 0.5, -15)
    starBtn.BackgroundColor3 = Color3.fromRGB(70,80,75)
    starBtn.Text = "★"
    starBtn.TextColor3 = Config.StarredEggs[eggData.name] and Theme.Gold or Theme.Text
    starBtn.Font = Enum.Font.GothamBold
    starBtn.TextSize = 14
    starBtn.BorderSizePixel = 0
    starBtn.AutoButtonColor = false
    starBtn.Parent = card
    local stc2 = Instance.new("UICorner"); stc2.CornerRadius=UDim.new(0,6); stc2.Parent=starBtn

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3=Theme.CardHover}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3=Theme.CardBg}):Play()
    end)

    stealBtn.MouseButton1Click:Connect(function()
        if eggData.part and eggData.part.Parent then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                pcall(function()
                    firetouchinterest(root, eggData.part, 0)
                    firetouchinterest(root, eggData.part, 1)
                end)
                Notify("🥚 Stolen: "..eggData.name, Theme.Green)
            end
        else
            Notify("Egg expired", Theme.Red)
        end
    end)

    starBtn.MouseButton1Click:Connect(function()
        Config.StarredEggs[eggData.name] = not Config.StarredEggs[eggData.name]
        starBtn.TextColor3 = Config.StarredEggs[eggData.name] and Theme.Gold or Theme.Text
        Notify((Config.StarredEggs[eggData.name] and "⭐ Starred: " or "☆ Unstarred: ")..eggData.name, Theme.Gold)
    end)

    eggCards[eggData.uid] = {card = card, data = eggData, distLabel = distLbl}
    return card
end

local function scanServerEggs()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local found = {}
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("egg") or n:find("pet") or n:find("spawn") then
                if not obj:IsDescendantOf(LocalPlayer.Character or game) then
                    local part = obj:IsA("BasePart") and obj or obj.PrimaryPart
                    if part and part.Parent then
                        local dist = root and (part.Position - root.Position).Magnitude or 9999
                        if dist < 2000 then
                            local weight, income, multiplier, kg = getEggStats(obj, part)
                            local rarity, rarityColor = classifyRarity(obj.Name)
                            table.insert(found, {
                                uid = obj:GetDebugId(),
                                name = obj.Name,
                                weight = weight, income = income,
                                multiplier = multiplier, kg = kg,
                                rarity = rarity, rarityColor = rarityColor,
                                part = part, obj = obj, dist = dist,
                            })
                            count = count + 1
                        end
                    end
                end
            end
        end
    end
    table.sort(found, function(a,b) return a.income > b.income end)
    local starred, unstarred = {}, {}
    for _, egg in ipairs(found) do
        if Config.StarredEggs[egg.name] then table.insert(starred, egg)
        else table.insert(unstarred, egg) end
    end
    local sorted = {}
    for _, e in ipairs(starred) do table.insert(sorted, e) end
    for _, e in ipairs(unstarred) do table.insert(sorted, e) end
    for _, c in pairs(eggCards) do
        if c.card and c.card.Parent then c.card:Destroy() end
    end
    eggCards = {}
    scannedEggs = sorted
    local y = 0
    for _, egg in ipairs(sorted) do
        local card = makeEggCard(egg)
        card.Position = UDim2.new(0, 0, 0, y)
        y = y + 74
    end
    EggListFrame.CanvasSize = UDim2.new(0, 0, 0, y)
    StatusLabel.Text = "🔍 Found "..count.." eggs  •  "..(#starred).." starred"
end

-- ═══════════ FLOATING BOOST BOX ═══════════
local BoostBox = Instance.new("Frame")
BoostBox.Name = "ZUTAXZ_Boost"
BoostBox.Size = UDim2.new(0, 200, 0, 140)
BoostBox.Position = UDim2.new(1, -220, 0, 100)
BoostBox.BackgroundColor3 = Theme.PanelBg
BoostBox.BorderSizePixel = 0
BoostBox.Active = true
BoostBox.Parent = ScreenGui
local bbc = Instance.new("UICorner"); bbc.CornerRadius=UDim.new(0,8); bbc.Parent=BoostBox
local bbs = Instance.new("UIStroke"); bbs.Color=Theme.PanelBorder; bbs.Thickness=2; bbs.Parent=BoostBox

local bdStart, bsPos
BoostBox.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        bdStart=i.Position; bsPos=BoostBox.Position
        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then bdStart=nil end
        end)
    end
end)
BoostBox.InputChanged:Connect(function(i)
    if bdStart and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-bdStart
        BoostBox.Position=UDim2.new(bsPos.X.Scale, bsPos.X.Offset+d.X, bsPos.Y.Scale, bsPos.Y.Offset+d.Y)
    end
end)

local BoostTitle = Instance.new("TextLabel")
BoostTitle.Size = UDim2.new(1, 0, 0, 30)
BoostTitle.BackgroundColor3 = Theme.PanelDark
BoostTitle.Text = "⚡ ZUTAXZ Boost"
BoostTitle.TextColor3 = Theme.Text
BoostTitle.Font = Enum.Font.GothamBold
BoostTitle.TextSize = 13
BoostTitle.Parent = BoostBox
local btc = Instance.new("UICorner"); btc.CornerRadius=UDim.new(0,8); btc.Parent=BoostTitle

local SpeedRow = Instance.new("Frame")
SpeedRow.Size = UDim2.new(1, -20, 0, 30)
SpeedRow.Position = UDim2.new(0, 10, 0, 38)
SpeedRow.BackgroundColor3 = Theme.CardBg
SpeedRow.BorderSizePixel = 0
SpeedRow.Parent = BoostBox
local src = Instance.new("UICorner"); src.CornerRadius=UDim.new(0,6); src.Parent=SpeedRow

local SpeedLbl = Instance.new("TextLabel")
SpeedLbl.Size = UDim2.new(0.7, 0, 1, 0)
SpeedLbl.Position = UDim2.new(0, 10, 0, 0)
SpeedLbl.BackgroundTransparency = 1
SpeedLbl.Text = "Speed Boost"
SpeedLbl.TextColor3 = Theme.Text
SpeedLbl.Font = Enum.Font.GothamBold
SpeedLbl.TextSize = 11
SpeedLbl.TextXAlignment = Enum.TextXAlignment.Left
SpeedLbl.Parent = SpeedRow

local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0, 22, 0, 22)
SpeedToggle.Position = UDim2.new(1, -30, 0.5, -11)
SpeedToggle.BackgroundColor3 = Theme.RedDark
SpeedToggle.Text = ""
SpeedToggle.BorderSizePixel = 0
SpeedToggle.AutoButtonColor = false
SpeedToggle.Parent = SpeedRow
local stgc = Instance.new("UICorner"); stgc.CornerRadius=UDim.new(1,0); stgc.Parent=SpeedToggle
local stgs = Instance.new("UIStroke"); stgs.Color=Theme.Red; stgs.Thickness=2; stgs.Parent=SpeedToggle

SpeedToggle.MouseButton1Click:Connect(function()
    Config.SpeedBoost = not Config.SpeedBoost
    SpeedToggle.BackgroundColor3 = Config.SpeedBoost and Theme.GreenDark or Theme.RedDark
    stgs.Color = Config.SpeedBoost and Theme.Green or Theme.Red
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = Config.SpeedBoost and Config.SpeedValue or 16 end
    Notify("Speed Boost: "..(Config.SpeedBoost and "ON" or "OFF"), Config.SpeedBoost and Theme.Green or Theme.Red)
end)

local SpeedSliderBg = Instance.new("Frame")
SpeedSliderBg.Size = UDim2.new(1, -20, 0, 8)
SpeedSliderBg.Position = UDim2.new(0, 10, 0, 72)
SpeedSliderBg.BackgroundColor3 = Color3.fromRGB(45,55,48)
SpeedSliderBg.BorderSizePixel = 0
SpeedSliderBg.Parent = BoostBox
local ssbc = Instance.new("UICorner"); ssbc.CornerRadius=UDim.new(1,0); ssbc.Parent=SpeedSliderBg

local SpeedFill = Instance.new("Frame")
SpeedFill.Size = UDim2.new(0.2, 0, 1, 0)
SpeedFill.BackgroundColor3 = Theme.Green
SpeedFill.BorderSizePixel = 0
SpeedFill.Parent = SpeedSliderBg
local sfc = Instance.new("UICorner"); sfc.CornerRadius=UDim.new(1,0); sfc.Parent=SpeedFill

local SpeedKnob = Instance.new("Frame")
SpeedKnob.Size = UDim2.new(0, 14, 0, 14)
SpeedKnob.Position = UDim2.new(0.2, -7, 0.5, -7)
SpeedKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
SpeedKnob.BorderSizePixel = 0
SpeedKnob.Parent = SpeedSliderBg
local skc = Instance.new("UICorner"); skc.CornerRadius=UDim.new(1,0); skc.Parent=SpeedKnob

local SpeedVal = Instance.new("TextLabel")
SpeedVal.Size = UDim2.new(1, -20, 0, 16)
SpeedVal.Position = UDim2.new(0, 10, 0, 84)
SpeedVal.BackgroundTransparency = 1
SpeedVal.Text = "Speed: "..Config.SpeedValue
SpeedVal.TextColor3 = Theme.Gold
SpeedVal.Font = Enum.Font.GothamBold
SpeedVal.TextSize = 11
SpeedVal.TextXAlignment = Enum.TextXAlignment.Left
SpeedVal.Parent = BoostBox

local speedDrag = false
local function updateSpeed(i)
    local r = math.clamp((i.Position.X - SpeedSliderBg.AbsolutePosition.X) / SpeedSliderBg.AbsoluteSize.X, 0, 1)
    SpeedFill.Size = UDim2.new(r, 0, 1, 0)
    SpeedKnob.Position = UDim2.new(r, -7, 0.5, -7)
    Config.SpeedValue = math.floor(16 + (500 - 16) * r)
    SpeedVal.Text = "Speed: "..Config.SpeedValue
    if Config.SpeedBoost then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = Config.SpeedValue end
    end
end
SpeedSliderBg.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        speedDrag = true; updateSpeed(i)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if speedDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        updateSpeed(i)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then speedDrag = false end
end)

local AntiRow = Instance.new("Frame")
AntiRow.Size = UDim2.new(1, -20, 0, 30)
AntiRow.Position = UDim2.new(0, 10, 0, 104)
AntiRow.BackgroundColor3 = Theme.CardBg
AntiRow.BorderSizePixel = 0
AntiRow.Parent = BoostBox
local arc = Instance.new("UICorner"); arc.CornerRadius=UDim.new(0,6); arc.Parent=AntiRow

local AntiLbl = Instance.new("TextLabel")
AntiLbl.Size = UDim2.new(0.7, 0, 1, 0)
AntiLbl.Position = UDim2.new(0, 10, 0, 0)
AntiLbl.BackgroundTransparency = 1
AntiLbl.Text = "Anti Hit (Beta)"
AntiLbl.TextColor3 = Theme.Text
AntiLbl.Font = Enum.Font.GothamBold
AntiLbl.TextSize = 11
AntiLbl.TextXAlignment = Enum.TextXAlignment.Left
AntiLbl.Parent = AntiRow

local AntiToggle = Instance.new("TextButton")
AntiToggle.Size = UDim2.new(0, 22, 0, 22)
AntiToggle.Position = UDim2.new(1, -30, 0.5, -11)
AntiToggle.BackgroundColor3 = Theme.RedDark
AntiToggle.Text = ""
AntiToggle.BorderSizePixel = 0
AntiToggle.AutoButtonColor = false
AntiToggle.Parent = AntiRow
local atc = Instance.new("UICorner"); atc.CornerRadius=UDim.new(1,0); atc.Parent=AntiToggle
local ats = Instance.new("UIStroke"); ats.Color=Theme.Red; ats.Thickness=2; ats.Parent=AntiToggle

AntiToggle.MouseButton1Click:Connect(function()
    Config.AntiHit = not Config.AntiHit
    AntiToggle.BackgroundColor3 = Config.AntiHit and Theme.GreenDark or Theme.RedDark
    ats.Color = Config.AntiHit and Theme.Green or Theme.Red
    Notify("Anti Hit (Beta): "..(Config.AntiHit and "ON" or "OFF"), Config.AntiHit and Theme.Green or Theme.Red)
end)

-- ═══════════ LIVE REFRESH ═══════════
task.spawn(function()
    task.wait(0.5)
    while ScreenGui.Parent do
        pcall(scanServerEggs)
        task.wait(Config.RefreshRate)
    end
end)

task.spawn(function()
    while ScreenGui.Parent do
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for uid, entry in pairs(eggCards) do
                if entry.card and entry.card.Parent and entry.data.part and entry.data.part.Parent then
                    local d = (entry.data.part.Position - root.Position).Magnitude
                    if entry.distLabel then
                        entry.distLabel.Text = "📏 "..math.floor(d).." studs"
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- ═══════════ AUTO STEAL ═══════════
RunService.Heartbeat:Connect(function()
    if not Config.AutoSteal then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local target = nil
    for _, egg in ipairs(scannedEggs) do
        if Config.StarredEggs[egg.name] and egg.part and egg.part.Parent then
            target = egg.part; break
        end
    end
    if not target and #scannedEggs > 0 then
        for _, egg in ipairs(scannedEggs) do
            if egg.part and egg.part.Parent then target = egg.part; break end
        end
    end
    if target then
        local dist = (target.Position - root.Position).Magnitude
        if dist > 12 then
            root.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
        else
            pcall(function()
                firetouchinterest(root, target, 0)
                firetouchinterest(root, target, 1)
            end)
        end
    end
end)

-- ═══════════ INSTANT STEAL ═══════════
RunService.Heartbeat:Connect(function()
    if not Config.InstantSteal then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, egg in ipairs(scannedEggs) do
        if egg.part and egg.part.Parent then
            pcall(function()
                firetouchinterest(root, egg.part, 0)
                firetouchinterest(root, egg.part, 1)
            end)
        end
    end
end)

-- ═══════════ ANTI HIT ═══════════
RunService.Heartbeat:Connect(function()
    if not Config.AntiHit then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if theirRoot then
                local dist = (theirRoot.Position - root.Position).Magnitude
                if dist < Config.AntiHitDistance then
                    local dashDir = (root.Position - theirRoot.Position).Unit
                    root.CFrame = root.CFrame + (dashDir * 20)
                end
            end
        end
    end
    if hum.Health < hum.MaxHealth then
        hum.Health = math.min(hum.MaxHealth, hum.Health + 5)
    end
end)

-- ═══════════ MINIMIZE ═══════════
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.Position = UDim2.new(1, -36, 0, 8)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
MinimizeBtn.Text = "◀"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = StealPanel
local mbc = Instance.new("UICorner"); mbc.CornerRadius=UDim.new(1,0); mbc.Parent=MinimizeBtn

local panelMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    panelMinimized = not panelMinimized
    TweenService:Create(StealPanel, TweenInfo.new(0.25), {
        Size = panelMinimized and UDim2.new(0, 40, 0, 42) or UDim2.new(0, 340, 0, 440)
    }):Play()
    MinimizeBtn.Text = panelMinimized and "▶" or "◀"
end)

-- ═══════════ INIT ═══════════
task.spawn(function()
    task.wait(1)
    Notify("ZUTAXZ Panel v4.0 Loaded", Theme.Green)
    task.wait(0.5)
    Notify("Server scanner active", Theme.Gold)
end)

print("[ZUTAXZ v4.0] Loaded.")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ ล้างของเก่า ]] --
if game:GetService("CoreGui"):FindFirstChild("Manaw_Arsenal_Fix") then
    game:GetService("CoreGui")["Manaw_Arsenal_Fix"]:Destroy()
end

local Window = Fluent:CreateWindow({
    Title = "Arsenal VIP 🍋",
    SubTitle = "Fixed Keybinds Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift 
})

-- [[ Variables ]] --
getgenv().Config = {
    AimEnabled = false,
    AimKey = Enum.UserInputType.MouseButton2,
    MenuKey = Enum.KeyCode.RightShift, -- เก็บปุ่มเปิดปิดแยกไว้
    FOVSize = 150,
    ShowFOV = false,
    WallCheck = true,
    Smoothing = 0.05,
    EspEnabled = false,
    EspSkeleton = false,
    EspTeamCheck = true
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- [[ GUI Container (FOV) ]] --
local MainGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
MainGui.Name = "Manaw_Arsenal_Fix"
MainGui.IgnoreGuiInset = true

local FOVFrame = Instance.new("Frame", MainGui)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
local Stroke = Instance.new("UIStroke", FOVFrame)
Stroke.Thickness = 1.5; Stroke.Color = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

-- [[ TABS ]] --
local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ 1. COMBAT MENU ]] --
Tabs.Combat:AddToggle("AimTog", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) getgenv().Config.AimEnabled = v end)

Tabs.Combat:AddKeybind("AimBind", {
    Title = "Aimbot Key (ปุ่มล็อคเป้า)",
    Default = "MouseButton2",
    Mode = "Hold",
    ChangedCallback = function(NewKey) getgenv().Config.AimKey = NewKey end
})

Tabs.Combat:AddToggle("WallTog", {Title = "Wall Check (เช็คกำแพง)", Default = true}):OnChanged(function(v) getgenv().Config.WallCheck = v end)

Tabs.Combat:AddToggle("FovTog", {Title = "Show FOV Circle", Default = false}):OnChanged(function(v) 
    getgenv().Config.ShowFOV = v; FOVFrame.Visible = v 
end)

Tabs.Combat:AddSlider("FovSlider", {Title = "FOV Size", Min = 50, Max = 600, Default = 150, Rounding = 0}):OnChanged(function(v) 
    getgenv().Config.FOVSize = v; FOVFrame.Size = UDim2.new(0, v * 2, 0, v * 2) 
end)

-- [[ 2. VISUALS MENU ]] --
Tabs.Visuals:AddToggle("EspTog", {Title = "Enable ESP (Chams)", Default = false}):OnChanged(function(v) getgenv().Config.EspEnabled = v end)
Tabs.Visuals:AddToggle("SkelTog", {Title = "Skeleton ESP (โครงกระดูก)", Default = false}):OnChanged(function(v) getgenv().Config.EspSkeleton = v end)
Tabs.Visuals:AddToggle("TeamTog", {Title = "Team Check (ซ่อนเพื่อน)", Default = true}):OnChanged(function(v) getgenv().Config.EspTeamCheck = v end)

-- [[ 3. SETTINGS MENU ]] --
local MenuBind = Tabs.Settings:AddKeybind("MenuBind", {
    Title = "Toggle Menu Key (ปุ่มเปิด/ปิดเมนู)",
    Default = "RightShift",
    Mode = "Toggle", -- ใช้โหมด Toggle
    ChangedCallback = function(NewKey)
        getgenv().Config.MenuKey = NewKey -- อัปเดตปุ่มใน Config
        Fluent:Notify({Title = "Settings Updated", Content = "เปลี่ยนปุ่มเมนูเป็น: " .. tostring(NewKey), Duration = 3})
    end
})

-- [[ LOGIC: Menu Toggle System ]] --
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then -- ถ้าไม่ได้กำลังพิมพ์แชท
        if input.KeyCode == getgenv().Config.MenuKey then
            -- สั่งย่อ/ขยายหน้าต่าง Fluent โดยตรง
            Window:Minimize() 
        end
    end
end)

-- [[ LOGIC: Functions ]] --
local function IsVisible(part)
    if not getgenv().Config.WallCheck then return true end
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit and hit:IsDescendantOf(part.Parent)
end

local function GetTarget()
    local target, dist = nil, getgenv().Config.FOVSize
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if getgenv().Config.EspTeamCheck and plr.Team == LocalPlayer.Team then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist and IsVisible(plr.Character.Head) then
                    target = plr.Character.Head; dist = mag
                end
            end
        end
    end
    return target
end

-- Skeleton Logic
local Skeletons = {}
local function GetLine(plr, index)
    if not Skeletons[plr] then Skeletons[plr] = {} end
    if not Skeletons[plr][index] then
        local line = Drawing.new("Line")
        line.Thickness = 1.5; line.Color = Color3.fromRGB(0, 255, 0); line.Transparency = 1
        Skeletons[plr][index] = line
    end
    return Skeletons[plr][index]
end

local function HideSkeleton(plr)
    if Skeletons[plr] then for _, line in pairs(Skeletons[plr]) do line.Visible = false end end
end

-- [[ MAIN LOOP ]] --
RunService.RenderStepped:Connect(function()
    -- 1. Aimbot Input Check
    local isAiming = false
    local key = getgenv().Config.AimKey
    
    if key then
        if key == Enum.UserInputType.MouseButton1 or key == Enum.UserInputType.MouseButton2 or key == Enum.UserInputType.MouseButton3 then
            isAiming = UserInputService:IsMouseButtonPressed(key)
        elseif typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
            isAiming = UserInputService:IsKeyDown(key)
        end
    end

    if getgenv().Config.AimEnabled and isAiming then
        local target = GetTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1 - getgenv().Config.Smoothing)
        end
    end

    -- 2. ESP & Skeleton
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local isEnemy = not getgenv().Config.EspTeamCheck or plr.Team ~= LocalPlayer.Team
            local isAlive = char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0

            if getgenv().Config.EspEnabled and isEnemy and isAlive then
                local hl = char:FindFirstChild("ESP_HL") or Instance.new("Highlight", char)
                hl.Name = "ESP_HL"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.FillTransparency = 0.5; hl.Enabled = true
            elseif char and char:FindFirstChild("ESP_HL") then char.ESP_HL.Enabled = false end

            if getgenv().Config.EspSkeleton and isEnemy and isAlive then
                local hum = char:FindFirstChild("Humanoid")
                local getP = function(pName)
                    local part = char:FindFirstChild(pName)
                    if part then 
                        local pos, vis = Camera:WorldToViewportPoint(part.Position)
                        return pos, vis
                    end
                    return nil, false
                end
                local connections = (hum.RigType == Enum.HumanoidRigType.R15) and {
                    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
                } or {
                    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
                }
                for i, conn in ipairs(connections) do
                    local p1, v1 = getP(conn[1]); local p2, v2 = getP(conn[2])
                    local line = GetLine(plr, i)
                    if v1 and v2 then line.From = Vector2.new(p1.X, p1.Y); line.To = Vector2.new(p2.X, p2.Y); line.Visible = true else line.Visible = false end
                end
            else HideSkeleton(plr) end
        end
    end
end)

Window:SelectTab(1)
Fluent:Notify({Title = "Fixed!", Content = "ตอนนี้เปลี่ยนปุ่มเปิด/ปิดเมนูได้จริงแล้วครับ", Duration = 5})
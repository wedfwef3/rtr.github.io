local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Remote = game:GetService("ReplicatedStorage").RemoteEvents.RequestTakeDiamonds
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

local a, b, c, d, e, totalDiamondsLabel, roundDiamondsLabel, infoLabel
local chest, proxPrompt
local startTime

local function rainbowStroke(stroke)
    task.spawn(function()
        while task.wait() do
            for hue = 0, 1, 0.01 do
                stroke.Color = Color3.fromHSV(hue, 1, 1)
                task.wait(0.02)
            end
        end
    end)
end

local function hopServer()
    local gameId = game.PlaceId
    while true do
        local success, body = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
        end)
        if success then
            local data = HttpService:JSONDecode(body)
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    while true do
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

task.spawn(function()
    while task.wait(1) do
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char:FindFirstChild("Humanoid").DisplayName == LocalPlayer.DisplayName then
                    hopServer()
                end
            end
        end
    end
end)

a = Instance.new("ScreenGui")
a.Name = "DiamondFarmUI"
a.ResetOnSpawn = false
a.Parent = game.CoreGui

b = Instance.new("Frame", a)
b.Size = UDim2.new(0, 400, 0, 260)
b.Position = UDim2.new(0.5, -200, 0.5, -130)
b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
b.BorderSizePixel = 0
b.Active = true
b.Draggable = true

c = Instance.new("UICorner", b)
c.CornerRadius = UDim.new(0, 16)

d = Instance.new("UIStroke", b)
d.Thickness = 2
rainbowStroke(d)

e = Instance.new("TextLabel", b)
e.Size = UDim2.new(1, 0, 0, 50)
e.Position = UDim2.new(0, 0, 0, 0)
e.BackgroundTransparency = 1
e.Text = "Farm Diamonds | ringta"
e.TextColor3 = Color3.fromRGB(255, 255, 255)
e.Font = Enum.Font.GothamBold
e.TextSize = 28
e.TextStrokeTransparency = 0.6

totalDiamondsLabel = Instance.new("TextLabel", b)
totalDiamondsLabel.Size = UDim2.new(1, -40, 0, 40)
totalDiamondsLabel.Position = UDim2.new(0, 20, 0, 60)
totalDiamondsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
totalDiamondsLabel.TextColor3 = Color3.new(1, 1, 1)
totalDiamondsLabel.Font = Enum.Font.GothamBold
totalDiamondsLabel.TextSize = 22
totalDiamondsLabel.BorderSizePixel = 0
totalDiamondsLabel.Text = "Total Diamonds: ..."
local totalCorner = Instance.new("UICorner", totalDiamondsLabel)
totalCorner.CornerRadius = UDim.new(0, 10)

roundDiamondsLabel = Instance.new("TextLabel", b)
roundDiamondsLabel.Size = UDim2.new(1, -40, 0, 36)
roundDiamondsLabel.Position = UDim2.new(0, 20, 0, 104)
roundDiamondsLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
roundDiamondsLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
roundDiamondsLabel.Font = Enum.Font.GothamBold
roundDiamondsLabel.TextSize = 20
roundDiamondsLabel.BorderSizePixel = 0
roundDiamondsLabel.Text = "Diamonds gained this round: ..."
local roundCorner = Instance.new("UICorner", roundDiamondsLabel)
roundCorner.CornerRadius = UDim.new(0, 10)

infoLabel = Instance.new("TextLabel", b)
infoLabel.Size = UDim2.new(1, -40, 0, 50)
infoLabel.Position = UDim2.new(0, 20, 0, 150)
infoLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
infoLabel.BackgroundTransparency = 0.3
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 20
infoLabel.Text = "Waiting for diamond chest..."
infoLabel.BorderSizePixel = 0
local infoCorner = Instance.new("UICorner", infoLabel)
infoCorner.CornerRadius = UDim.new(0, 12)

local prevDiamondCount = tonumber(DiamondCount.Text) or 0
local roundDiamonds = 0
local roundActive = false

task.spawn(function()
    while task.wait(0.2) do
        local currentDiamondCount = tonumber(DiamondCount.Text) or 0
        totalDiamondsLabel.Text = "Total Diamonds: " .. currentDiamondCount
        if roundActive then
            roundDiamondsLabel.Text = "Diamonds gained this round: " .. (currentDiamondCount - prevDiamondCount)
        else
            roundDiamondsLabel.Text = "Diamonds gained this round: 0"
        end
    end
end)

local function updateInfo(text)
    infoLabel.Text = text
end

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
if not chest then
    updateInfo("Chest not found (my fault), hopping server...")
    roundActive = false
    hopServer()
    return
end

updateInfo("Teleporting to chest...")
LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position))

repeat
    task.wait(0.1)
    local prox = chest:FindFirstChild("Main")
    if prox and prox:FindFirstChild("ProximityAttachment") then
        proxPrompt = prox.ProximityAttachment:FindFirstChild("ProximityInteraction")
    end
until proxPrompt

updateInfo("Trying to open stronghold chest...")

startTime = tick()
local chestOpened = false
while proxPrompt and proxPrompt.Parent and (tick() - startTime) < 10 do
    local beforeDiamonds = tonumber(DiamondCount.Text) or 0
    pcall(function()
        fireproximityprompt(proxPrompt)
    end)
    task.wait(0.2)
    local afterDiamonds = tonumber(DiamondCount.Text) or 0
    if afterDiamonds > beforeDiamonds then
        chestOpened = true
        break
    end
end

if not chestOpened then
    updateInfo("Couldn't open stronghold chest, hopping server...")
    roundActive = false
    hopServer()
    return
end

updateInfo("Searching for diamonds in workspace...")
roundActive = true
prevDiamondCount = tonumber(DiamondCount.Text) or 0

repeat task.wait(0.1) until workspace:FindFirstChild("Diamond", true)

local diamondsFound = 0
for _, v in pairs(workspace:GetDescendants()) do
    if v.ClassName == "Model" and v.Name == "Diamond" then
        Remote:FireServer(v)
        diamondsFound = diamondsFound + 1
    end
end

updateInfo("Took all diamonds (" .. diamondsFound .. "), hopping server...")

task.wait(1)
hopServer()

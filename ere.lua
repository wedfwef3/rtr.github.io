local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Remote = game:GetService("ReplicatedStorage").RemoteEvents.RequestTakeDiamonds
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")

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
    if getgenv and getgenv().queue_on_teleport and getgenv().src then
        queue_on_teleport(getgenv().src)
    end
    while true do
        local success, body = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
        end)
        if success then
            local data = HttpService:JSONDecode(body)
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                    return
                end
            end
        end
        task.wait(0.2)
    end
end

local function main()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DiamondFarmUI"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 400, 0, 260)
    frame.Position = UDim2.new(0.5, -200, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    rainbowStroke(stroke)

    local header = Instance.new("TextLabel", frame)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.Text = "Farm Diamonds | ringta"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 28
    header.TextStrokeTransparency = 0.6

    local totalDiamondsLabel = Instance.new("TextLabel", frame)
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

    local roundDiamondsLabel = Instance.new("TextLabel", frame)
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

    local infoLabel = Instance.new("TextLabel", frame)
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

    local function updateInfo(text)
        infoLabel.Text = text
    end

    local prevDiamondCount = tonumber(DiamondCount.Text) or 0
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

    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    local chest = workspace:FindFirstChild("Items") and workspace.Items:FindFirstChild("Stronghold Diamond Chest")
    if not chest then
        updateInfo("Chest not found, hopping server...")
        roundActive = false
        hopServer()
        return
    end

    updateInfo("Teleporting to chest...")
    LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position))

    local proxPrompt
    repeat
        task.wait(0.1)
        local prox = chest:FindFirstChild("Main")
        if prox and prox:FindFirstChild("ProximityAttachment") then
            proxPrompt = prox.ProximityAttachment:FindFirstChild("ProximityInteraction")
        end
    until proxPrompt

    updateInfo("Trying to open stronghold chest...")
    local startTime = tick()
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
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == "Diamond" then
            Remote:FireServer(v)
            diamondsFound = diamondsFound + 1
        end
    end

    updateInfo("Took all diamonds (" .. diamondsFound .. "), hopping server...")
    task.wait(1)
    hopServer()
end

if getgenv then
    getgenv().src = [=[
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Remote = game:GetService("ReplicatedStorage").RemoteEvents.RequestTakeDiamonds
local Interface = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface")
local DiamondCount = Interface:WaitForChild("DiamondCount"):WaitForChild("Count")
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
    if getgenv and getgenv().queue_on_teleport and getgenv().src then
        queue_on_teleport(getgenv().src)
    end
    while true do
        local success, body = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(gameId))
        end)
        if success then
            local data = HttpService:JSONDecode(body)
            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(gameId, server.id, LocalPlayer)
                    return
                end
            end
        end
        task.wait(0.2)
    end
end
local function main()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DiamondFarmUI"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 400, 0, 260)
    frame.Position = UDim2.new(0.5, -200, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2
    rainbowStroke(stroke)
    local header = Instance.new("TextLabel", frame)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.Text = "Farm Diamonds | ringta"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 28
    header.TextStrokeTransparency = 0.6
    local totalDiamondsLabel = Instance.new("TextLabel", frame)
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
    local roundDiamondsLabel = Instance.new("TextLabel", frame)
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
    local infoLabel = Instance.new("TextLabel", frame)
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
    local function updateInfo(text)
        infoLabel.Text = text
    end
    local prevDiamondCount = tonumber(DiamondCount.Text) or 0
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
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local chest = workspace:FindFirstChild("Items") and workspace.Items:FindFirstChild("Stronghold Diamond Chest")
    if not chest then
        updateInfo("Chest not found, hopping server...")
        roundActive = false
        hopServer()
        return
    end
    updateInfo("Teleporting to chest...")
    LocalPlayer.Character:PivotTo(CFrame.new(chest:GetPivot().Position))
    local proxPrompt
    repeat
        task.wait(0.1)
        local prox = chest:FindFirstChild("Main")
        if prox and prox:FindFirstChild("ProximityAttachment") then
            proxPrompt = prox.ProximityAttachment:FindFirstChild("ProximityInteraction")
        end
    until proxPrompt
    updateInfo("Trying to open stronghold chest...")
    local startTime = tick()
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
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == "Diamond" then
            Remote:FireServer(v)
            diamondsFound = diamondsFound + 1
        end
    end
    updateInfo("Took all diamonds (" .. diamondsFound .. "), hopping server...")
    task.wait(1)
    hopServer()
end
if getgenv then
    getgenv().src = [=[--[[ RECURSIVE --]]]=]..getgenv().src
end
task.spawn(function()
    while task.wait(1) do
        for _, char in ipairs(workspace:FindFirstChild("Characters") and workspace.Characters:GetChildren() or {}) do
            if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                    hopServer()
                end
            end
        end
    end
end)
main()
]=]
end

task.spawn(function()
    while task.wait(1) do
        for _, char in ipairs(workspace:FindFirstChild("Characters") and workspace.Characters:GetChildren() or {}) do
            if char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char.Humanoid.DisplayName == LocalPlayer.DisplayName then
                    hopServer()
                end
            end
        end
    end
end)

main()

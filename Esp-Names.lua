-- Settings
local EspNames = true  -- Toggle for ESP

-- Function to handle ESP Names
local function espNames(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local textLabel = Drawing.new("Text")
    textLabel.Visible = false
    textLabel.Center = true
    textLabel.Outline = true
    textLabel.Font = 2
    textLabel.Color = Color3.fromRGB(255, 255, 255)
    textLabel.Size = 13

    local connections = {}

    local function cleanup()
        textLabel.Visible = false
        textLabel:Remove()
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
        connections = {}
    end

    table.insert(connections, character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
        end
    end))

    table.insert(connections, humanoid.HealthChanged:Connect(function(health)
        if health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
            cleanup()
        end
    end))

    table.insert(connections, game:GetService("RunService").RenderStepped:Connect(function()
        if EspNames then
            local hrpPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
            if onScreen then
                textLabel.Position = Vector2.new(hrpPosition.X, hrpPosition.Y)
                textLabel.Text = player.Name
                textLabel.Visible = true
            else
                textLabel.Visible = false
            end
        else
            textLabel.Visible = false
        end
    end))
end

local function playerAdded(player)
    player.CharacterAdded:Connect(function(character)
        espNames(player, character)
    end)
    
    if player.Character then
        espNames(player, player.Character)
    end
end

-- Connect to existing players
for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
    if player ~= game:GetService("Players").LocalPlayer then
        playerAdded(player)
    end
end

-- Connect to new players
game:GetService("Players").PlayerAdded:Connect(playerAdded)
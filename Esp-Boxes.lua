local lplr = game.Players.LocalPlayer 
local camera = game:GetService("Workspace").CurrentCamera
local worldToViewportPoint = camera.worldToViewportPoint

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 3, 0)

local function createBoxESP(v)
    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Color = Color3.new(0, 0, 0)
    BoxOutline.Thickness = 3
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 1, 1)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    return BoxOutline, Box
end

local function updateBoxESP(BoxOutline, Box, character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")

    if humanoidRootPart and head then
        local rootPosition, onScreen = camera:worldToViewportPoint(humanoidRootPart.Position)
        local headPosition = camera:worldToViewportPoint(head.Position + HeadOff)
        local legPosition = camera:worldToViewportPoint(humanoidRootPart.Position - LegOff)

        if onScreen then
            local distanceFactor = 1000 / rootPosition.Z
            local boxWidth = distanceFactor + 20  -- Base width adjustment

            -- Adjust the width based on distance
            if rootPosition.Z > 50 then  -- Change this threshold as needed
                boxWidth = boxWidth * (50 / rootPosition.Z)
            end

            BoxOutline.Size = Vector2.new(boxWidth, headPosition.Y - legPosition.Y)
            BoxOutline.Position = Vector2.new(rootPosition.X - BoxOutline.Size.X / 2, rootPosition.Y - BoxOutline.Size.Y / 2)
            BoxOutline.Visible = true

            Box.Size = Vector2.new(boxWidth, headPosition.Y - legPosition.Y)
            Box.Position = Vector2.new(rootPosition.X - Box.Size.X / 2, rootPosition.Y - Box.Size.Y / 2)
            Box.Visible = true

            if character:FindFirstChild("Humanoid") and character.Humanoid.Health <= 0 then
                BoxOutline.Visible = false
                Box.Visible = false
            end
        else
            BoxOutline.Visible = false
            Box.Visible = false
        end
    else
        BoxOutline.Visible = false
        Box.Visible = false
    end
end

for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= lplr then
        local BoxOutline, Box = createBoxESP(player)
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character then
                updateBoxESP(BoxOutline, Box, player.Character)
            else
                BoxOutline.Visible = false
                Box.Visible = false
            end
        end)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    local BoxOutline, Box = createBoxESP(player)
    game:GetService("RunService").RenderStepped:Connect(function()
        if player.Character then
            updateBoxESP(BoxOutline, Box, player.Character)
        else
            BoxOutline.Visible = false
            Box.Visible = false
        end
    end)
end)
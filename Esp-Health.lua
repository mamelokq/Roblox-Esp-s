local lplr = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local worldToViewportPoint = camera.worldToViewportPoint

_G.TeamCheck = false -- Toggle TeamCheck to True or False
local EspHealth = true -- Track if ESP Health is enabled

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 3, 0)

-- Function to create ESP elements
local function CreateESPElements()
    local BoxOutline = Drawing.new("Square")
    BoxOutline.Color = Color3.new(0, 0, 0)
    BoxOutline.Thickness = 3
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false
    BoxOutline.Visible = false

    local Box = Drawing.new("Square")
    Box.Color = Color3.new(1, 1, 1)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    Box.Visible = false

    local HealthBarOutline = Drawing.new("Square")
    HealthBarOutline.Thickness = 3
    HealthBarOutline.Filled = false
    HealthBarOutline.Color = Color3.new(0, 0, 0)
    HealthBarOutline.Transparency = 1
    HealthBarOutline.Visible = false

    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = false
    HealthBar.Transparency = 1
    HealthBar.Visible = false

    return BoxOutline, Box, HealthBarOutline, HealthBar
end

-- Function to update ESP elements
local function UpdateESP(v, BoxOutline, Box, HealthBarOutline, HealthBar)
    game:GetService("RunService").RenderStepped:Connect(function()
        if EspHealth and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v ~= lplr and v.Character.Humanoid.Health > 0 then
            local Vector, onScreen = camera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)

            local RootPart = v.Character.HumanoidRootPart
            local Head = v.Character.Head
            local RootPosition = worldToViewportPoint(camera, RootPart.Position)
            local HeadPosition = worldToViewportPoint(camera, Head.Position + HeadOff)
            local LegPosition = worldToViewportPoint(camera, RootPart.Position - LegOff)

            if onScreen then
                BoxOutline.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                BoxOutline.Position = Vector2.new(RootPosition.X - BoxOutline.Size.X / 2, RootPosition.Y - BoxOutline.Size.Y / 2)
                BoxOutline.Visible = true

                Box.Size = Vector2.new(1000 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                Box.Visible = true

                HealthBarOutline.Size = Vector2.new(2, HeadPosition.Y - LegPosition.Y)
                HealthBarOutline.Position = BoxOutline.Position - Vector2.new(6, 0)
                HealthBarOutline.Visible = true

                local maxHealth = v.Character:FindFirstChild("Humanoid").MaxHealth
                local health = v.Character:FindFirstChild("Humanoid").Health
                HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) * (health / maxHealth))
                HealthBar.Position = Vector2.new(Box.Position.X - 6, Box.Position.Y + (1 / HealthBar.Size.Y))
                HealthBar.Color = Color3.fromRGB(255 - 255 * (health / maxHealth), 255 * (health / maxHealth), 0)
                HealthBar.Visible = true

                if v.TeamColor == lplr.TeamColor and _G.TeamCheck then
                    BoxOutline.Visible = false
                    Box.Visible = false
                    HealthBarOutline.Visible = false
                    HealthBar.Visible = false
                else
                    BoxOutline.Visible = true
                    Box.Visible = true
                    HealthBarOutline.Visible = true
                    HealthBar.Visible = true
                end
            else
                BoxOutline.Visible = false
                Box.Visible = false
                HealthBarOutline.Visible = false
                HealthBar.Visible = false
            end
        else
            BoxOutline.Visible = false
            Box.Visible = false
            HealthBarOutline.Visible = false
            HealthBar.Visible = false
        end
    end)
end

-- Create ESP elements for existing players
for _, v in pairs(game.Players:GetPlayers()) do
    if v ~= lplr then
        local BoxOutline, Box, HealthBarOutline, HealthBar = CreateESPElements()
        coroutine.wrap(function() UpdateESP(v, BoxOutline, Box, HealthBarOutline, HealthBar) end)()
    end
end

-- Handle new players
game.Players.PlayerAdded:Connect(function(v)
    if v ~= lplr then
        local BoxOutline, Box, HealthBarOutline, HealthBar = CreateESPElements()
        coroutine.wrap(function() UpdateESP(v, BoxOutline, Box, HealthBarOutline, HealthBar) end)()
    end
end)
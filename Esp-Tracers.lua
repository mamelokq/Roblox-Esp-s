local lplr = game.Players.LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local worldToViewportPoint = camera.worldToViewportPoint

_G.TeamCheck = false -- Toggle TeamCheck to True or False

local function createTracerForPlayer(player)
    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.new(1, 1, 1) -- Tracer color
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    local function updateTracer()
        game:GetService("RunService").RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player ~= lplr and player.Character.Humanoid.Health > 0 then
                local Vector, OnScreen = camera:worldToViewportPoint(player.Character.HumanoidRootPart.Position)

                if OnScreen then
                    Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y) -- From center of screen
                    Tracer.To = Vector2.new(Vector.X, Vector.Y)

                    if _G.TeamCheck and player.TeamColor == lplr.TeamColor then
                        Tracer.Visible = false -- Hide tracer for teammates
                    else
                        Tracer.Visible = true -- Show tracer for enemies
                    end
                else
                    Tracer.Visible = false -- Hide if not on screen
                end
            else
                Tracer.Visible = false -- Hide if player is dead or not valid
            end
        end)
    end

    coroutine.wrap(updateTracer)() -- Start the tracer update coroutine
end

-- Create tracers for existing players
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= lplr then
        createTracerForPlayer(player)
    end
end

-- Create tracers for new players
game.Players.PlayerAdded:Connect(function(player)
    if player ~= lplr then
        createTracerForPlayer(player)
    end
end)
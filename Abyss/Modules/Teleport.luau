-- Written 18/02/2026, Teleporting.. pls no skid 🙏

local TeleportModule = {
    Misc = {
        LocalPlayer = nil,
        TweenService = game:GetService("TweenService")
    }
}

function TeleportModule.Setup(LocalPlayer)
    TeleportModule.Misc.LocalPlayer = LocalPlayer
end

function TeleportModule.TeleportVector3(Position, Time)
    local Character = TeleportModule.Misc.LocalPlayer.Character
    if not Character then return end

    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end

    local TweenInfoObject = TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local Tween = TeleportModule.Misc.TweenService:Create(HumanoidRootPart, TweenInfoObject, {
        CFrame = CFrame.new(Position)
    })

    Tween:Play()
    Tween.Completed:Wait()
end

return TeleportModule

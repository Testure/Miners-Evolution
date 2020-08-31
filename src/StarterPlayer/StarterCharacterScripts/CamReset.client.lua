local Human = script.Parent:WaitForChild("Humanoid")
workspace.CurrentCamera.FieldOfView = 70
workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
workspace.CurrentCamera.CameraSubject = Human
game.Lighting.Blur.Size = 0

local P = Human.Parent.HumanoidRootPart

workspace.CurrentCamera.CFrame = CFrame.new(P.Position,P.Position + Vector3.new(15,0,15))
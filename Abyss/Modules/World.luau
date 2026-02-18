-- Written 18/02/2026, World module for less clutter, Niggas deadass gon skid this 🥀

local WorldModule = {
	Misc = {
		FishModule = nil,
		Workspace = nil,
		ReplicatedStorage = nil,

		Fish = nil,
		Debris = nil
	},
	PlayerCharacters = {},
	LoadedFish = {},
	Teleports = {} -- TODO, TELELPORT POSITIONS FOR NOTABLE POI
}

local function FindFishConfigByName(FishName)
	local FishModule = WorldModule.Misc.FishModule
	if type(FishModule) ~= "table" or type(FishName) ~= "string" then
		return nil
	end

	return FishModule[FishName]
end

local function AddOrUpdateFish(Entry)
	for _, Item in ipairs(WorldModule.LoadedFish) do
		if Item.ID == Entry.ID then
			Item.Name = Entry.Name
			Item.Health = Entry.Health
			Item.Rarity = Entry.Rarity
			Item.BasePrice = Entry.BasePrice
			return
		end
	end

	table.insert(WorldModule.LoadedFish, Entry)
end

local function RemoveLoadedFishById(Id)
	for i = #WorldModule.LoadedFish, 1, -1 do
		if WorldModule.LoadedFish[i].ID == Id then
			table.remove(WorldModule.LoadedFish, i)
			break
		end
	end
end

local function AddFishItem(Child)
	if not Child:IsA("Model") then
		return
	end

	if #Child.Name >= 10 then -- Temp filter so random models dont get in
		return
	end

	local Head = Child:FindFirstChild("Head")
	if not Head then
		return
	end

	local Stats = Head:FindFirstChild("stats")
	if not Stats then
		return
	end

	local FishText = Stats:FindFirstChild("Fish")
	if not FishText or type(FishText.Text) ~= "string" then
		return
	end

	local FishName = FishText.Text
	local FishConfig = FindFishConfigByName(FishName)

	local HealthValue = nil
	local HealthNode = Stats:FindFirstChild("Health")
	if HealthNode then
		local AmountNode = HealthNode:FindFirstChild("Amount")
		if AmountNode and type(AmountNode.Text) == "string" then
			HealthValue = tonumber(AmountNode.Text:match("^(%d+)")) -- Getting the health from UI text for now 🙏
		end
	end

	if HealthValue == nil and FishConfig and FishConfig.config then
		HealthValue = tonumber(FishConfig.config.health)
	end

	local RarityValue = nil
	local BasePriceValue = nil

	if FishConfig then
		RarityValue = FishConfig.rarity
		if FishConfig.config then
			BasePriceValue = FishConfig.config.basevalue
		end
	end

	AddOrUpdateFish({
		ID = Child.Name,
		Name = FishName,
		Health = HealthValue,
		Rarity = RarityValue,
		BasePrice = BasePriceValue
	})
end

local function RemoveFishItem(Child)
	if not Child:IsA("Model") then
		return
	end

	RemoveLoadedFishById(Child.Name)
end

local function GetPlayerFromCharacter(Character)
	local Players = game:GetService("Players")
	return Players:GetPlayerFromCharacter(Character)
end

local function AddOrUpdatePlayer(Character)
	for _, Entry in ipairs(WorldModule.PlayerCharacters) do
		if Entry.Character == Character then
			Entry.Player = GetPlayerFromCharacter(Character)
			Entry.Name = Character.Name
			return
		end
	end

	table.insert(WorldModule.PlayerCharacters, {
		Character = Character,
		Player = GetPlayerFromCharacter(Character),
		Name = Character.Name
	})
end

local function RemovePlayerCharacter(Character)
	for i = #WorldModule.PlayerCharacters, 1, -1 do
		if WorldModule.PlayerCharacters[i].Character == Character then
			table.remove(WorldModule.PlayerCharacters, i)
			break
		end
	end
end

local function TrackDebrisModel(Child)
	if not Child:IsA("Model") then
		return
	end

	if Child:FindFirstChildOfClass("Humanoid") == nil then
		return
	end

	local Player = GetPlayerFromCharacter(Child)
	if Player == nil then
		return
	end

	AddOrUpdatePlayer(Child)
end

local function UntrackDebrisModel(Child)
	if not Child:IsA("Model") then
		return
	end

	RemovePlayerCharacter(Child)
end

local function RefreshPlayerCharacters()
	for i = #WorldModule.PlayerCharacters, 1, -1 do
		local Entry = WorldModule.PlayerCharacters[i]
		if Entry.Character == nil or Entry.Character.Parent == nil then
			table.remove(WorldModule.PlayerCharacters, i)
		else
			local Player = GetPlayerFromCharacter(Entry.Character)
			if Player == nil then
				table.remove(WorldModule.PlayerCharacters, i)
			else
				Entry.Player = Player
				Entry.Name = Entry.Character.Name
			end
		end
	end
end

function WorldModule.Setup(Workspace, ReplicatedStorage, FishModule)
	WorldModule.Misc.FishModule = FishModule
	WorldModule.Misc.Workspace = Workspace
	WorldModule.Misc.ReplicatedStorage = ReplicatedStorage

	local Game = Workspace:WaitForChild("Game")
	local Fish = Game:WaitForChild("Fish"):WaitForChild("client")

	local Debris = Workspace:WaitForChild("debris")

	WorldModule.Misc.Fish = Fish
	WorldModule.Misc.Debris = Debris
end

function WorldModule.HookWorld()
	task.spawn(function()
		for _, Child in ipairs(WorldModule.Misc.Fish:GetChildren()) do
			AddFishItem(Child)
		end

		WorldModule.Misc.Fish.ChildAdded:Connect(AddFishItem)
		WorldModule.Misc.Fish.ChildRemoved:Connect(RemoveFishItem)

		for _, Child in ipairs(WorldModule.Misc.Debris:GetChildren()) do
			TrackDebrisModel(Child)
		end

		WorldModule.Misc.Debris.ChildAdded:Connect(TrackDebrisModel)
		WorldModule.Misc.Debris.ChildRemoved:Connect(UntrackDebrisModel)

		game:GetService("Players").PlayerRemoving:Connect(function()
			RefreshPlayerCharacters() -- Clean up so we dont keep random left/dead players in da table
		end)

		warn("[ KODAK ] - World Module Setup!")
	end)
end

return WorldModule



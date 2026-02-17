-- Written 17/02/2026, Inventory module for simple access. (Main script too cluttered)

local InventoryModule = {
	Misc = {
		LocalPlayer = nil,
		Backpack = nil,
		HotbarGui = nil,
	},
	Hotbar = {},
}

local function IsStrictNumberName(Name)
	return type(Name) == "string" and Name:match("^%d+$") ~= nil
end

local function AddHotbarItem(Child)
	if not IsStrictNumberName(Child.Name) then
		return
	end

	local IndexNumber = tonumber(Child.Name)
	if not IndexNumber then
		return
	end

	for _, Item in ipairs(InventoryModule.Hotbar) do
		if Item.Index == IndexNumber then
			Item.Class = Child:GetAttribute("class")
			Item.Quantity = Child:GetAttribute("amount")
			Item.Name = Child:GetAttribute("name")
			Item.ID = Child:GetAttribute("id")
			Item.Rating = Child:GetAttribute("stars")
			Item.Weight = Child:GetAttribute("weight")
			return
		end
	end

	table.insert(InventoryModule.Hotbar, {
		Index = IndexNumber,
		Class = Child:GetAttribute("class"),
		Quantity = Child:GetAttribute("amount"),
		Name = Child:GetAttribute("name"),
		ID = Child:GetAttribute("id"),
		Rating = Child:GetAttribute("stars"),
		Weight = Child:GetAttribute("weight"),
	})
end

local function RemoveHotbarItem(Child)
	if not IsStrictNumberName(Child.Name) then
		return
	end

	local IndexNumber = tonumber(Child.Name)
	if not IndexNumber then
		return
	end

	for i = #InventoryModule.Hotbar, 1, -1 do
		if InventoryModule.Hotbar[i].Index == IndexNumber then
			table.remove(InventoryModule.Hotbar, i)
			break
		end
	end
end

function InventoryModule.Setup(LocalPlayer)
	InventoryModule.Misc.LocalPlayer = LocalPlayer

	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local Main = PlayerGui:WaitForChild("Main")
	local Backpack = Main:WaitForChild("Backpack")
	local HotbarGui = Backpack:WaitForChild("Hotbar")

	InventoryModule.Misc.Backpack = Backpack
	InventoryModule.Misc.HotbarGui = HotbarGui
end

function InventoryModule.HookHotbar()
	task.spawn(function()
		for _, Child in ipairs(InventoryModule.Misc.HotbarGui:GetChildren()) do
			AddHotbarItem(Child)
		end

		InventoryModule.Misc.HotbarGui.ChildAdded:Connect(AddHotbarItem)
		InventoryModule.Misc.HotbarGui.ChildRemoved:Connect(RemoveHotbarItem)

		warn("[ KODAK ] - Inventory Module Setup!")
	end)
end

return InventoryModule

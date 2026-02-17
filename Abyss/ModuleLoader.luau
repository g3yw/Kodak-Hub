-- Written 17/02/2026, Universal script to load all modules in Modules folder.

local Modules = {"Inventory"} -- Put module name w/o the .luau here when u add it to the Modules folder.
local LoadedMods = {}

local function LoadModule(Path)
  local LoadstringRes = loadstring(game:HttpGet("https://raw.githubusercontent.com/g3yw/Kodak-Hub/refs/heads/main/Abyss/Modules/"..Path..".luau"))
  if not LoadstringRes then
    return nil
  end
  print(LoadstringRes)

  local Success, Res = pcall(LoadstringRes)
  if Success then
    print(Res)
    return Res
  end

  return nil
end

for _, Mod in pairs(Modules) do
  local LoadedModule = LoadModule(Mod)
  if LoadedModule ~= nil then
    LoadedMods[Mod] = LoadedModule
  end
end

task.wait(1)

return LoadedMods

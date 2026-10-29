AddCSLuaFile("swz_printer/sh_config.lua")
AddCSLuaFile("swz_printer/sh_loader.lua")
include("swz_printer/sh_config.lua")
include("swz_printer/sh_loader.lua")

local cfg = SWZPrinter.Config

if SERVER then util.AddNetworkString("SWZPrinter_Act") end

for _, t in ipairs(cfg.Tiers) do
    scripted_ents.Register({
        Type = "anim",
        Base = "swz_printer",
        Tier = t.id,
        PrintName = t.name .. " Printer",
        Category = cfg.Category,
        Spawnable = true,
        AdminOnly = cfg.AdminOnlySpawn,
    }, "swz_printer_" .. t.id)
end

hook.Add("loadCustomDarkRPItems", "SWZPrinter", function()
    if not cfg.Shop.Enabled then return end
    for _, t in ipairs(cfg.Tiers) do
        local data = {
            ent = "swz_printer_" .. t.id,
            model = SWZPrinter.GetModel(),
            price = t.price,
            max = t.limit,
            cmd = cfg.Shop.CommandPrefix .. t.id,
        }
        for k, v in pairs(cfg.Shop.Extra) do data[k] = v end
        for k, v in pairs(t.shop or {}) do data[k] = v end
        DarkRP.createEntity(t.name .. " Printer", data)
    end
end)

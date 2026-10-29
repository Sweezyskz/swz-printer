local cfg = SWZPrinter.Config

SWZPrinter.Version = "1.0"
SWZPrinter.Credits = {
    author = "undefined.boy",
    github = "https://github.com/Sweezyskz",
    portfolio = "https://sweezy.asoso485576.workers.dev/",
}

local TXT, DIM, OK, WARN, ACC = Color(238, 241, 247), Color(128, 138, 156), Color(74, 214, 130), Color(255, 176, 56), Color(110, 200, 255)
local BRONZE, SILVER, GOLD = Color(205, 127, 80), Color(190, 199, 214), Color(240, 190, 60)

local LETTERS = {
    {BRONZE, {" ##### ", "##     ", " ####  ", "     ##", "##   ##", " ##### "}},
    {SILVER, {"##   ##", "##   ##", "## # ##", "## # ##", "#######", " ## ## "}},
    {GOLD,   {"#######", "    ## ", "   ##  ", "  ##   ", " ##    ", "#######"}},
}

local RULE = string.rep("=", 58)

local function Header()
    MsgC("\n", DIM, "  " .. RULE .. "\n\n")
    for row = 1, 6 do
        MsgC("    ")
        for _, l in ipairs(LETTERS) do MsgC(l[1], l[2][row], "   ") end
        MsgC("\n")
    end
    MsgC("\n", ACC, "    P R I N T E R", DIM, "   money printers for DarkRP   v" .. SWZPrinter.Version .. "\n\n")
end

local function Footer(warnings)
    local c = SWZPrinter.Credits
    MsgC("\n")
    MsgC(DIM, "    version     ", TXT, "v" .. SWZPrinter.Version, "\n")
    MsgC(DIM, "    created by  ", TXT, c.author, "\n")
    MsgC(DIM, "    github      ", ACC, c.github, "\n")
    MsgC(DIM, "    portfolio   ", ACC, c.portfolio, "\n\n")
    MsgC(warnings > 0 and WARN or OK, warnings > 0 and ("    loaded with " .. warnings .. " warning(s)") or "    ready", DIM, "  (" .. (SERVER and "server" or "client") .. ")\n")
    MsgC(DIM, "\n  " .. RULE .. "\n\n")
end

local STEPS = {
    {"config", function() return true, #cfg.Tiers .. " tiers, " .. #cfg.Modes .. " modes" end},
    {"printers", function()
        local names = {}
        for _, t in ipairs(cfg.Tiers) do names[#names + 1] = t.name end
        return true, table.concat(names, ", ")
    end},
    {"model", function()
        local ok = file.Exists(cfg.Model, "GAME")
        return ok, ok and cfg.Model or ("not found, using " .. cfg.FallbackModel)
    end},
    {"darkrp", function()
        local ok = DarkRP ~= nil
        return ok, ok and "detected" or "not detected"
    end},
    {"shop", function() return cfg.Shop.Enabled, cfg.Shop.Enabled and "F4 enabled (/" .. cfg.Shop.CommandPrefix .. "<tier>)" or "disabled" end},
}

local function Run(i, warnings)
    local step = STEPS[i]
    if not step then return Footer(warnings) end
    local ok, info = step[2]()
    MsgC(DIM, "    [", ACC, "SWZ", DIM, "] ", TXT, string.format("%-9s", step[1]), ok and OK or WARN, ok and "OK    " or "WARN  ", DIM, info, "\n")
    timer.Simple(0.2, function() Run(i + 1, warnings + (ok and 0 or 1)) end)
end

hook.Add("InitPostEntity", "SWZPrinterLoader", function()
    timer.Simple(1.5, function()
        Header()
        Run(1, 0)
    end)
end)

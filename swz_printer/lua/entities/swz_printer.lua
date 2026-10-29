AddCSLuaFile()
include("swz_printer/sh_config.lua")

local cfg = SWZPrinter.Config
local L = cfg.Lang

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Printer"
ENT.Category = cfg.Category
ENT.Spawnable = false
ENT.IsSWZPrinter = true
ENT.Tier = cfg.Tiers[1].id

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Int", 0, "Money")
    self:NetworkVar("Int", 1, "Temp")
    self:NetworkVar("Float", 0, "Battery")
    self:NetworkVar("Bool", 0, "Power")
    self:NetworkVar("Int", 2, "Mode")
    self:NetworkVar("Int", 3, "Total")
    self:NetworkVar("Int", 4, "Hp")
end

function ENT:Cfg() return SWZPrinter.Tier[self.Tier] end

local function money(n) return cfg.Currency .. string.Comma(math.floor(n)) end

if SERVER then
    local function note(ply, ok, text)
        if DarkRP and DarkRP.notify then DarkRP.notify(ply, ok and 0 or 1, 4, text) else ply:ChatPrint(text) end
    end

    function ENT:Initialize()
        self:SetModel(SWZPrinter.GetModel())
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end
        self.IsMoneyPrinter = true
        self.SeizeReward = cfg.SeizeReward
        self.damage = cfg.Health
        self.m, self.total = 0, 0
        self:SetPower(cfg.StartPowered)
        self:SetMode(math.Clamp(cfg.DefaultMode, 1, #cfg.Modes))
        self:SetHp(100)
        self:SetBattery(100)
        self:SetTemp(cfg.AmbientTemp)
        if cfg.Sounds.Loop ~= "" then
            self.snd = CreateSound(self, cfg.Sounds.Loop)
            self.snd:SetSoundLevel(cfg.Sounds.LoopLevel)
        end
        self:NextThink(CurTime() + 1)
    end

    function ENT:Think()
        local c = self:Cfg()
        local mode = cfg.Modes[self:GetMode()] or cfg.Modes[1]
        local running = self:GetPower() and self:GetBattery() > 0 and self.m < c.max and self:WaterLevel() == 0
        if running then
            local gain = math.min(c.max - self.m, c.rate * mode.rate / 60)
            self.m = self.m + gain
            self.total = self.total + gain
            self:SetBattery(math.max(0, self:GetBattery() - c.drain * mode.drain / 60))
        end
        self:SetMoney(math.floor(self.m))
        self:SetTotal(math.floor(self.total))
        local target = running and (c.heat + mode.heat) or cfg.AmbientTemp
        self:SetTemp(math.Round(self:GetTemp() + (target - self:GetTemp()) * cfg.HeatSpeed))
        if self.snd then
            if running then self.snd:PlayEx(1, 100) else self.snd:Stop() end
        end
        if cfg.DestroyInWater and self:WaterLevel() > 0 then self:Destruct() end
        self:NextThink(CurTime() + 1)
        return true
    end

    function ENT:Destruct()
        if self.dead then return end
        self.dead = true
        if cfg.ExplosionOnDestroy then
            local fx = EffectData()
            fx:SetStart(self:GetPos()) fx:SetOrigin(self:GetPos()) fx:SetScale(1)
            util.Effect("Explosion", fx)
        end
        if cfg.DropMoneyOnDestroy and self.m >= 1 and DarkRP and DarkRP.createMoneyBag then
            DarkRP.createMoneyBag(self:GetPos() + Vector(0, 0, 15), math.floor(self.m))
        end
        local o = self:Getowning_ent()
        if IsValid(o) then note(o, false, string.format(L.Destroyed, self:Cfg().name)) end
        self:Remove()
    end

    function ENT:OnTakeDamage(dmg)
        self.damage = self.damage - dmg:GetDamage()
        self:SetHp(math.Clamp(math.floor(self.damage / cfg.Health * 100), 0, 100))
        if self.damage <= 0 then self:Destruct() end
    end

    function ENT:OnRemove()
        if self.snd then self.snd:Stop() end
    end

    local function isOwner(ply, ent)
        local o = ent:Getowning_ent()
        return not IsValid(o) or o == ply or (cfg.AdminBypass and ply:IsAdmin())
    end

    local ACT = {}
    ACT[1] = function(ply, ent)
        if cfg.OwnerOnlyWithdraw and not isOwner(ply, ent) then return note(ply, false, L.OwnerOnly) end
        local amount = math.floor(ent.m)
        if amount < 1 then return note(ply, false, L.NothingToWithdraw) end
        ent.m = 0
        ent:SetMoney(0)
        ply:addMoney(amount)
        note(ply, true, string.format(L.Withdrawn, money(amount)))
    end
    ACT[2] = function(ply, ent)
        if cfg.OwnerOnlyRecharge and not isOwner(ply, ent) then return note(ply, false, L.OwnerOnly) end
        local missing = 100 - ent:GetBattery()
        if missing < 1 then return note(ply, false, L.BatteryAlreadyFull) end
        local cost = math.ceil(ent:Cfg().recharge * missing / 100)
        if not ply:canAfford(cost) then return note(ply, false, string.format(L.NeedMoney, money(cost))) end
        ply:addMoney(-cost)
        ent:SetBattery(100)
        note(ply, true, string.format(L.Recharged, money(cost)))
    end
    ACT[3] = function(ply, ent)
        if cfg.OwnerOnlyControl and not isOwner(ply, ent) then return note(ply, false, L.OwnerOnly) end
        ent:SetPower(not ent:GetPower())
        note(ply, true, ent:GetPower() and L.PoweredOn or L.PoweredOff)
    end
    for i = 1, #cfg.Modes do
        ACT[3 + i] = function(ply, ent)
            if cfg.OwnerOnlyControl and not isOwner(ply, ent) then return note(ply, false, L.OwnerOnly) end
            ent:SetMode(i)
            note(ply, true, string.format(L.ModeSet, cfg.Modes[i].name))
        end
    end

    net.Receive("SWZPrinter_Act", function(_, ply)
        local ent, act = net.ReadEntity(), net.ReadUInt(4)
        if not (IsValid(ent) and ent.IsSWZPrinter and ACT[act] and ply:Alive()) then return end
        if ply:EyePos():Distance(ent:GetPos()) > cfg.Distance.Use * 1.5 then return end
        if (ply.nextPrinterAct or 0) > CurTime() then return end
        ply.nextPrinterAct = CurTime() + cfg.ActionCooldown
        ACT[act](ply, ent)
    end)

    hook.Add("PlayerSpawnedSENT", "SWZPrinter", function(ply, ent)
        if ent.IsSWZPrinter then ent:Setowning_ent(ply) end
    end)
    return
end

local sc = cfg.Screen
local W, H = 820, 781
local C = cfg.Theme

local function font(name, size, weight)
    surface.CreateFont("SWZP_" .. name, {font = "Roboto", size = size, weight = weight or 700, extended = true})
end
font("name", 58) font("tier", 44, 800) font("label", 28, 600) font("big", 88, 800)
font("num", 70, 800) font("mid", 40, 700) font("btn", 36, 800) font("small", 26, 600)
font("tiny", 24, 700) font("stat", 31, 800)

local function short(n)
    if n >= 1e6 then return string.format("%s%.1fM", cfg.Currency, n / 1e6) end
    return money(n)
end
local function dur(sec)
    if sec == math.huge or sec ~= sec then return "--" end
    sec = math.max(0, math.floor(sec))
    if sec >= 3600 then return string.format("%dh %02dm", math.floor(sec / 3600), math.floor(sec % 3600 / 60)) end
    return string.format("%d:%02d", math.floor(sec / 60), sec % 60)
end
local function box(r, x, y, w, h, col) draw.RoundedBox(r, x, y, w, h, col) end
local function txt(t, f, x, y, col, ax, ay) draw.SimpleText(t, "SWZP_" .. f, x, y, col, ax or TEXT_ALIGN_LEFT, ay or TEXT_ALIGN_CENTER) end

local function Plane(ent, dist)
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local extX, extY, ox, oy = maxs.x - mins.x, maxs.y - mins.y, (mins.x + maxs.x) / 2, (mins.y + maxs.y) / 2
    local fit, topZ = 0.94, maxs.z + 0.1
    if ent:GetModel() == cfg.Model then extX, extY, ox, oy, fit, topZ = sc.Length, sc.Width, sc.OffsetX, sc.OffsetY, sc.Scale, sc.Height end
    topZ = topZ + math.Clamp((dist or 0) * 0.0004, 0, 0.5)
    local s = math.min(extY / W, extX / H) * fit
    local ang = ent:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    local center = ent:LocalToWorld(Vector(ox, oy, topZ))
    local origin = center - ang:Forward() * (W * s / 2) - ang:Right() * (H * s / 2)
    return origin, ang, s
end

local hover
local dbg = CreateClientConVar("swz_printer_debug", "0", false, false)

local function Debug(ent, origin, ang, s)
    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local function line(a, b, col) render.DrawLine(ent:LocalToWorld(a), ent:LocalToWorld(b), col, true) end
    local y, x = sc.Width / 2, sc.Length / 2
    local c = {Vector(-x, -y, 11.06), Vector(x, -y, 11.06), Vector(x, y, 11.06), Vector(-x, y, 11.06)}
    for i = 1, 4 do line(c[i], c[i % 4 + 1], Color(255, 220, 0)) end
    render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), mins, maxs, Color(0, 255, 255), true)
    local p = {origin, origin + ang:Forward() * W * s, origin + ang:Forward() * W * s + ang:Right() * H * s, origin + ang:Right() * H * s}
    for i = 1, 4 do render.DrawLine(p[i], p[i % 4 + 1], Color(255, 0, 255), true) end
    if (ent.dbgT or 0) < CurTime() then
        ent.dbgT = CurTime() + 2
        MsgN(string.format("[printer] modele=%s | boite (%.2f %.2f %.2f)-(%.2f %.2f %.2f) | echelle %.5f | ecran %.2f x %.2f",
            ent:GetModel(), mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z, s, W * s, H * s))
    end
end

local function Zone(x, y, w, h, act, enabled, mx, my, ent)
    local over = enabled and mx and mx >= x and mx <= x + w and my >= y and my <= y + h
    if over then hover = {ent = ent, act = act, t = CurTime()} end
    return over
end

local function Button(x, y, w, h, label, col, enabled, mx, my, act, ent)
    local over = Zone(x, y, w, h, act, enabled, mx, my, ent)
    local a = enabled and (over and 255 or 215) or 70
    box(14, x, y, w, h, Color(col.r, col.g, col.b, a))
    txt(label, "btn", x + w / 2, y + h / 2, enabled and C.buttonText or C.mute, TEXT_ALIGN_CENTER)
end

local function Chip(x, y, label, col)
    surface.SetFont("SWZP_small")
    local tw = surface.GetTextSize(label)
    box(12, x - tw - 54, y, tw + 54, 46, Color(col.r, col.g, col.b, 38))
    box(8, x - tw - 36, y + 17, 12, 12, col)
    txt(label, "small", x - 18, y + 23, col, TEXT_ALIGN_RIGHT)
end

local function sm(ent, key, target, speed)
    ent.sm = ent.sm or {}
    local v = ent.sm[key]
    if v == nil or sc.AnimSpeed <= 0 then v = target end
    v = Lerp(math.min(1, FrameTime() * speed * sc.AnimSpeed), v, target)
    ent.sm[key] = v
    return v
end
local function mix(a, b, t) return Color(Lerp(t, a.r, b.r), Lerp(t, a.g, b.g), Lerp(t, a.b, b.b)) end
local function LowBad(v)
    if v <= 20 then return C.bad elseif v <= 30 then return mix(C.bad, C.warn, (v - 20) / 10)
    elseif v <= 45 then return C.warn elseif v <= 55 then return mix(C.warn, C.ok, (v - 45) / 10) end
    return C.ok
end
local function HighBad(v)
    if v <= 45 then return C.ok elseif v <= 55 then return mix(C.ok, C.warn, (v - 45) / 10)
    elseif v <= 65 then return C.warn elseif v <= 75 then return mix(C.warn, C.bad, (v - 65) / 10) end
    return C.bad
end

local function Bar(x, y, w, h, frac, col)
    box(h / 2, x, y, w, h, C.line)
    box(h / 2, x, y, math.max(h, w * math.Clamp(frac, 0, 1)), h, col)
end

local matGlow = Material("sprites/glow04_noz")

local function Body(ent, c, running, dist)
    local k, t = c.color, cfg.Tint
    render.SetColorModulation(1 - t + t * k.r / 255, 1 - t + t * k.g / 255, 1 - t + t * k.b / 255)
    ent:DrawModel()
    render.SetColorModulation(1, 1, 1)
    if not cfg.LEDs.Enabled or dist > cfg.Distance.Detail * 1.5 then return end

    local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
    local cy = (mins.y + maxs.y) / 2
    local full = ent:GetMoney() >= c.max
    local led = (ent:GetBattery() <= 0 and C.bad) or (full and C.warn) or C.ok
    local pulse = running and (150 + 105 * math.sin(CurTime() * 4)) or 90
    render.SetMaterial(matGlow)
    for i = -1, 1 do
        render.DrawSprite(ent:LocalToWorld(Vector(maxs.x + 0.2, cy + i * 4, maxs.z - 1.4)), cfg.LEDs.Size, cfg.LEDs.Size,
            Color(led.r, led.g, led.b, pulse))
    end
end

local function SpinFan(ent, running)
    if not cfg.Fan.Enabled then return end
    if ent.fanBone == nil then
        local b = ent:LookupBone(cfg.Fan.Bone)
        ent.fanBone = (b and b >= 0) and b or false
    end
    if not ent.fanBone then return end
    if not running and (ent.fanV or 0) < 1 then
        if ent.fanV ~= 0 then
            ent.fanV = 0
            ent:ManipulateBoneAngles(ent.fanBone, Angle(ent.fanA or 0, 0, 0))
        end
        return
    end
    local dt = FrameTime()
    ent.fanV = Lerp(math.min(1, dt * (running and cfg.Fan.SpinUp or cfg.Fan.SpinDown)), ent.fanV or 0, running and cfg.Fan.Speed or 0)
    ent.fanA = ((ent.fanA or 0) + ent.fanV * dt) % 360
    ent:ManipulateBoneAngles(ent.fanBone, Angle(ent.fanA, 0, 0))
end

function ENT:Draw()
    local c0 = self:Cfg()
    local run0 = self:GetPower() and self:GetBattery() > 0 and self:GetMoney() < c0.max
    local ply = LocalPlayer()
    local dist = ply:EyePos():Distance(self:GetPos())
    Body(self, c0, run0, dist)
    if dist < cfg.Distance.Fan then SpinFan(self, run0) end
    if dist > cfg.Distance.Max then return end
    local c = c0
    local origin, ang, s = Plane(self, dist)

    if dist > cfg.Distance.Detail then
        local battery, held = self:GetBattery(), self:GetMoney()
        local on = self:GetPower()
        local run = on and battery > 0 and held < c.max
        render.OverrideDepthEnable(true, false)
        cam.Start3D2D(origin, ang, s)
            box(62, 0, 0, W, H, C.bg)
            box(20, 24, 24, W - 48, 150, C.card)
            box(8, 24, 24, 16, 150, c.color)
            box(14, W - 24 - 230, 60, 190, 78, run and C.ok or (on and C.warn or C.mute))
            box(20, 24, 200, (W - 68) / 2, 240, C.card)
            box(12, 54, 230, W / 2 - 98, 180, C.line)
            box(12, 54, 230 + 180 * (1 - battery / 100), W / 2 - 98, 180 * battery / 100, LowBad(battery))
            box(20, 44 + (W - 68) / 2, 200, (W - 68) / 2, 240, C.card)
            box(12, 74 + (W - 68) / 2, 230, (W - 68) / 2 - 60, 180, C.line)
            box(12, 74 + (W - 68) / 2, 230 + 180 * (1 - held / c.max), (W - 68) / 2 - 60, 180 * held / c.max, c.color)
        cam.End3D2D()
        render.OverrideDepthEnable(false, false)
        return
    end
    if dbg:GetBool() then Debug(self, origin, ang, s) end

    local mx, my
    if dist < cfg.Distance.Use then
        local hit = (ply:EyePos() - origin):Dot(ang:Up()) > 0 and util.IntersectRayWithPlane(ply:EyePos(), ply:GetAimVector(), origin, ang:Up())
        if hit then
            local lp = WorldToLocal(hit, Angle(), origin, ang)
            mx, my = lp.x / s, -lp.y / s
        end
    end

    local battery, held = self:GetBattery(), self:GetMoney()
    local temp, hp = self:GetTemp(), self:GetHp()
    local on = self:GetPower()
    local modes = cfg.Modes
    local mi = math.Clamp(self:GetMode(), 1, #modes)
    local mode = modes[mi]
    local rate, drain = c.rate * mode.rate, c.drain * mode.drain
    local running = on and battery > 0 and held < c.max
    local owner = self:Getowning_ent()
    local canCtl = not cfg.OwnerOnlyControl or not IsValid(owner) or owner == ply or (cfg.AdminBypass and ply:IsAdmin())
    owner = IsValid(owner) and owner:Nick() or L.Unknown

    local dBat, dHeld = sm(self, "bat", battery, 6), sm(self, "held", held, 5)
    local dTemp, dHp = sm(self, "temp", temp, 3), sm(self, "hp", hp, 5)
    local dTotal, dRate = sm(self, "total", self:GetTotal(), 4), sm(self, "rate", rate, 8)
    local dPow, dMode = sm(self, "pow", on and 1 or 0, 10), sm(self, "mode", mi, 12)

    if sc.SharpText then
        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    end
    cam.Start3D2D(origin, ang, s)
        box(62, 0, 0, W, H, C.bg)

        local cw, x1 = (W - 48 - 20) / 2, 24
        local x2 = x1 + cw + 20

        box(20, 24, 20, W - 48, 72, C.card)
        txt(owner, "name", W / 2, 56, C.text, TEXT_ALIGN_CENTER)

        box(20, 24, 104, W - 48, 60, C.card)
        box(4, 24, 118, 8, 32, c.color)
        txt(string.upper(c.name) .. " " .. L.PrinterSuffix, "tier", 52, 134, c.color)
        if not on then Chip(W - 44, 111, L.StateOff, C.mute)
        elseif running then Chip(W - 44, 111, L.StateOnline, C.ok)
        elseif battery <= 0 then Chip(W - 44, 111, L.StateEmpty, C.bad)
        else Chip(W - 44, 111, L.StateFull, C.warn) end

        local y = 176
        local over = Zone(x1, y, cw, 112, 3, canCtl, mx, my, self)
        local dHover = sm(self, "hpow", over and 1 or 0, 14)
        box(20, x1, y, cw, 112, mix(C.card, C.hi, dHover))
        txt(L.Power, "label", x1 + 24, y + 30, C.mute)
        txt(dPow > 0.5 and L.PowerOn or L.PowerOff, "mid", x1 + 24, y + 76, mix(C.mute, C.ok, dPow))
        local sx, sy = x1 + cw - 24 - 116, y + 28
        local fade = canCtl and 255 or 100
        local bgc = mix(C.line, C.ok, dPow)
        box(28, sx, sy, 116, 56, Color(bgc.r, bgc.g, bgc.b, fade))
        box(24, sx + 4 + (116 - 56) * dPow, sy + 4, 48, 48, Color(238, 241, 247, fade))

        box(20, x2, y, cw, 112, C.card)
        txt(L.Mode, "label", x2 + 24, y + 28, C.mute)
        local pw = (cw - 48 - 10 * (#modes - 1)) / #modes
        for i = 1, #modes do
            local px = x2 + 24 + (i - 1) * (pw + 10)
            Zone(px, y + 48, pw, 52, 3 + i, canCtl, mx, my, self)
            box(14, px, y + 48, pw, 52, C.line)
        end
        local lo = math.Clamp(math.floor(dMode), 1, math.max(#modes - 1, 1))
        local mcol = mix(modes[lo].color, modes[math.min(lo + 1, #modes)].color, math.Clamp(dMode - lo, 0, 1))
        box(14, x2 + 24 + (dMode - 1) * (pw + 10), y + 48, pw, 52, Color(mcol.r, mcol.g, mcol.b, canCtl and 255 or 110))
        for i, m in ipairs(modes) do
            local px = x2 + 24 + (i - 1) * (pw + 10)
            txt(m.name, "tiny", px + pw / 2, y + 74, mix(C.mute, C.buttonText, math.Clamp(1 - math.abs(dMode - i), 0, 1)), TEXT_ALIGN_CENTER)
        end

        local cy, ch = 300, 305
        box(20, x1, cy, cw, ch, C.card)
        txt(L.Battery, "label", x1 + 24, cy + 34, C.mute)
        local bcol = LowBad(dBat)
        txt(math.floor(dBat + 0.5) .. "%", "big", x1 + 24, cy + 118, bcol)
        txt(on and string.format(L.EmptyIn, dur(battery / drain * 60)) or L.Idle, "small", x1 + 24, cy + 180, C.mute)
        box(12, x1 + cw - 24 - 48, cy + 24, 48, 196, C.line)
        local fh = math.max(0, 188 * dBat / 100)
        box(8, x1 + cw - 24 - 44, cy + 28 + (188 - fh), 40, fh, bcol)
        Button(x1 + 24, cy + ch - 76, cw - 48, 56, L.Recharge .. "  " .. money(math.ceil(c.recharge * (100 - battery) / 100)), C.ok, battery < 99.5, mx, my, 2, self)

        box(20, x2, cy, cw, ch, C.card)
        txt(L.Money, "label", x2 + 24, cy + 34, C.mute)
        txt(string.format(L.Max, short(c.max)), "small", x2 + cw - 24, cy + 34, C.mute, TEXT_ALIGN_RIGHT)
        txt(string.format(L.PerMinute, money(dRate)), "mid", x2 + 24, cy + 82, C.text)
        txt(L.InStock, "small", x2 + 24, cy + 122, C.mute)
        txt(money(dHeld), "num", x2 + 24, cy + 164, C.text)
        Bar(x2 + 24, cy + 208, cw - 48, 12, dHeld / c.max, c.color)
        Button(x2 + 24, cy + ch - 76, cw - 48, 56, L.Withdraw, c.color, held >= 1, mx, my, 1, self)

        local tw = (W - 48 - 48) / 4
        local stats = {
            {L.StatTotal, short(dTotal)},
            {L.StatPerHour, short(dRate * 60)},
            {L.StatFullIn, held >= c.max and L.StatFull or (running and dur((c.max - held) / rate * 60) or "--")},
            {L.StatEmptyIn, on and dur(battery / drain * 60) or "--"},
        }
        for i, st in ipairs(stats) do
            local tx = 24 + (i - 1) * (tw + 16)
            box(16, tx, 617, tw, 72, C.card)
            txt(st[1], "tiny", tx + tw / 2, 639, C.mute, TEXT_ALIGN_CENTER)
            txt(st[2], "stat", tx + tw / 2, 669, C.text, TEXT_ALIGN_CENTER)
        end

        for i, row in ipairs({{L.Temperature, dTemp / 100, HighBad(dTemp), math.Round(dTemp) .. "°C"}, {L.Health, dHp / 100, LowBad(dHp), math.Round(dHp) .. "%"}}) do
            local rx = (i == 1) and x1 or x2
            box(20, rx, 701, cw, 56, C.card)
            txt(row[1], "tiny", rx + 22, 729, C.mute)
            Bar(rx + 110, 723, 140, 12, row[2], row[3])
            txt(row[4], "mid", rx + cw - 22, 729, row[3], TEXT_ALIGN_RIGHT)
        end
    cam.End3D2D()
    if sc.SharpText then
        render.PopFilterMin()
        render.PopFilterMag()
    end
end

hook.Add("KeyPress", "SWZPrinter", function(ply, key)
    if key ~= IN_USE or not IsFirstTimePredicted() or ply ~= LocalPlayer() then return end
    if hover and IsValid(hover.ent) and CurTime() - hover.t < 0.15 then
        net.Start("SWZPrinter_Act")
        net.WriteEntity(hover.ent)
        net.WriteUInt(hover.act, 4)
        net.SendToServer()
        if cfg.Sounds.Click ~= "" then surface.PlaySound(cfg.Sounds.Click) end
    end
end)

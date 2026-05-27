local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true
local Window = Library:CreateWindow({
    Title = 'SPTS: Legends',
    Footer = 'version: 1.0',
    Icon = 131440985129142, -- https://create.roblox.com/store/asset/131440985129142/Vyx
    NotifySide = 'Right',
    ShowCustomCursor = false,
})
local player = game.Players.LocalPlayer
local Players = game:GetService("Players")
local WEBHOOK_URL = "https://discord.com/api/webhooks/1508004868407689329/2M4317DsmXsmcqOcJbUhKLIXebjvWgt6m11eyaaDb8HYaR5UHmX5H812rLQaDfZdiV93"
local BIG_SUFFIXES = {
    "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "QaD", "QiD", "SxD", "SpD", "OcD", "NoD", "Vg", "UVg", "DVg", "TVg", "QaVg", "QiVg", "SxVg", "SpVg", "OcVg", "NoVg", "Tg", 
}
local DATA_FILE = "SPTSRWebhookData_" .. player.UserId .. ".json"
local HttpService = game:GetService("HttpService")
local RunService  = game:GetService("RunService")
local function getStat(attr)
    local ok, val = pcall(function() return player:GetAttribute(attr) end)
    if ok and type(val) == "number" then return val end
    return 0
end
local function getStringAttr(attr)
    local ok, val = pcall(function() return player:GetAttribute(attr) end)
    if ok and type(val) == "string" then return val end
    return "N/A"
end
local function collectStats()
    local baseTPM = getStat("TPM")
    local raceMultiplier = getStat("RaceMultiplier")
    local fusionTPMMultiplier = getStat("FusionTPMMultiplier")
    local finalTPM = baseTPM * (raceMultiplier * fusionTPMMultiplier * 2)
    return {
        FistStrength            = getStat("FistStrength"),
        FistStrengthMultiplier  = getStat("FistStrengthMultiplier"),
        BodyToughness           = getStat("BodyToughness"),
        BodyToughnessMultiplier = getStat("BodyToughnessMultiplier"),
        PsychicPower            = getStat("PsychicPower"),
        PsychicPowerMultiplier  = getStat("PsychicPowerMultiplier"),
        JumpForce               = getStat("JumpForce"),
        JumpForceMultiplier     = getStat("JumpForceMultiplier"),
        MovementSpeed           = getStat("MovementSpeed"),
        MovementSpeedMultiplier = getStat("MovementSpeedMultiplier"),
        TPM                     = finalTPM,
        TotalPower              = getStat("TotalPower"),
        GlobalRank              = getStat("P2WGlobalRank"),
        FusionLevel             = getStringAttr("FusionName"), 
        FusionTier              = getStat("FusionTier"),
    }
end
local function fmt(n)
    if type(n) ~= "number" or n ~= n then return "N/A" end
    if n == 0 then return "0" end
    local negative = n < 0; if negative then n = -n end
    local idx = 1
    while n >= 1000 and idx < #BIG_SUFFIXES do n = n / 1000; idx = idx + 1 end
    local result = (idx == 1) and tostring(math.floor(n))
                   or (string.format("%.2f", n):gsub("%.?0+$", "") .. BIG_SUFFIXES[idx])
    return negative and ("-" .. result) or result
end
local function delta(old, new)
    local diff = new - old
    if diff > 0  then return "▲ +" .. fmt(diff) end
    if diff < 0  then return "▼ "  .. fmt(math.abs(diff)) end
    return "— no change"
end
local function loadSavedStats()
    local ok, data = pcall(function()
        local raw = readfile(DATA_FILE)
        return HttpService:JSONDecode(raw)
    end)
    return ok and data or nil
end
local function saveData(stats, execCount)
    pcall(function()
        writefile(DATA_FILE, HttpService:JSONEncode({
            stats    = stats,
            execCount = execCount,
        }))
    end)
end
local sessionStart = tick()
pcall(function()
    local persistPath = "autoexec/SPTSLegends.lua"
    local selfSource = game:HttpGet("YOUR_RAW_SCRIPT_URL_HERE")
    local shouldWrite = true
    if isfile(persistPath) then
        local existing = readfile(persistPath)
        if existing == selfSource then
            shouldWrite = false
            print("[Persistence] Autoexec already up to date")
        end
    end
    if shouldWrite then
        writefile(persistPath, selfSource)
        print("[Persistence] Autoexec saved/updated")
    end
end)
task.spawn(function()
    task.wait(6)
    local userId     = player.UserId
    local username   = player.Name
    local placeId    = game.PlaceId
    local profileUrl = "https://www.roblox.com/users/" .. userId .. "/profile"
    local avatarImage = ""
    pcall(function()
        local raw  = game:HttpGet("https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=150x150&format=Png&isCircular=false", true)
        local data = HttpService:JSONDecode(raw)
        if data and data.data and data.data[1] then
            avatarImage = data.data[1].imageUrl or ""
        end
    end)
    local saved = nil
    pcall(function()
        saved = loadSavedStats()
    end)
    local lastStats = saved and saved.stats or nil
    local execCount = saved and (saved.execCount + 1) or 1
    local currentStats = collectStats()
    pcall(function()
        saveData(currentStats, execCount)
    end)
    local sessionStart = tick()
    local statLabels = {
        { key = "FistStrength",            label = "Fist Strength" },
        { key = "BodyToughness",           label = "Body Toughness" },
        { key = "PsychicPower",            label = "Psychic Power" },
        { key = "JumpForce",               label = "Jump Force" },
        { key = "MovementSpeed",           label = "Move Speed" },
        { key = "FistStrengthMultiplier",  label = "FS Multiplier" },
        { key = "BodyToughnessMultiplier", label = "BT Multiplier" },
        { key = "PsychicPowerMultiplier",  label = "PP Multiplier" },
        { key = "JumpForceMultiplier",     label = "JF Multiplier" },
        { key = "MovementSpeedMultiplier", label = "MS Multiplier" },
        { key = "TPM",                     label = "TPM" },
        { key = "TotalPower",              label = "Total Power" },
        { key = "GlobalRank",              label = "Global Rank" },
        { key = "FusionLevel",             label = "Fusion" },
    }
    local payload = nil
    local ok1, err1 = pcall(function()
        local statLines, changeLines = {}, {}
        for _, def in ipairs(statLabels) do
            local cur = currentStats[def.key] or 0
            local displayValue
            if type(cur) == "string" then
                displayValue = cur
            else
                displayValue = fmt(cur)
            end
            table.insert(statLines, def.label .. ": **" .. displayValue .. "**")
            if lastStats then
                local old = lastStats[def.key] or 0
                if type(old) == "number" and type(cur) == "number" then
                    table.insert(changeLines, def.label .. ": " .. delta(old, cur))
                end
            end
        end
        local statsText   = table.concat(statLines, "\n")
        local changesText = lastStats and table.concat(changeLines, "\n") or "_No previous data — first execution_"
        local sessionDur = (saved and saved.lastSessionDuration) or "No previous session"
        local embed = {
            title     = "🟢 Script Executed — SPTS: Legends",
            color     = 0x9B59B6,
            thumbnail = { url = avatarImage },
            fields    = {
                { name = "👤 Username",          value = username,                         inline = true  },
                { name = "🆔 User ID",           value = tostring(userId),                 inline = true  },
                { name = "🎮 Place ID",          value = tostring(placeId),                inline = true  },
                { name = "🔗 Profile",           value = "[Click here](" .. profileUrl .. ")", inline = true },
                { name = "🔢 Total Executes",    value = tostring(execCount),              inline = true  },
                { name = "🕐 Time Executed", value = os.date("%d/%m/%Y at %H:%M:%S"), inline = true },
                { name = "📊 Current Stats",     value = statsText,                        inline = false },
                { name = "📈 Change Since Last Trigger", value = changesText,              inline = false },
            },
            footer    = { text = "SPTS:L Webhook • VyxHub" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }
        payload = HttpService:JSONEncode({ embeds = { embed } })
    end)
    if not ok1 then
        return
    end
    local requestFunc = nil
    if syn and syn.request then
        requestFunc = syn.request
    elseif http and http.request then
        requestFunc = http.request
    elseif request then
        requestFunc = request
    end
    if not requestFunc then
        return
    end
    local ok, err = pcall(requestFunc, {
        Url     = WEBHOOK_URL,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = payload,
    })
end)
local antiAFKConnection = nil
local lastDeath = nil
local PlayerViewerGUI = nil
local inspectorVisible = false
local selectedInspectedPlayer = nil
local inspectorUpdateConnection = nil
local lasScreenGui = nil
local FSZones = {
    {name = "0", cframe = CFrame.new(-2269.771, 1943.37219, 1051.28455, -0.0149722425, 6.47287912e-09, 0.999887884, 1.92641973e-08, 1, -6.18514395e-09, -0.999887884, 1.91694323e-08, -0.0149722425), requirement = 0},
    {name = "1B", cframe = CFrame.new(1176.34949, 4789.33545, -2293.5, 0.880030394, 1.04717607e-07, 0.474917382, -1.20807698e-07, 1, 3.36235795e-09, -0.474917382, -6.03326527e-08, 0.880030394), requirement = 1000000000},
    {name = "100B", cframe = CFrame.new(1380.30139, 9274.40137, 1648.51819, 0.0609991476, 8.43776746e-08, -0.998137832, 1.06078413e-09, 1, 8.45999253e-08, 0.998137832, -6.21933216e-09, 0.0609991476), requirement = 100000000000},
    {name = "10T", cframe = CFrame.new(-366.034302, 15735.2051, -12.1672544, 0.995713294, 2.02994466e-09, 0.0924932063, -1.62733336e-12, 1, -2.19294414e-08, -0.0924932063, 2.18352856e-08, 0.995713294), requirement = 10000000000000},
    {name = "10Qa", cframe = CFrame.new(-3727.84766, 2693.57227, 16.0745296, 0.0901988745, 2.79683299e-08, 0.995923758, -1.02125838e-07, 1, -1.88334646e-08, -0.995923758, -1.00010794e-07, 0.0901988745), requirement = 10000000000000000},
    {name = "100Qi", cframe = CFrame.new(1630.12598, 345.290314, 15.2987471, 0.692142248, -6.7703283e-08, -0.721761107, 1.10162457e-08, 1, -8.32387173e-08, 0.721761107, 4.96619386e-08, 0.692142248), requirement = 100000000000000000000},
    {name = "1Sx", cframe = CFrame.new(-379.764587, 249.18605, -79.6964035, 0.965907097, -1.49697481e-08, -0.25888893, 1.66366778e-08, 1, 4.2479118e-09, 0.25888893, -8.41014014e-09, 0.965907097), requirement = 1000000000000000000000},
    {name = "1Sp", cframe = CFrame.new(-499.793976, 24128.3047, -14.2568655, 0.99993062, 3.05130747e-08, 0.0117797721, -2.97312432e-08, 1, -6.65457733e-08, -0.0117797721, 6.61909283e-08, 0.99993062), requirement = 1000000000000000000000000},
    {name = "10Oc", cframe = CFrame.new(-143.936157, 810.812073, -3072.28101, -0.987532735, -5.72541872e-08, 0.157413632, -4.79417963e-08, 1, 6.29557348e-08, -0.157413632, 5.46241559e-08, -0.987532735), requirement = 10000000000000000000000000000},
    {name = "1No", cframe = CFrame.new(2542.07446, 957.446716, 3013.55664, 0.647452891, -2.39967708e-08, 0.762105465, 1.92891125e-08, 1, 1.51002428e-08, -0.762105465, 4.92364238e-09, 0.647452891), requirement = 1000000000000000000000000000000},
    {name = "10Dc", cframe = CFrame.new(-4932.24268, 6461.31055, -2647.33057, -0.455936253, 7.26396721e-08, -0.890012443, -1.09641141e-08, 1, 8.72331753e-08, 0.890012443, 4.95309642e-08, -0.455936253), requirement = 10000000000000000000000000000000000},
    {name = "10Ud", cframe = CFrame.new(-5555.97852, 7621.5083, -4057.93945, -0.993656695, 3.18277174e-08, -0.112455957, 2.03542214e-08, 1, 1.03174706e-07, 0.112455957, 1.00231283e-07, -0.993656695), requirement = 10000000000000000000000000000000000000},
    {name = "10Dd", cframe = CFrame.new(-135.123917, 271.066895, -2778.39502, 1, 7.18386683e-10, 1.10802137e-15, -7.18386683e-10, 1, 3.68997064e-08, -1.08151316e-15, -3.68997064e-08, 1), requirement = 100000000000000000000000000000000000000000},
    {name = "100Td", cframe = CFrame.new(519.054382, 271.076416, -2672.27124, 1, -9.97027954e-08, 2.48749415e-15, 9.97027954e-08, 1, -1.41017475e-09, -2.34689579e-15, 1.41017475e-09, 1), requirement = 100000000000000000000000000000000000000000000},
    {name = "10Qad", cframe = CFrame.new(-3467.16406, 854.104126, -2895.91602, 1, 2.76834466e-09, -1.69274571e-14, -2.76834466e-09, 1, -8.05140665e-09, 1.69051683e-14, 8.05140665e-09, 1), requirement = 10000000000000000000000000000000000000000000000},
}
local BTZones = {
    {name = "100", cframe = CFrame.new(367.036713, 249.738846, -445.080231, 0.999153137, -1.04025361e-07, 0.0411467589, 1.04061932e-07, 1, 1.25299471e-09, -0.0411467589, 3.02987746e-09, 0.999153137), requirement = 100},
    {name = "10k", cframe = CFrame.new(356.429504, 263.774994, -491.887543, 0.999983132, -6.65461499e-08, 0.00581188127, 6.68386306e-08, 1, -5.01300406e-08, -0.00581188127, 5.05176523e-08, 0.999983132), requirement = 10000},
    {name = "100k", cframe = CFrame.new(1638.39722, 259.376007, 2247.62158, -0.126060277, 3.91438739e-08, -0.992022574, -4.5399041e-08, 1, 4.522769e-08, 0.992022574, 5.073829e-08, -0.126060277), requirement = 100000},
    {name = "1m", cframe = CFrame.new(-2297.76733, 977.258057, 1070.18555, 0.355243593, 7.08071966e-08, -0.934773743, 4.49922979e-08, 1, 9.28464488e-08, 0.934773743, -7.50407239e-08, 0.355243593), requirement = 1000000},
    {name = "10m", cframe = CFrame.new(-2037.96814, 714.275085, -1887.83997, 0.998887718, -6.38770388e-08, 0.0471520908, 6.4482272e-08, 1, -1.13146656e-08, -0.0471520908, 1.43425547e-08, 0.998887718), requirement = 10000000},
    {name = "1b", cframe = CFrame.new(-256.918488, 286.897644, 979.702576, 0.0282151923, -6.6130057e-09, 0.999601901, 2.02114414e-09, 1, 6.55859012e-09, -0.999601901, 1.83528759e-09, 0.0282151923), requirement = 1000000000},
    {name = "100b", cframe = CFrame.new(-278.050232, 281.427185, 992.259277, -0.00319529395, 6.34362394e-08, 0.999994874, -8.16399393e-08, 1, -6.36974278e-08, -0.999994874, -8.1843055e-08, -0.00319529395), requirement = 100000000000},
    {name = "10T", cframe = CFrame.new(-278.01886, 281.427399, 1006.40698, -0.00319823297, -1.35164022e-08, 0.999994874, 1.08025713e-08, 1, 1.35510207e-08, -0.999994874, 1.08458558e-08, -0.00319823297), requirement = 10000000000000},
    {name = "10Qa", cframe = CFrame.new(-47.1115685, 245.187485, 1330.58118, 1, 4.50923849e-08, 1.72128631e-14, -4.50923849e-08, 1, 8.35411811e-08, -1.34457925e-14, -8.35411811e-08, 1), requirement = 10000000000000000},
    {name = "100Qi", cframe = CFrame.new(1668.99561, 344.193329, -22.8525906, 0.707134247, -9.39987643e-10, 0.707079291, -1.84338038e-08, 1, 1.97646308e-08, -0.707079291, -2.70104099e-08, 0.707134247), requirement = 100000000000000000000},
    {name = "1Sx", cframe = CFrame.new(703.556824, 247.536148, -1828.57202, 1, 1.37334089e-09, -1.21231093e-15, -1.37334089e-09, 1, -3.94078938e-08, 1.1581905e-15, 3.94078938e-08, 1), requirement = 1000000000000000000000},
    {name = "1Sp", cframe = CFrame.new(389.618622, 245.389908, -21.0375519, 1, -2.95618641e-09, -1.61266063e-15, 2.95618641e-09, 1, 8.48214086e-08, 1.36191272e-15, -8.48214086e-08, 1), requirement = 1000000000000000000000000},
    {name = "10Oc", cframe = CFrame.new(-324.988831, 249.302765, -485.454987, 0.866007268, -3.77648846e-08, 0.500031412, 3.1052565e-08, 1, 2.17449099e-08, -0.500031412, -3.30399197e-09, 0.866007268), requirement = 10000000000000000000000000000},
    {name = "1No", cframe = CFrame.new(-126.343002, 243.457245, 221.213013, 1, -3.71794044e-08, 6.51155816e-15, 3.71794044e-08, 1, -5.26165387e-08, -4.55530677e-15, 5.26165387e-08, 1), requirement = 1000000000000000000000000000000},
    {name = "10Dc", cframe = CFrame.new(159.158615, 249.247055, -359.302277, 1, 7.40803818e-09, -1.91459495e-15, -7.40803818e-09, 1, -1.15695886e-09, 1.90602424e-15, 1.15695886e-09, 1), requirement = 10000000000000000000000000000000000},
    {name = "10Ud", cframe = CFrame.new(-1012.34912, 246.137817, 1675.41101, 0.999262214, 0, -0.0384062119, 0, 1, 0, 0.0384062119, 0, 0.999262214), requirement = 10000000000000000000000000000000000000},
    {name = "10Dd", cframe = CFrame.new(405.714325, 271.076416, -2122.02539, 0.291535258, 6.23715302e-09, 0.956560075, -3.38731105e-08, 1, 3.80326659e-09, -0.956560075, -3.35104531e-08, 0.291535258), requirement = 100000000000000000000000000000000000000000},
    {name = "100Td", cframe = CFrame.new(892.975769, 257.126587, -2669.03442, 0.830906928, -1.31344677e-08, 0.556411386, -5.97189243e-11, 1, 2.36948541e-08, -0.556411386, -1.97214458e-08, 0.830906928), requirement = 100000000000000000000000000000000000000000000},
    {name = "10Qad", cframe = CFrame.new(119.452591, 344.208221, -2482.84009, 1, 5.28686179e-08, 5.73723918e-15, -5.28686179e-08, 1, 6.39997353e-08, -2.35366167e-15, -6.39997353e-08, 1), requirement = 10000000000000000000000000000000000000000000000},
}
local PSZones = {
    {name = "1M", cframe = CFrame.new(-2530.81494, 5486.41895, -533.408325, 0.24939476, 1.73370722e-08, 0.968401909, -6.91805653e-08, 1, -8.65366806e-11, -0.968401909, -6.69730085e-08, 0.24939476), requirement = 1000000},
    {name = "1B", cframe = CFrame.new(-2561.79956, 5500.90234, -439.030212, 0.372447491, 1.93577669e-08, 0.92805326, -2.19991882e-08, 1, -1.20297239e-08, -0.92805326, -1.59359779e-08, 0.372447491), requirement = 1000000000},
    {name = "1T", cframe = CFrame.new(-2582.28369, 5516.45166, -502.717743, 0.373660117, 9.71572192e-08, 0.927565694, -1.1170421e-07, 1, -5.97454317e-08, -0.927565694, -8.12885119e-08, 0.373660117), requirement = 1000000000000},
    {name = "1Qa", cframe = CFrame.new(-2546.59839, 5412.48877, -494.52536, 0.251929462, 5.70839482e-08, 0.967745602, -1.71155659e-08, 1, -5.45308936e-08, -0.967745602, -2.82557444e-09, 0.251929462), requirement = 10000000000000000},
    {name = "100Qi", cframe = CFrame.new(-2636.10522, 5570.6543, -432.306396, 0.251911759, 4.98361068e-08, 0.967750192, -1.49434403e-08, 1, -4.76069921e-08, -0.967750192, -2.46875564e-09, 0.251911759), requirement = 100000000000000000000},
    {name = "1Sx", cframe = CFrame.new(1648.2605, 243.66806, -159.410004, 0.576067686, 1.8919831e-08, -0.817402005, -1.09859775e-08, 1, 1.54038826e-08, 0.817402005, 1.06281442e-10, 0.576067686), requirement = 1000000000000000000000},
    {name = "1Sp", cframe = CFrame.new(914.384827, 353.15744, -2071.96484, 0.996860206, 1.26754742e-07, -0.0791813806, -1.27550251e-07, 1, -4.98893815e-09, 0.0791813806, 1.50728798e-08, 0.996860206), requirement = 1000000000000000000000000},
    {name = "10Oc", cframe = CFrame.new(-2561.65771, 312.880432, -112.382874, 1, 1.1963146e-08, -1.72197072e-14, -1.1963146e-08, 1, 1.30604178e-07, 1.87821441e-14, -1.30604178e-07, 1), requirement = 10000000000000000000000000000},
    {name = "1No", cframe = CFrame.new(-770.284302, 5504.55518, -235.607758, 0.988742888, 5.71779744e-08, 0.149624422, -6.49189218e-08, 1, 4.68516248e-08, -0.149624422, -5.6037667e-08, 0.988742888), requirement = 1000000000000000000000000000000},
    {name = "10Dc", cframe = CFrame.new(-620.12384, 249.695648, 1333.11841, 1, 1.56379854e-09, -4.34823728e-15, -1.56379854e-09, 1, 9.51303392e-09, 4.36311372e-15, -9.51303392e-09, 1), requirement = 10000000000000000000000000000000000},
    {name = "10Ud", cframe = CFrame.new(-224.763046, 278.201843, 2236.86523, 0.987276196, -7.10644699e-08, -0.15901491, 5.41674048e-08, 1, -1.1059516e-07, 0.15901491, 1.00574539e-07, 0.987276196), requirement = 10000000000000000000000000000000000000},
    {name = "10Dd", cframe = CFrame.new(849.742371, 363.527863, -2635.10596, 1, 1.136912e-07, 4.09570129e-16, -1.136912e-07, 1, 2.79003531e-09, -9.23676459e-17, -2.79003531e-09, 1), requirement = 100000000000000000000000000000000000000000},
    {name = "100Td", cframe = CFrame.new(-230.910461, 271.029449, -2309.0791, 0.999067128, -1.12151479e-08, -0.0431835093, 9.64293356e-09, 1, -3.66160506e-08, 0.0431835093, 3.61654777e-08, 0.999067128), requirement = 100000000000000000000000000000000000000000000},
    {name = "10Qad", cframe = CFrame.new(-761.884521, 5744.70752, 102.131584, 0.786276996, 4.93273973e-08, 0.617874205, -4.98643482e-09, 1, -7.34885504e-08, -0.617874205, 5.47013634e-08, 0.786276996), requirement = 10000000000000000000000000000000000000000000000},
}
local NPCnames = {
    {name = "Noob", health = 100000},
    {name = "Thug", health = 1000000000000},
    {name = "Mafia", health = 10000000000000000},
    {name = "WereWolf", health = 100000000000000000000},
    {name = "Sath", health = 1000000000000000000000000000000000},
    {name = "Robot", health = 100000000000000000000000000000000000000},
}
local videoUrls = {
    "rbxassetid://5608339667",
    "rbxassetid://5608403837",
    "rbxassetid://5608304953",
    "rbxassetid://5670785995",
}
local statusGroups = {
    Villains = {'Supervillain', 'Criminal', 'Lawbreaker'},
    Heroes = {'Superhero', 'Guardian', 'Protector'},
    Innocent = {'Innocent'}
}
local MiscTeleports = {
    {name = 'Spawn', cframe = CFrame.new(422.06781, 249.197632, 877.447571, 0.249072298, -2.64159823e-08, 0.968484879, 7.05863528e-08, 1, 9.12236864e-09, -0.968484879, 6.60896902e-08, 0.249072298)},
    {name = 'Sath', cframe = CFrame.new(488.58902, 249.197632, 895.078613, -0.225295424, -4.36883845e-08, -0.97429049, 3.53536578e-08, 1, -5.30164286e-08, 0.97429049, -4.63890899e-08, -0.225295424)},
    {name = 'Grim Reaper', cframe = CFrame.new(-129.489319, 249.193542, 528.983398, -0.999995351, -5.04946875e-08, 0.00304673426, -5.06868751e-08, 1, -6.30035188e-08, -0.00304673426, -6.31576569e-08, -0.999995351)},
    {name = 'Ghost Rider', cframe = CFrame.new(159.43158, 249.193604, 1234.44165, -0.0137687353, -2.65524356e-11, 0.999905229, 6.97175864e-08, 1, 9.86568938e-10, -0.999905229, 6.97245639e-08, -0.0137687353)},
}
local function getPlayerStatus(targetPlayer)
    if not targetPlayer then return nil end
    local leaderstats = targetPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local status = leaderstats:FindFirstChild("Status")
        if status then
            local statusValue = status.Value
            return statusValue
        end
    end
    return nil
end
local function toFullNumber(num)
    return string.format("%.0f", num)
end
local function getTargetPlayerStat(targetPlayer, statName)
    local success, result = pcall(function()
        if not targetPlayer or not targetPlayer.Parent then
            return nil
        end
        local statValue = targetPlayer:GetAttribute(statName)
        if statValue then
            return tonumber(toFullNumber(statValue))
        end
        return 0
    end)
    if not success then
        return nil
    end
    return result
end
local STAT_DEFINITIONS = {
    { attr = "FistStrength",             label = "Fist Strength" },
    { attr = "FistStrengthMultiplier",   label = "FS Multiplier" },
    { attr = "BodyToughness",            label = "Body Toughness" },
    { attr = "BodyToughnessMultiplier",  label = "BT Multiplier" },
    { attr = "PsychicPower",             label = "Psychic Power" },
    { attr = "PsychicPowerMultiplier",   label = "PP Multiplier" },
    { attr = "JumpForce",                label = "Jump Force" },
    { attr = "JumpForceMultiplier",      label = "JF Multiplier" },
    { attr = "MovementSpeed",            label = "Move Speed" },
    { attr = "MovementSpeedMultiplier",  label = "MS Multiplier" },
    { attr = "TPM",                      label = "TPM" },
    { attr = "TotalPower",               label = "Total Power" },
    { attr = "GlobalRank",               label = "Global Rank" },
}
local BIG_SUFFIXES = {
    "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "QaD", "QiD", "SxD", "SpD", "OcD", "NoD", "Vg", "UVg", "DVg", "TVg", "QaVg", "QiVg", "SxVg", "SpVg", "OcVg", "NoVg", "Tg", 
}
local function formatBigNumber(n)
    if type(n) ~= "number" or n ~= n then return "N/A" end
    if n == 0 then return "0" end
    local negative = n < 0
    if negative then n = -n end
    local idx = 1
    while n >= 1000 and idx < #BIG_SUFFIXES do
        n = n / 1000
        idx = idx + 1
    end
    local result
    if idx == 1 then
        result = tostring(math.floor(n))
    else
        result = string.format("%.2f", n):gsub("%.?0+$", "") .. BIG_SUFFIXES[idx]
    end
    return negative and ("-" .. result) or result
end
local Tabs = {
	Main = Window:AddTab("Main", "user"),
    Teleports = Window:AddTab("Teleports", "map-pin"),
    Misc = Window:AddTab("Misc", "sparkles"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}
local LeftGroupBox = Tabs.Main:AddLeftGroupbox('Race Roll', "repeat")
LeftGroupBox:AddToggle('RaceRollToggle', {
    Text = 'Race Roll',
    Default = false,
    Tooltip = 'Automatically rolls races',
})
local NPCnamesList = {}
for _, npc in ipairs(NPCnames) do
    table.insert(NPCnamesList, npc.name)
end
local NPCFarmGroup = Tabs.Main:AddLeftGroupbox('NPC Farm', "hand-fist")
NPCFarmGroup:AddToggle('NPCFarmToggle', {
    Text = 'Enable NPC Farm',
    Default = false,
    Tooltip = 'Automatically farms selected NPC using Punch skill (1:1 damage)',
})
NPCFarmGroup:AddDropdown('NPCFarmDropdown', {
    Values = NPCnamesList,
    Default = {""},
    Multi = true,
    Text = 'Select NPC',
    Tooltip = 'Choose which NPC to farm',
})
local LASGroup = Tabs.Main:AddRightGroupbox('Low Attention Span', "tv")
LASGroup:AddToggle('LASToggle', {
    Text = 'Enable Low Attention Span',
    Default = false,
    Tooltip = 'Plays various videos on the screen to keep you entertained while grinding.',
})
local TabBox2 = Tabs.Main:AddRightTabbox()
local areaTraining = TabBox2:AddTab('Area Training')
areaTraining:AddToggle('AreaToggle', { 
    Text = 'Enable Feature' ,
    Default = false,
    Tooltip = 'Automatically trains in best area for selected stat'
})
local DepBox = areaTraining:AddDependencyBox()
DepBox:AddDropdown('ModeDropdown', {
    Values = { 'FS', 'BT', 'BT Death', "PS" },
    Default = {""},
    Text = 'Select Mode',
    Tooltip = 'Choose Stat'
})
local noAreaTraining = TabBox2:AddTab('No Area')
noAreaTraining:AddToggle('NoAreaFeatureToggle', { 
    Text = 'Enable Feature',
    Default = false,
    Tooltip = 'Automatically trains selected skill without being in an area (no area multi)'
})
local noAreaDepBox = noAreaTraining:AddDependencyBox()
noAreaDepBox:AddDropdown('NoAreaModeDropdown', {
    Values = { 'FS', 'BT', 'PS' },
    Default = {""},
    Multi = true,
    Text = 'Select Mode',
    Tooltip = 'Choose Stat',
})
local rightGroupBox = Tabs.Main:AddRightGroupbox('Multiplier Upgrades', "circle-fading-arrow-up")
rightGroupBox:AddToggle('MultiplierToggle', {   
    Text = 'Multiplier Upgrades',
    Default = false,
    Tooltip = 'Select to automatically upgrade multipliers',
})
rightGroupBox:AddDropdown('MultiplierDropdown', {
    Values = { 'FS', 'BT', 'PP', 'JF', 'MS' },
    Default = {""},
    Multi = true,
    Text = 'Select Multipliers',
    Tooltip = 'Choose which multipliers to upgrade',
})
local FSZoneNames = {}
for _, zone in ipairs(FSZones) do
    table.insert(FSZoneNames, zone.name)
end
local BTZoneNames = {}
for _, zone in ipairs(BTZones) do
    table.insert(BTZoneNames, zone.name)
end
local PSZoneNames = {}
for _, zone in ipairs(PSZones) do
    table.insert(PSZoneNames, zone.name)
end
local TeleportsGroup = Tabs.Teleports:AddLeftGroupbox('MiscTeleports', "map-pin-plus-inside")
TeleportsGroup:AddButton("Teleport", function()
    local selectedTeleportName = Options.TeleportDropdown.Value
    for _, teleport in ipairs(MiscTeleports) do
        if teleport.name == selectedTeleportName then
            player.Character.HumanoidRootPart.CFrame = teleport.cframe
            break
        end
    end
end)
TeleportsGroup:AddDropdown("TeleportDropdown", {
    Values = (function()
        local names = {}
        for _, teleport in ipairs(MiscTeleports) do
            table.insert(names, teleport.name)
        end
        return names
    end)(),
    Default = {""},
    Multi = false,
    Text = "Select Teleport",
})
local FSGroup = Tabs.Teleports:AddLeftGroupbox('FS Zones', "map-pin")
FSGroup:AddButton('Teleport', function() 
    local selectedZoneName = Options.FSTeleportDropdown.Value
    for _, zone in ipairs(FSZones) do
        if zone.name == selectedZoneName then
            player.Character.HumanoidRootPart.CFrame = zone.cframe
            break
        end
    end
end)
FSGroup:AddDropdown('FSTeleportDropdown', {
    Values = FSZoneNames,
    Default = {""},
    Text = 'Select Zone',
    Tooltip = 'Choose which zone to teleport to',
})
local BTGroup = Tabs.Teleports:AddRightGroupbox('BT Zones', "map-pin")
BTGroup:AddButton('Teleport', function() 
    local selectedZoneName = Options.BTTeleportDropdown.Value
    for _, zone in ipairs(BTZones) do
        if zone.name == selectedZoneName then
            player.Character.HumanoidRootPart.CFrame = zone.cframe
            break
        end
    end
end)
BTGroup:AddDropdown('BTTeleportDropdown', {
    Values = BTZoneNames,
    Default = {""},
    Text = 'Select Zone',
    Tooltip = 'Choose which zone to teleport to',
})
local PSGroup = Tabs.Teleports:AddRightGroupbox('PS Zones', "map-pin")
PSGroup:AddButton('Teleport', function() 
    local selectedZoneName = Options.PSTeleportDropdown.Value
    for _, zone in ipairs(PSZones) do
        if zone.name == selectedZoneName then
            player.Character.HumanoidRootPart.CFrame = zone.cframe
            break
        end
    end
end)
PSGroup:AddDropdown('PSTeleportDropdown', {
    Values = PSZoneNames,
    Default = {""},
    Text = 'Select Zone',
    Tooltip = 'Choose which zone to teleport to',
})
local KIAuraSize = Tabs.Misc:AddLeftGroupbox('KI Aura Size', "a-large-small")
KIAuraSize:AddSlider('KIAuraSliderX', {
    Text = 'Size X',
    Default = 17.8,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Compact = false,
})
KIAuraSize:AddSlider('KIAuraSliderY', {
    Text = 'Size Y',
    Default = 17.4,
    Min = 1,
    Max = 200,
    Rounding = 0,
    Compact = false,
})
KIAuraSize:AddToggle('KIAuraToggle', {
    Text = 'Enable KI Aura Size',
    Default = false,
    Tooltip = 'Toggles KI Aura Size',
})
local ESPGroup = Tabs.Misc:AddLeftGroupbox('ESP Toggles', "eye")
ESPGroup:AddLabel('Note: Can be performance heavy\nColours have different multis')
ESPGroup:AddDivider()
ESPGroup:AddToggle('BTESPToggle', {
    Text = 'BT ESP Toggle',
    Default = false,
    Tooltip = 'Toggles ESP for players based on BT',
})
ESPGroup:AddToggle('PSESPToggle', {
    Text = 'PS ESP Toggle',
    Default = false,
    Tooltip = 'Toggles ESP for players based on PS',
})
ESPGroup:AddToggle('StatusESPToggle', {
    Text = 'Status ESP Toggle',
    Default = false,
    Tooltip = 'Toggles ESP for players based on Status',
})
local StatusGroup = Tabs.Misc:AddRightGroupbox('Status Bringer', "users-round")
StatusGroup:AddToggle('StatusBringerToggle', {
    Text = 'Enable Status Bringer',
    Default = false,
    Tooltip = 'Toggles Status Bringer',
})
StatusGroup:AddDropdown('StatusBringerDropdown', {
    Values = {'Villains', 'Heroes', 'Innocent'},
    Default = {''},
    Multi = true,
    Text = 'Select Status',
    Tooltip = 'Choose which status to bring',
})
local AutoRespawnGroup = Tabs.Misc:AddRightGroupbox('Auto Respawn', "refresh-cw")
AutoRespawnGroup:AddToggle('AutoRespawnToggle', {
    Text = 'Enable Auto Respawn',
    Default = false,
    Tooltip = 'Automatically respawns the player when they die',
})
AutoRespawnGroup:AddDropdown('AutoRespawnModeDropdown', {
    Values = {'Normal Respawn', 'Last POS'},
    Default = 1,
    Text = 'Respawn Mode',
    Tooltip = 'Choose the respawn mode',
})
AutoRespawnGroup:AddSlider('AutoRespawnSlider', {
    Text = 'Respawn Delay (seconds)',
    Default = 1,
    Min = 1,
    Max = 30,
    Rounding = 0,
    Compact = false,
})
local MiscGroup = Tabs.Misc:AddRightGroupbox('Misc', "alarm-clock-off")
MiscGroup:AddToggle('AntiAFKToggle', {
    Text = 'Enable Anti AFK',
    Default = false,
    Tooltip = 'Prevents the player from being kicked for being AFK',
})
MiscGroup:AddDivider()
local function buildPlayerViewerUI()
    if PlayerViewerGUI then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerViewerGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    screenGui.Parent = player.PlayerGui
    PlayerViewerGUI = screenGui
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 560, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainFrame
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(50, 40, 70)
    mainStroke.Thickness = 1
    mainStroke.Parent = mainFrame
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 6)
    titleCorner.Parent = titleBar
    local titleFill = Instance.new("Frame")
    titleFill.Size = UDim2.new(1, 0, 0.5, 0)
    titleFill.Position = UDim2.new(0, 0, 0.5, 0)
    titleFill.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    titleFill.BorderSizePixel = 0
    titleFill.Parent = titleBar
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "Player Viewer"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 14, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.Parent = titleBar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -32, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, -12, 1, -44)
    body.Position = UDim2.new(0, 6, 0, 40)
    body.BackgroundTransparency = 1
    body.Parent = mainFrame
    local leftWrapper = Instance.new("Frame")
    leftWrapper.Name = "LeftWrapper"
    leftWrapper.Size = UDim2.new(0, 175, 1, 0)
    leftWrapper.BackgroundTransparency = 1
    leftWrapper.BorderSizePixel = 0
    leftWrapper.Parent = body
    local listHeader = Instance.new("Frame")
    listHeader.Name = "ListHeader"
    listHeader.Size = UDim2.new(1, 0, 0, 28)
    listHeader.Position = UDim2.new(0, 0, 0, 0)
    listHeader.BackgroundColor3 = Color3.fromRGB(20, 18, 27)
    listHeader.BorderSizePixel = 0
    listHeader.Parent = leftWrapper
    local listHeaderCorner = Instance.new("UICorner")
    listHeaderCorner.CornerRadius = UDim.new(0, 5)
    listHeaderCorner.Parent = listHeader
    local listHeaderStroke = Instance.new("UIStroke")
    listHeaderStroke.Color = Color3.fromRGB(45, 35, 65)
    listHeaderStroke.Thickness = 1
    listHeaderStroke.Parent = listHeader
    local listTitle = Instance.new("TextLabel")
    listTitle.Text = "PLAYERS"
    listTitle.Size = UDim2.new(1, 0, 1, 0)
    listTitle.BackgroundTransparency = 1
    listTitle.TextColor3 = Color3.fromRGB(120, 90, 180)
    listTitle.Font = Enum.Font.GothamBold
    listTitle.TextSize = 10
    listTitle.BorderSizePixel = 0
    listTitle.Parent = listHeader
    local listPanel = Instance.new("Frame")
    listPanel.Name = "ListPanel"
    listPanel.Size = UDim2.new(1, 0, 1, -32)
    listPanel.Position = UDim2.new(0, 0, 0, 32)
    listPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    listPanel.BorderSizePixel = 0
    listPanel.Parent = leftWrapper
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 5)
    listCorner.Parent = listPanel
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(45, 35, 65)
    listStroke.Thickness = 1
    listStroke.Parent = listPanel
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayerScroll"
    scrollFrame.Size = UDim2.new(1, -4, 1, -4)
    scrollFrame.Position = UDim2.new(0, 2, 0, 2)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 2
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 60, 160)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = listPanel
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scrollFrame
    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 3)
    listPad.PaddingLeft = UDim.new(0, 3)
    listPad.PaddingRight = UDim.new(0, 3)
    listPad.Parent = scrollFrame
    local statsPanel = Instance.new("Frame")
    statsPanel.Name = "StatsPanel"
    statsPanel.Size = UDim2.new(1, -181, 1, 0)
    statsPanel.Position = UDim2.new(0, 181, 0, 0)
    statsPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    statsPanel.BorderSizePixel = 0
    statsPanel.Parent = body
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 5)
    statsCorner.Parent = statsPanel
    local statsStroke = Instance.new("UIStroke")
    statsStroke.Color = Color3.fromRGB(45, 35, 65)
    statsStroke.Thickness = 1
    statsStroke.Parent = statsPanel
    local playerHeader = Instance.new("Frame")
    playerHeader.Name = "PlayerHeader"
    playerHeader.Size = UDim2.new(1, 0, 0, 52)
    playerHeader.BackgroundColor3 = Color3.fromRGB(20, 18, 27)
    playerHeader.BorderSizePixel = 0
    playerHeader.Parent = statsPanel
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 5)
    headerCorner.Parent = playerHeader
    local headerFill = Instance.new("Frame")
    headerFill.Size = UDim2.new(1, 0, 0.5, 0)
    headerFill.Position = UDim2.new(0, 0, 0.5, 0)
    headerFill.BackgroundColor3 = Color3.fromRGB(20, 18, 27)
    headerFill.BorderSizePixel = 0
    headerFill.Parent = playerHeader
    local headerAvatar = Instance.new("ImageLabel")
    headerAvatar.Name = "Avatar"
    headerAvatar.Size = UDim2.new(0, 38, 0, 38)
    headerAvatar.Position = UDim2.new(0, 8, 0, 8)
    headerAvatar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    headerAvatar.BorderSizePixel = 0
    headerAvatar.Image = ""
    headerAvatar.Parent = playerHeader
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = headerAvatar
    local headerName = Instance.new("TextLabel")
    headerName.Name = "PlayerName"
    headerName.Text = "Select a player →"
    headerName.Size = UDim2.new(1, -58, 0, 22)
    headerName.Position = UDim2.new(0, 54, 0, 8)
    headerName.BackgroundTransparency = 1
    headerName.TextColor3 = Color3.fromRGB(220, 220, 240)
    headerName.TextXAlignment = Enum.TextXAlignment.Left
    headerName.Font = Enum.Font.GothamBold
    headerName.TextSize = 13
    headerName.TextTruncate = Enum.TextTruncate.AtEnd
    headerName.Parent = playerHeader
    local headerUser = Instance.new("TextLabel")
    headerUser.Name = "PlayerUser"
    headerUser.Text = ""
    headerUser.Size = UDim2.new(1, -58, 0, 16)
    headerUser.Position = UDim2.new(0, 54, 0, 30)
    headerUser.BackgroundTransparency = 1
    headerUser.TextColor3 = Color3.fromRGB(110, 110, 160)
    headerUser.TextXAlignment = Enum.TextXAlignment.Left
    headerUser.Font = Enum.Font.Gotham
    headerUser.TextSize = 11
    headerUser.Parent = playerHeader
    local headerStatus = Instance.new("TextLabel")
    headerStatus.Name = "PlayerStatus"
    headerStatus.Text = ""
    headerStatus.Size = UDim2.new(0, 100, 0, 16)
    headerStatus.Position = UDim2.new(1, -108, 0, 19)
    headerStatus.BackgroundTransparency = 1
    headerStatus.TextColor3 = Color3.fromRGB(255, 200, 80)
    headerStatus.TextXAlignment = Enum.TextXAlignment.Right
    headerStatus.Font = Enum.Font.GothamBold
    headerStatus.TextSize = 11
    headerStatus.Parent = playerHeader
    local statsScroll = Instance.new("ScrollingFrame")
    statsScroll.Name = "StatsScroll"
    statsScroll.Size = UDim2.new(1, -8, 1, -58)
    statsScroll.Position = UDim2.new(0, 4, 0, 55)
    statsScroll.BackgroundTransparency = 1
    statsScroll.ScrollBarThickness = 2
    statsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 60, 160)
    statsScroll.BorderSizePixel = 0
    statsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    statsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    statsScroll.Parent = statsPanel
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.Padding = UDim.new(0, 4)
    statsLayout.Parent = statsScroll
    local statsPad = Instance.new("UIPadding")
    statsPad.PaddingTop = UDim.new(0, 4)
    statsPad.PaddingLeft = UDim.new(0, 2)
    statsPad.PaddingRight = UDim.new(0, 2)
    statsPad.Parent = statsScroll
    local placeholderLabel = Instance.new("TextLabel")
    placeholderLabel.Name = "Placeholder"
    placeholderLabel.Text = "← Click a player to view their stats"
    placeholderLabel.Size = UDim2.new(1, 0, 0, 40)
    placeholderLabel.BackgroundTransparency = 1
    placeholderLabel.TextColor3 = Color3.fromRGB(80, 80, 110)
    placeholderLabel.Font = Enum.Font.Gotham
    placeholderLabel.TextSize = 12
    placeholderLabel.Parent = statsScroll
    local statRows = {}
    local function createStatRow(parent, statDef)
        local row = Instance.new("Frame")
        row.Name = statDef.attr
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundColor3 = Color3.fromRGB(20, 18, 26)
        row.BorderSizePixel = 0
        row.Parent = parent
        local rowCorner = Instance.new("UICorner")
        rowCorner.CornerRadius = UDim.new(0, 4)
        rowCorner.Parent = row
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 2, 0, 16)
        accent.Position = UDim2.new(0, 0, 0.5, -8)
        accent.BackgroundColor3 = Color3.fromRGB(110, 60, 180)
        accent.BorderSizePixel = 0
        accent.Parent = row
        local accentCorner = Instance.new("UICorner")
        accentCorner.CornerRadius = UDim.new(0, 2)
        accentCorner.Parent = accent
        local labelText = Instance.new("TextLabel")
        labelText.Text = statDef.label
        labelText.Size = UDim2.new(0.55, -8, 1, 0)
        labelText.Position = UDim2.new(0, 8, 0, 0)
        labelText.BackgroundTransparency = 1
        labelText.TextColor3 = Color3.fromRGB(150, 140, 180)
        labelText.TextXAlignment = Enum.TextXAlignment.Left
        labelText.Font = Enum.Font.Gotham
        labelText.TextSize = 11
        labelText.Parent = row
        local valueText = Instance.new("TextLabel")
        valueText.Name = "Value"
        valueText.Text = "—"
        valueText.Size = UDim2.new(0.45, -6, 1, 0)
        valueText.Position = UDim2.new(0.55, 0, 0, 0)
        valueText.BackgroundTransparency = 1
        valueText.TextColor3 = Color3.fromRGB(210, 200, 240)
        valueText.TextXAlignment = Enum.TextXAlignment.Right
        valueText.Font = Enum.Font.GothamBold
        valueText.TextSize = 11
        valueText.Parent = row
        return row, valueText
    end
    for _, statDef in ipairs(STAT_DEFINITIONS) do
        local row, valueLabel = createStatRow(statsScroll, statDef)
        statRows[statDef.attr] = {row = row, valueLabel = valueLabel}
        row.Visible = false
    end
    local extraRows = {}
    local extraDefs = {
        { key = "Race",        label = "Race",        attr = nil },
        { key = "Status",      label = "Status",      attr = nil },
        { key = "SafeZone",    label = "Safe Zone",   attr = "SafeZone" },
    }
    for _, def in ipairs(extraDefs) do
        local row, valueLabel = createStatRow(statsScroll, {attr = def.key, label = def.label})
        extraRows[def.key] = {row = row, valueLabel = valueLabel}
        row.Visible = false
    end
    local activePlayerBtn = nil
    local function refreshStats()
        if not selectedInspectedPlayer or not selectedInspectedPlayer.Parent then
            return
        end
        local tp = selectedInspectedPlayer
        headerName.Text = tp.DisplayName
        local globalRank = tp:GetAttribute("P2WGlobalRank")
        local rankText = globalRank and (" • Global Ranking #" .. formatBigNumber(tonumber(toFullNumber(globalRank)))) or ""
        headerUser.Text = "@" .. tp.Name .. rankText
        headerAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tp.UserId .. "&width=48&height=48&format=png"
        local status = getPlayerStatus(tp)
        headerStatus.Text = status or ""
        if status then
            if table.find(statusGroups["Villains"], status) then
                headerStatus.TextColor3 = Color3.fromRGB(255, 80, 80)
            elseif table.find(statusGroups["Heroes"], status) then
                headerStatus.TextColor3 = Color3.fromRGB(80, 220, 80)
            else
                headerStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        placeholderLabel.Visible = false
        for _, statDef in ipairs(STAT_DEFINITIONS) do
            local entry = statRows[statDef.attr]
            if entry then
                local val = tp:GetAttribute(statDef.attr)
                entry.row.Visible = true
                if val ~= nil then
                    if statDef.attr == "TPM" then
                        local raceMultiplier = tp:GetAttribute("RaceMultiplier") or 1
                        local fusionTPMMult = tp:GetAttribute("FusionTPMMultiplier") or 1
                        val = val * raceMultiplier * fusionTPMMult * 2
                    end
                    local num = tonumber(toFullNumber(val))
                    entry.valueLabel.Text = formatBigNumber(num)
                else
                    entry.valueLabel.Text = "N/A"
                end
            end
        end
        local statusEntry = extraRows["Status"]
        if statusEntry then
            statusEntry.row.Visible = true
            statusEntry.valueLabel.Text = status or "Unknown"
            if status then
                if table.find(statusGroups["Villains"], status) then
                    statusEntry.valueLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                elseif table.find(statusGroups["Heroes"], status) then
                    statusEntry.valueLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
                else
                    statusEntry.valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
        end
        local szEntry = extraRows["SafeZone"]
        if szEntry then
            szEntry.row.Visible = true
            local inSZ = tp:GetAttribute("SafeZone")
            szEntry.valueLabel.Text = inSZ and "Yes" or "No"
            szEntry.valueLabel.TextColor3 = inSZ and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(200, 100, 100)
        end
    end
    local function clearStats()
        placeholderLabel.Visible = true
        headerName.Text = "Select a player →"
        headerUser.Text = ""
        headerStatus.Text = ""
        headerAvatar.Image = ""
        for _, entry in pairs(statRows) do
            entry.row.Visible = false
        end
        for _, entry in pairs(extraRows) do
            entry.row.Visible = false
        end
    end
    local function buildPlayerList()
        -- Clear existing buttons
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("Frame") then
                child:Destroy()
            end
        end
        local allPlayers = Players:GetPlayers()
        for _, p in ipairs(allPlayers) do
            local btn = Instance.new("TextButton")
            btn.Name = p.Name
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = Color3.fromRGB(20, 18, 26)
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            btn.Text = ""
            btn.Parent = scrollFrame
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            local thumb = Instance.new("ImageLabel")
            thumb.Size = UDim2.new(0, 24, 0, 24)
            thumb.Position = UDim2.new(0, 5, 0.5, -12)
            thumb.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            thumb.BorderSizePixel = 0
            thumb.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=48&height=48&format=png"
            thumb.Parent = btn
            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(1, 0)
            thumbCorner.Parent = thumb
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = p.DisplayName
            nameLabel.Size = UDim2.new(1, -36, 0, 18)
            nameLabel.Position = UDim2.new(0, 34, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(210, 210, 230)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = btn
            local userLabel = Instance.new("TextLabel")
            userLabel.Text = "@" .. p.Name
            userLabel.Size = UDim2.new(1, -36, 0, 13)
            userLabel.Position = UDim2.new(0, 34, 0, 19)
            userLabel.BackgroundTransparency = 1
            userLabel.TextColor3 = Color3.fromRGB(100, 100, 140)
            userLabel.TextXAlignment = Enum.TextXAlignment.Left
            userLabel.Font = Enum.Font.Gotham
            userLabel.TextSize = 10
            userLabel.TextTruncate = Enum.TextTruncate.AtEnd
            userLabel.Parent = btn
            if p == player then
                nameLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
                local youBadge = Instance.new("TextLabel")
                youBadge.Text = "YOU"
                youBadge.Size = UDim2.new(0, 28, 0, 13)
                youBadge.Position = UDim2.new(1, -31, 0.5, -6)
                youBadge.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
                youBadge.TextColor3 = Color3.fromRGB(200, 180, 255)
                youBadge.Font = Enum.Font.GothamBold
                youBadge.TextSize = 8
                youBadge.BorderSizePixel = 0
                youBadge.Parent = btn
                local badgeCorner = Instance.new("UICorner")
                badgeCorner.CornerRadius = UDim.new(0, 3)
                badgeCorner.Parent = youBadge
            end
            btn.MouseEnter:Connect(function()
                if selectedInspectedPlayer ~= p then
                    btn.BackgroundColor3 = Color3.fromRGB(26, 22, 36)
                end
            end)
            btn.MouseLeave:Connect(function()
                if selectedInspectedPlayer ~= p then
                    btn.BackgroundColor3 = Color3.fromRGB(20, 18, 26)
                end
            end)
            btn.MouseButton1Click:Connect(function()
                if activePlayerBtn then
                    activePlayerBtn.BackgroundColor3 = Color3.fromRGB(20, 18, 26)
                end
                selectedInspectedPlayer = p
                activePlayerBtn = btn
                btn.BackgroundColor3 = Color3.fromRGB(45, 30, 70)
                refreshStats()
            end)
        end
    end
    buildPlayerList()
    Players.PlayerAdded:Connect(function()
        buildPlayerList()
    end)
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        if selectedInspectedPlayer == leavingPlayer then
            selectedInspectedPlayer = nil
            activePlayerBtn = nil
            clearStats()
        end
        buildPlayerList()
    end)
    task.spawn(function()
        while screenGui and screenGui.Parent do
            if inspectorVisible and selectedInspectedPlayer and selectedInspectedPlayer.Parent then
                pcall(refreshStats)
            end
            task.wait(0.5)
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        inspectorVisible = false
        mainFrame.Visible = false
    end)
    mainFrame.Visible = false
end
MiscGroup:AddButton('Player Viewer', function()
    if not PlayerViewerGUI then
        buildPlayerViewerUI()
    end
    inspectorVisible = not inspectorVisible
    local mainFrame = PlayerViewerGUI and PlayerViewerGUI:FindFirstChild("MainFrame")
    if mainFrame then
        mainFrame.Visible = inspectorVisible
    end
end)
MiscGroup:AddToggle('threeDRenderToggle', {
    Text = '3D Rendering',
    Default = false,
    Tooltip = 'Toggles 3D rendering',
})
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddSlider("UICornerSlider", {
	Text = "Corner Radius",
	Default = 4,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(value)
		Window:SetCornerRadius(value)
	end
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "K", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)
task.spawn(function()
    while true do
        task.wait()
        if Toggles.threeDRenderToggle.Value then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        task.wait()
        if Toggles.LASToggle.Value then
            if not lasScreenGui then
                lasScreenGui = Instance.new("ScreenGui")
                lasScreenGui.Name = "LASGui"
                lasScreenGui.ResetOnSpawn = false
                lasScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                lasScreenGui.Parent = player.PlayerGui

                -- Create 2 video slots at random positions
                local slots = {}
                for i = 1, 2 do
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(0, 280, 0, 160)
                    frame.Position = UDim2.new(
                        math.random(0, 70) / 100,
                        0,
                        math.random(0, 70) / 100,
                        0
                    )
                    frame.BackgroundColor3 = Color3.new(0, 0, 0)
                    frame.BorderSizePixel = 0
                    frame.Parent = lasScreenGui

                    local video = Instance.new("VideoFrame")
                    video.Size = UDim2.new(1, 0, 1, 0)
                    video.Position = UDim2.new(0, 0, 0, 0)
                    video.BackgroundColor3 = Color3.new(0, 0, 0)
                    video.Looped = true
                    video.Video = videoUrls[i]
                    video.Parent = frame

                    task.spawn(function()
                        video.Loaded:Wait()
                        video:Play()
                    end)

                    slots[i] = { frame = frame, video = video }
                end

                -- Randomly swap videos and reposition on a timer
                task.spawn(function()
                    while lasScreenGui and Toggles.LASToggle.Value do
                        task.wait(math.random(3, 7))
                        if not lasScreenGui or not Toggles.LASToggle.Value then break end

                        for i = 1, 2 do
                            local slot = slots[i]

                            -- Random new position
                            slot.frame.Position = UDim2.new(
                                math.random(0, 70) / 100,
                                0,
                                math.random(0, 70) / 100,
                                0
                            )

                            -- Random new video
                            local newUrl = videoUrls[math.random(1, #videoUrls)]
                            slot.video:Pause()
                            slot.video.Video = newUrl
                            task.spawn(function()
                                slot.video.Loaded:Wait()
                                slot.video:Play()
                            end)
                        end
                    end
                end)
            end
        else
            if lasScreenGui then
                lasScreenGui:Destroy()
                lasScreenGui = nil
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.AreaToggle.Value and Options.ModeDropdown.Value == "FS" then
            if player then
                local fistStrength = tonumber(toFullNumber(player:GetAttribute("FistStrength")))

                local bestZone = nil
                for _, zone in ipairs(FSZones) do
                    if fistStrength >= zone.requirement then
                        bestZone = zone
                    end
                end
                if bestZone and bestZone.name == "10Qad" then
                    workspace.Exp1.MP.CanCollide = true
                else
                    workspace.Exp1.MP.CanCollide = false
                end
                local targetZone = bestZone or FSZones[1]
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = targetZone.cframe
                end
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.AreaToggle.Value and Options.ModeDropdown.Value == "BT" then
            local bodyToughness = tonumber(toFullNumber(player:GetAttribute("BodyToughness")))
            local bestZone = nil
            for _, zone in ipairs(BTZones) do
                if bodyToughness >= zone.requirement then
                    bestZone = zone
                end
            end
            local targetZone = bestZone or BTZones[1]
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = targetZone.cframe
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.AreaToggle.Value and Options.ModeDropdown.Value == "BT Death" then
            local bodyToughness = tonumber(toFullNumber(player:GetAttribute("BodyToughness")))
            local bestZone = nil
            for _, zone in ipairs(BTZones) do
                if bodyToughness >= (zone.requirement/19) then
                    bestZone = zone
                end
            end
            local targetZone = bestZone or BTZones[1]
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = targetZone.cframe
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.AreaToggle.Value and Options.ModeDropdown.Value == "PS" then
            local powerStrength = tonumber(toFullNumber(player:GetAttribute("PsychicPower")))
            local bestZone = nil
            for _, zone in ipairs(PSZones) do
                if powerStrength >= zone.requirement then
                    bestZone = zone
                end
            end
            local targetZone = bestZone or PSZones[1]
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = targetZone.cframe
            end
            local backpack = player.Backpack
            if not character then return end
            local psychicChar = character:FindFirstChild("PsychicPower")
            if not psychicChar then
                local backpackPsychic = backpack:FindFirstChild("PsychicPower")
                if backpackPsychic then
                    backpackPsychic.Parent = character
                end
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(1)
        if Toggles.NoAreaFeatureToggle.Value then
            local selectedModes = Options.NoAreaModeDropdown.Value
            if selectedModes["FS"] then
                game:GetService("ReplicatedStorage").RemoteEvents.FS_Train:FireServer()            
            end
            if selectedModes["BT"] then
                game:GetService("ReplicatedStorage").RemoteEvents.BT_Train:FireServer()            
            end
            if selectedModes["PS"] then
                local character = player.Character
                local backpack = player.Backpack
                if not character then return end
                local psychicChar = character:FindFirstChild("PsychicPower")
                if not psychicChar then
                    local backpackPsychic = backpack:FindFirstChild("PsychicPower")
                    if backpackPsychic then
                        backpackPsychic.Parent = character
                    end
                end
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(1.1)
        if Toggles.MultiplierToggle.Value then
            local selectedMultipliers = Options.MultiplierDropdown.Value
            if selectedMultipliers["FS"] then
                game:GetService("ReplicatedStorage").RemoteEvents.UpgradeMultiplier:FireServer("FistStrengthMultiplier")            
            end
            if selectedMultipliers["BT"] then
                game:GetService("ReplicatedStorage").RemoteEvents.UpgradeMultiplier:FireServer("BodyToughnessMultiplier")            
            end
            if selectedMultipliers["PP"] then
                game:GetService("ReplicatedStorage").RemoteEvents.UpgradeMultiplier:FireServer("PsychicPowerMultiplier")           
            end
            if selectedMultipliers["JF"] then
                game:GetService("ReplicatedStorage").RemoteEvents.UpgradeMultiplier:FireServer("JumpForceMultiplier")            
            end
            if selectedMultipliers["MS"] then
                game:GetService("ReplicatedStorage").RemoteEvents.UpgradeMultiplier:FireServer("MovementSpeedMultiplier")        
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(0.25)
        if Toggles.RaceRollToggle.Value then
            game:GetService("ReplicatedStorage").RemoteEvents.RollRace:FireServer()
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(0.1)
        if Toggles.KIAuraToggle.Value then
            local character = player.Character
            if character then
                local kiAura = character:FindFirstChild("KillingIntentAura")
                if kiAura and kiAura:IsA("BasePart") then
                    kiAura.Size = Vector3.new(Options.KIAuraSliderX.Value, 30, Options.KIAuraSliderY.Value)
                end
            end
        end
        if Library.Unloaded then break end
    end
end)
local highlightsTable = {}
local function updateESPNameLabel(targetPlayer, targetModel, highlightColour)
    local head = targetModel:FindFirstChild("Head")
    if not head then return end
    local existing = head:FindFirstChild("ESP_NameLabel")
    if not existing then
        existing = Instance.new("BillboardGui")
        existing.Name = "ESP_NameLabel"
        existing.Adornee = head
        existing.AlwaysOnTop = true
        existing.Size = UDim2.new(0, 200, 0, 30)
        existing.StudsOffset = Vector3.new(0, 2.5, 0)
        existing.ResetOnSpawn = false
        existing.Parent = head
        local label = Instance.new("TextLabel")
        label.Name = "NameText"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Parent = existing
    end
    local label = existing:FindFirstChild("NameText")
    if label then
        local displayName = targetPlayer.DisplayName
        local userName = targetPlayer.Name
        if displayName ~= userName then
            label.Text = displayName .. " (@" .. userName .. ")"
        else
            label.Text = "@" .. userName
        end
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    espLabelsTable[targetPlayer] = existing
end
local function removeESPNameLabel(targetPlayer)
    local existing = espLabelsTable[targetPlayer]
    if existing and existing.Parent then
        existing:Destroy()
    end
    espLabelsTable[targetPlayer] = nil
end
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.BTESPToggle.Value then
            local mainFS = tonumber(toFullNumber(player:GetAttribute("FistStrength")))
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    local targetName = targetPlayer.Name
                    local targetModel = workspace:FindFirstChild(targetName)
                    if targetModel then
                        local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
                        if targetHumanoid then
                            local targetBT = getTargetPlayerStat(targetPlayer, "BodyToughness")
                            if targetBT then
                                local highlightColour
                                if mainFS >= (targetBT * 10) then
                                    highlightColour = Color3.fromRGB(0, 255, 0)
                                elseif mainFS >= (targetBT * 5) then
                                    highlightColour = Color3.fromRGB(255, 255, 0)
                                elseif mainFS >= targetBT then
                                    highlightColour = Color3.fromRGB(255, 0, 0)
                                else
                                    highlightColour = Color3.fromRGB(0, 0, 0)
                                end
                                
                                local existingHighlight = targetModel:FindFirstChild("BT_ESP_Highlight")
                                if not existingHighlight then
                                    existingHighlight = Instance.new("Highlight")
                                    existingHighlight.Name = "BT_ESP_Highlight"
                                    existingHighlight.Adornee = targetModel
                                    existingHighlight.FillTransparency = 0.5
                                    existingHighlight.OutlineTransparency = 0
                                    existingHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    existingHighlight.Parent = targetModel
                                    existingHighlight.FillColor = highlightColour
                                end
                                existingHighlight.FillColor = highlightColour
                                existingHighlight.OutlineColor = highlightColour
                                highlightsTable[targetPlayer] = {type = "BT", highlight = existingHighlight}
                                updateESPNameLabel(targetPlayer, targetModel, highlightColour)
                            end
                        end
                    end
                end
            end
        else
            if Toggles.BTESPToggle.Value == false then
                for targetPlayer, highlightData in pairs(highlightsTable) do
                    if highlightData and highlightData.type == "BT" then
                        if highlightData.highlight and highlightData.highlight.Parent then
                            highlightData.highlight:Destroy()
                        end
                        highlightsTable[targetPlayer] = nil
                        removeESPNameLabel(targetPlayer)
                    end
                end
            end
        end
        if Library.Unloaded then 
            for targetPlayer, highlightData in pairs(highlightsTable) do
                    if highlightData and highlightData.type == "BT" then
                        if highlightData.highlight and highlightData.highlight.Parent then
                            highlightData.highlight:Destroy()
                        end
                        highlightsTable[targetPlayer] = nil
                        removeESPNameLabel(targetPlayer)
                    end
                end
            break 
        end
    end
end)
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.PSESPToggle.Value then
            local mainPS = tonumber(toFullNumber(player:GetAttribute("PsychicPower")))
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    local targetName = targetPlayer.Name
                    local targetModel = workspace:FindFirstChild(targetName)
                    if targetModel then
                        local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
                        if targetHumanoid then
                            local targetPS = getTargetPlayerStat(targetPlayer, "PsychicPower")
                            if targetPS then
                                local highlightColour
                                if mainPS >= (targetPS * 100) then
                                    highlightColour = Color3.fromRGB(0, 255, 0)
                                elseif mainPS >= (targetPS * 50) then
                                    highlightColour = Color3.fromRGB(255, 255, 0)
                                elseif mainPS >= targetPS then
                                    highlightColour = Color3.fromRGB(255, 0, 0)
                                else
                                    highlightColour = Color3.fromRGB(0, 0, 0)
                                end
                                local existingHighlight = targetModel:FindFirstChild("PS_ESP_Highlight")
                                if not existingHighlight then
                                    existingHighlight = Instance.new("Highlight")
                                    existingHighlight.Name = "PS_ESP_Highlight"
                                    existingHighlight.Adornee = targetModel
                                    existingHighlight.FillTransparency = 0.5
                                    existingHighlight.OutlineTransparency = 0
                                    existingHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    existingHighlight.Parent = targetModel
                                    existingHighlight.FillColor = highlightColour
                                end
                                existingHighlight.FillColor = highlightColour
                                existingHighlight.OutlineColor = highlightColour
                                highlightsTable[targetPlayer] = {type = "PS", highlight = existingHighlight}
                                updateESPNameLabel(targetPlayer, targetModel, highlightColour)
                            end
                        end
                    end
                end
            end
        else
            if Toggles.PSESPToggle.Value == false then
                for targetPlayer, highlightData in pairs(highlightsTable) do
                    if highlightData and highlightData.type == "PS" then
                        if highlightData.highlight and highlightData.highlight.Parent then
                            highlightData.highlight:Destroy()
                        end
                        highlightsTable[targetPlayer] = nil
                        removeESPNameLabel(targetPlayer)
                    end
                end
            end
        end
        if Library.Unloaded then 
            for targetPlayer, highlightData in pairs(highlightsTable) do
                    if highlightData and highlightData.type == "PS" then
                        if highlightData.highlight and highlightData.highlight.Parent then
                            highlightData.highlight:Destroy()
                        end
                        highlightsTable[targetPlayer] = nil
                        removeESPNameLabel(targetPlayer)
                    end
                end
            break 
        end
    end
end)
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.StatusESPToggle.Value then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    local targetName = targetPlayer.Name
                    local targetModel = workspace:FindFirstChild(targetName)
                    if targetModel then
                        local targetHumanoid = targetModel:FindFirstChild("Humanoid")
                        if targetHumanoid then
                            local targetStatus = getPlayerStatus(targetPlayer)
                            if targetStatus then
                                local highlightColour
                                if table.find(statusGroups["Villains"], targetStatus) then
                                    highlightColour = Color3.fromRGB(255, 0, 0)
                                elseif table.find(statusGroups["Heroes"], targetStatus) then
                                    highlightColour = Color3.fromRGB(0, 255, 0)
                                elseif table.find(statusGroups["Innocent"], targetStatus) then
                                    highlightColour = Color3.fromRGB(255, 255, 255)
                                else
                                    highlightColour = Color3.fromRGB(0, 0, 0)
                                end
                                local existingHighlight = targetModel:FindFirstChild("Status_ESP_Highlight")
                                if not existingHighlight then
                                    existingHighlight = Instance.new("Highlight")
                                    existingHighlight.Name = "Status_ESP_Highlight"
                                    existingHighlight.Adornee = targetModel
                                    existingHighlight.FillTransparency = 0.5
                                    existingHighlight.OutlineTransparency = 0
                                    existingHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    existingHighlight.Parent = targetModel
                                    existingHighlight.FillColor = highlightColour
                                end
                                existingHighlight.FillColor = highlightColour
                                existingHighlight.OutlineColor = highlightColour
                                highlightsTable[targetPlayer] = {type = "Status", highlight = existingHighlight}
                                updateESPNameLabel(targetPlayer, targetModel, highlightColour)
                            end
                        end
                    end
                end
            end
        else
            if Toggles.StatusESPToggle.Value == false then
                for targetPlayer, highlightData in pairs(highlightsTable) do
                    if highlightData and highlightData.type == "Status" then
                        if highlightData.highlight and highlightData.highlight.Parent then
                            highlightData.highlight:Destroy()
                        end
                        highlightsTable[targetPlayer] = nil
                        removeESPNameLabel(targetPlayer)
                    end
                end
            end    
        end
        if Library.Unloaded then 
            for targetPlayer, highlightData in pairs(highlightsTable) do
                    if highlightData and highlightData.type == "Status" then
                        if highlightData.highlight and highlightData.highlight.Parent then
                            highlightData.highlight:Destroy()
                        end
                        highlightsTable[targetPlayer] = nil
                        removeESPNameLabel(targetPlayer)
                    end
                end
            break
        end 
    end
end)
task.spawn(function()
    while true do
        wait(0.05)
        if Toggles.StatusBringerToggle.Value then
            local mainCharacter = player.Character
            if mainCharacter then
                local mainHRP = mainCharacter:FindFirstChild("HumanoidRootPart")
                if mainHRP then
                    local mainFS = tonumber(toFullNumber(player:GetAttribute("FistStrength")))
                    local selectedStatuses = Options.StatusBringerDropdown.Value
                    for _, targetPlayer in pairs(Players:GetPlayers()) do
                        if targetPlayer ~= player then
                            local targetName = targetPlayer.Name
                            local targetModel = workspace:FindFirstChild(targetName)
                            if targetModel then
                                local targetHumanoid = targetModel:FindFirstChild("Humanoid")
                                if targetHumanoid and targetHumanoid.Health > 0 then
                                    local targetStatus = getPlayerStatus(targetPlayer)
                                    local statusMatches = false
                                    for selectedCategory, _ in pairs(selectedStatuses) do
                                        if statusGroups[selectedCategory] then
                                            for _, actualStatus in ipairs(statusGroups[selectedCategory]) do
                                                if actualStatus == targetStatus then
                                                    statusMatches = true
                                                    break
                                                end
                                            end
                                        end
                                        if statusMatches then break end
                                    end
                                    if statusMatches then
                                        local inSafeZone = targetPlayer:GetAttribute("SafeZone")
                                        if inSafeZone then
                                        else
                                            local targetBT = getTargetPlayerStat(targetPlayer, "BodyToughness")
                                            if mainFS >= (targetBT * 5) then
                                                local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
                                                if targetHRP then
                                                    local forwardDirection = mainHRP.CFrame.LookVector
                                                    local newPosition = mainHRP.Position + forwardDirection * 1
                                                    targetHRP.CFrame = CFrame.new(newPosition, newPosition + forwardDirection)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait()
        if Toggles.NPCFarmToggle.Value then
            local mainCharacter = player.Character
            if mainCharacter then
                local mainHRP = mainCharacter:FindFirstChild("HumanoidRootPart")
                if mainHRP then
                    local selectedNPCs = Options.NPCFarmDropdown.Value
                    for _, npc in ipairs(workspace:GetChildren()) do
                        if selectedNPCs[npc.Name] then
                            local npcHealthObj = npc:FindFirstChild("NPC")
                            if npcHealthObj and npcHealthObj.Health > 0 then
                                local npcHRP = npc:FindFirstChild("Torso") or npc:FindFirstChild("HumanoidRootPart")
                                if npcHRP then
                                    local forwardDirection = mainHRP.CFrame.LookVector
                                    local newPosition = mainHRP.Position + forwardDirection * 2
                                    npcHRP.CFrame = CFrame.new(newPosition, newPosition + forwardDirection)
                                    npcHRP.Anchored = true
                                end
                            end
                        end
                    end
                end
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.NPCFarmToggle.Value then
        game:GetService("ReplicatedStorage").RemoteEvents.UseSkill:FireServer("Punch")
        end
        if Library.Unloaded then break end
    end
end)
local wasPlayerDead = false
local savedDeathPosition = nil
task.spawn(function()
    while true do
        wait(0.5)
        if Toggles.AutoRespawnToggle.Value then
            local respawnType = Options.AutoRespawnModeDropdown.Value
            local timer = Options.AutoRespawnSlider.Value
            if respawnType == "Normal Respawn" then
                pcall(function()
                    local char = player.Character
                    local humanoid = char and char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        wait(timer)
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RefreshCharacter"):FireServer()
                        end)
                        wait(0.1)
                        local respawnButton = player.PlayerGui:FindFirstChild("IntroGui")
                        if respawnButton then
                            respawnButton = respawnButton:FindFirstChild("PlayButton")
                            if respawnButton then
                                for _, connection in pairs(getconnections(respawnButton.Activated)) do
                                    connection.Function()
                                end
                                for _, connection in pairs(getconnections(respawnButton.MouseButton1Click)) do
                                    connection.Function()
                                end
                            end
                        end
                        local respawnWaitTime = 0
                        while respawnWaitTime < 3 do
                            local currentChar = player.Character
                            local currentHumanoid = currentChar and currentChar:FindFirstChild("Humanoid")
                            if currentHumanoid and currentHumanoid.Health > 0 then
                                break
                            end
                            task.wait(0.05)
                            respawnWaitTime = respawnWaitTime + 0.05
                        end
                    end
                end)
            elseif respawnType == "Last POS" then
                pcall(function()
                    local char = player.Character
                    local humanoid = char and char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health <= 0 then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            lastDeath = hrp.CFrame
                        end
                        wait(timer)
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RefreshCharacter"):FireServer()
                        end)
                        wait(0.1)
                        local respawnButton = player.PlayerGui:FindFirstChild("IntroGui")
                        if respawnButton then
                            respawnButton = respawnButton:FindFirstChild("PlayButton")
                            if respawnButton then
                                for _, connection in pairs(getconnections(respawnButton.Activated)) do
                                    connection.Function()
                                end
                                for _, connection in pairs(getconnections(respawnButton.MouseButton1Click)) do
                                    connection.Function()
                                end
                            end
                        end
                        local respawnWaitTime = 0
                        while respawnWaitTime < 3 do
                            local currentChar = player.Character
                            local currentHumanoid = currentChar and currentChar:FindFirstChild("Humanoid")
                            if currentHumanoid and currentHumanoid.Health > 0 then
                                break
                            end
                            task.wait(0.05)
                            respawnWaitTime = respawnWaitTime + 0.05
                        end
                        task.wait(0.2)
                        if lastDeath and player.Character then
                            local newHrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if newHrp then
                                newHrp.CFrame = lastDeath
                            end
                        end
                    end
                end)
            end
        end
        if Library.Unloaded then break end
    end
end)
task.spawn(function()
    while task.wait(1) do
        if Toggles.AntiAFKToggle.Value then
            pcall(function()
                if getconnections then
                    for _, connection in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do
                        if connection["Disable"] then
                            connection["Disable"](connection)
                        elseif connection["Disconnect"] then
                            connection["Disconnect"](connection)
                        end
                    end
                else
                    if not antiAFKConnection then
                        antiAFKConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                            local virtualUser = game:GetService("VirtualUser")
                            if virtualUser then
                                virtualUser:CaptureController()
                                virtualUser:ClickButton2(Vector2.new())
                            end
                        end)
                    end
                end
            end)
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
        if Library.Unloaded then break end
    end
end)
Library:OnUnload(function()
    print('Unloaded!')
    Library.Unloaded = true
    local totalSecs = math.floor(tick() - sessionStart)
    local finalDur = string.format("%02d:%02d:%02d",
        math.floor(totalSecs / 3600),
        math.floor((totalSecs % 3600) / 60),
        totalSecs % 60
    )
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end)
    pcall(function()
        local existing = loadSavedStats() or {}
        existing.lastSessionDuration = finalDur
        writefile(DATA_FILE, HttpService:JSONEncode(existing))
    end)
    if PlayerViewerGUI then
        PlayerViewerGUI:Destroy()
        PlayerViewerGUI = nil
    end
end)
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "" })
ThemeManager:SetFolder("VyxHub")
SaveManager:SetFolder("VyxHub/SPTSLegends")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

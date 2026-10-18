 
local BASE = "https://raw.githubusercontent.com/android9009/gamesense-rust/main/"
assert(type(loadstring) == "function", "Gamesense requires loadstring support")

local function fetch(path)
    local ok, body = pcall(function() return game:HttpGet(BASE .. path, true) end)
    if not ok then error("[Gamesense] Download failed: " .. path .. "\n" .. tostring(body), 0) end
    if type(body) ~= "string" or body == "" then
        error("[Gamesense] Empty response: " .. path, 0)
    end
    if body:match("^%s*404:") or body:match("^%s*<") then
        error("[Gamesense] Missing file or invalid response: " .. BASE .. path
            .. "\nUpload the unpacked files to the repository root. Response: " .. body:sub(1, 160), 0)
    end
    return body
end

 
local manifest = {
    ui = "gamesense.lua",
    sources = {
        "modules/core.lua",
        "modules/chams_layers.lua",
        "modules/visuals.lua",
        "modules/rage.lua",
        "modules/antiaim.lua",
        "modules/backtrack.lua",
        "modules/esp.lua",
        "modules/players.lua",
        "modules/movement.lua",
        "modules/misc.lua",
        "modules/legit.lua",
        "modules/exports.lua",
    },
}
local uiSource = fetch(manifest.ui)
local chunks = {"local __GS_UI = ...\n"}
local sourceMap, currentLine = {}, 2
for _, path in ipairs(manifest.sources) do
    local source = fetch(path)
    local chunk = "\n-- SOURCE: " .. path .. "\n" .. source .. "\n"
    local _, newlines = chunk:gsub("\n", "")
    sourceMap[#sourceMap + 1] = {Path = path, First = currentLine + 2, Last = currentLine + newlines - 1}
    currentLine += newlines
    chunks[#chunks + 1] = chunk
end
local function describeError(err)
    local text = tostring(err)
    local line = tonumber(text:match("gamesense%-runtime:(%d+)"))
        or tonumber(text:match('gamesense%-runtime"%]:(%d+)'))
    if line then
        for _, source in ipairs(sourceMap) do
            if line >= source.First and line <= source.Last then
                return text .. "\nSource: " .. source.Path .. ":" .. (line - source.First + 1)
            end
        end
    end
    return text
end
 
local uiChunk, uiError = loadstring(uiSource, "@gamesense-ui")
assert(uiChunk, "[Gamesense] UI compilation failed: " .. tostring(uiError))
local runtimeChunk, runtimeError = loadstring(table.concat(chunks), "@gamesense-runtime")
assert(runtimeChunk, "[Gamesense] Runtime compilation failed: " .. describeError(runtimeError))

local Library
local ok, result = xpcall(function()
    Library = uiChunk()
    if not Library and getgenv then Library = getgenv().Library end
    assert(Library, "[Gamesense] UI did not return Library")
    return runtimeChunk(Library)
end, function(err)
    return debug.traceback(describeError(err), 2)
end)
if not ok then
    if Library and Library.Unload then pcall(function() Library:Unload() end) end
    error("[Gamesense] Startup failed:\n" .. tostring(result), 0)
end
if getgenv then
    getgenv().GamesenseRuntime = result
    table.insert(Library.UnloadHooks, function()
        if getgenv().GamesenseRuntime == result then getgenv().GamesenseRuntime = nil end
    end)
end
return result

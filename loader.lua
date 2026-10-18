-- Gamesense loader: upload this package to the ROOT of gamesense-rust/main.
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

-- Fixed source order: no JSON manifest or JSONDecode dependency.
local manifest = {
    ui = "gamesense.lua",
    sources = {
        "modules/core.lua",
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
for _, path in ipairs(manifest.sources) do
    chunks[#chunks + 1] = "\n-- SOURCE: " .. path .. "\n" .. fetch(path) .. "\n"
end
-- Compile ALL source before starting the UI or any runtime components.
local uiChunk, uiError = loadstring(uiSource, "@gamesense-ui")
assert(uiChunk, "[Gamesense] UI compilation failed: " .. tostring(uiError))
local runtimeChunk, runtimeError = loadstring(table.concat(chunks), "@gamesense-runtime")
assert(runtimeChunk, "[Gamesense] Runtime compilation failed: " .. tostring(runtimeError))

local Library
local ok, result = xpcall(function()
    Library = uiChunk()
    if not Library and getgenv then Library = getgenv().Library end
    assert(Library, "[Gamesense] UI did not return Library")
    return runtimeChunk(Library)
end, function(err)
    return debug.traceback(tostring(err), 2)
end)
if not ok then
    if Library and Library.Unload then pcall(function() Library:Unload() end) end
    error("[Gamesense] Startup failed:\n" .. tostring(result), 0)
end
if getgenv then getgenv().GamesenseRuntime = result end
return result

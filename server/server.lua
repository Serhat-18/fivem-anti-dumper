local QBCore = exports["qb-core"]:GetCoreObject()
local function _banPlayer(src, reason)
    MySQL.ready(function()
        MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(src), QBCore.Functions.GetIdentifier(src, 'license'), QBCore.Functions.GetIdentifier(src, 'discord'), QBCore.Functions.GetIdentifier(src, 'ip'), reason, 2147483647, 'cAntiDump System'
        })
    end)
end

local function doesFileExist(path)
    local file = io.open(path, "r")
    if file then io.close(file) return true else return false end
end

function BanPlayer(src, reason)
    _banPlayer(src, reason)
    TriggerEvent("qb-log:server:CreateLog", "cfbans", "Hileci Yasaklandı", "red", string.format("Kişi: %s Banlayan: %s Sebep: %s", GetPlayerName(src), "cAntiDump", reason), true)
    DropPlayer(src, ("XX Roleplay Sunucusundan Yasaklandınız! \n Sebep: %s. \n Yasağın Süresi (Gün): '2147483647' \n Bunun Hatalı Olduğunu Düşünüyorsanız Bizimle İletişime Geçiniz \n Contact: https://discord.gg/cfscripting"):format(reason))
end

function KickPlayer(src, reason)
    DropPlayer(src, reason)
end

RegisterNetEvent('cAntiDump:server:ScriptLoaded', function(name)
    local src = source
    local id = tostring(src)
    if not ResourcesQueue[id] then return BanPlayer(src, '[CF-GUARD] Paketi Dumplamaya Çalıştı') end
    if not ResourcesQueue[id].resources[name] then return BanPlayer(src, '[CF-GUARD] Paketi Dumplamaya Çalıştı') end
    if ResourcesQueue[id].loadedRes == name then
        ResourcesQueue[id].isLoading = false
        ResourcesQueue[id].resources[name].loaded = true
        Wait(1000)
        if not ResourcesQueue[id].isLoading then
            local find = FindWhereNotLoadedResources(id)
            if find then
                TriggerClientEvent(find.under, find.src, find.code)
                ResourcesQueue[id].isLoading = true
                ResourcesQueue[id].loadedRes = find.name
            end
        end
    end
end)

function FindWhereNotLoadedResources(id)
    for _, info in pairs(ResourcesQueue[id].resources) do
        if not info.loaded then return info end
    end
    return nil
end

function InsertQueue(src, underTrigger, code, name)
    local id = tostring(src)
    if not ResourcesQueue[id] then ResourcesQueue[id] = {isLoading = false, resources = {}, loadedRes = nil} end
    if not ResourcesQueue[id].resources[name] then
        ResourcesQueue[id].resources[name] = {under = underTrigger, code = code, name = name, src = src, id = tostring(src), loaded = false}
    end
    if not ResourcesQueue[id].isLoading then
        local find = FindWhereNotLoadedResources(id)
        if find then
            TriggerClientEvent(find.under, find.src, find.code)
            ResourcesQueue[id].isLoading = true
            ResourcesQueue[id].loadedRes = find.name
        end
    end
end

function LoadFile(path)
    if not doesFileExist(path) then
        return ''
    end
    local file = io.open(path, "r")
    local content = file:read("*a")
    io.close(file)
    return content
end
exports('KickPlayer', KickPlayer)
exports("LoadFile", LoadFile)
exports("BanPlayer", BanPlayer)
exports("InsertQueue", InsertQueue)
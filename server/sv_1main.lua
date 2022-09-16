local scriptName = "vrp_farm"
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CONEXOES ]
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
src = {}
Tunnel.bindInterface(scriptName,src)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
local isScriptLoading = false
local items = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ QUERY ]
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("farm/get_markers", "SELECT * FROM vrp_markers WHERE tipo=@tipo AND ativo=1")
vRP.prepare("farm/get_groups", "SELECT * FROM vrp_farm_group WHERE ativo=1 ORDER BY item, id DESC")
vRP.prepare("farm/get_points", "SELECT * FROM vrp_farm WHERE ativo=1 ORDER BY rota, id DESC")
-----------------------------------------------------------------------------------------------------------------------------------------
--[ THREADS ]
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    loadServer()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farm:Server:Reload")
AddEventHandler("farm:Server:Reload", function()
    TriggerClientEvent("farm:Client:Reload", -1)
end)

RegisterServerEvent("farm:Server:ReloadMe")
AddEventHandler("farm:Server:ReloadMe", function()
    TriggerClientEvent("farm:Client:Reload", source)
end)

RegisterServerEvent("farm:Server:SetMarkers")
AddEventHandler("farm:Server:SetMarkers", function()
    TriggerClientEvent("farm:Client:SetMarkers", source, "farm", getFarmMarkers())
    TriggerClientEvent("farm:Client:SetMarkers", source, "craft", getCraftMarkers())
    TriggerClientEvent("farm:Client:SetMarkers", source, "policia", getPoliciaMarkers())
end)

AddEventHandler("admin:itens", function()
    getItems()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO LOCAL ]
-----------------------------------------------------------------------------------------------------------------------------------------
function getItemRecipes(items)
    local itemRecipes = {}
    if(items) then
        for k,v in pairs(items) do
            local itemInfo = src.getItem(v)
            local itemInfoRecipe = json.decode(itemInfo.recipe)
            local recipe = {}
            if(itemInfoRecipe) then
                for l, x in pairs(itemInfoRecipe) do
                    local item = src.getItem(x.id)
                    table.insert(recipe, {
                        id = item.id,
                        item = item.item,
                        qtd = x.qtd*itemInfo.packSize
                    })
                end
            end
            table.insert(itemRecipes, {
                id = itemInfo.id,
                item = itemInfo.item,
                descricao = itemInfo.descricao,
                packSize = itemInfo.packSize,
                recipe = recipe
            })
        end
    end
    return itemRecipes
end

function getItems()
    items = vRP.query("inventory/get_itens", {}) or {}
end

function getAllItems()
    return items
end

function loadServer()
    isScriptLoading = true
    getItems()
    setFarmMarkers()
    setCraftMarkers()
    setPoliciaMarkers()
    isScriptLoading = false
end

function getGroups(data, points, blip_id)
    local groups = {}
    for i=1, #data do
        local group = data[i]
        if(group.blip_id == blip_id) then
            groups[group.item] = getRotasFarm(points, group.id_group)
        end
    end
    return groups
end

function getRotasFarm(data, group)
    local rotas = {}
    for i=1, #data do
        local rota = data[i]
        if(rota.id_group == group) then
            local selRota = rotas[rota.rota] or {}
            table.insert(selRota, {id = rota.id, x = rota.x, y = rota.y, z = rota.z})
            rotas[rota.rota] = selRota
        end
    end
    return rotas
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------
function src.isLoading()
    return isScriptLoading
end

function src.checkPermission(permissao)
    local source = source
    local user_id = vRP.getUserId(source)
    return vRP.hasPermission(user_id, permissao..'.permissao')
end

function src.getItem(id)
    for i=1, #items do
        if(id == items[i].id) then return items[i] end
    end
    return ''
end

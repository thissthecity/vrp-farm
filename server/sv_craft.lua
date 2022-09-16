-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
local craftMarkers = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ QUERY ]
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
--[ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farm:Server:Producao")
AddEventHandler("farm:Server:Producao", function(item)
    local source = source
    local user_id = vRP.getUserId(source)
    local itemData = src.getItem(item)
    if(user_id and itemData) then
        if(checaEspaco(source, user_id, itemData)) then
            if(checaReceita(source, user_id, itemData)) then
                local buildTime = itemData.buildTime * 1000
                TriggerClientEvent("progress", source, buildTime, "Fabricando: <b>"..itemData.packSize.."x "..itemData.descricao.."</b>")
                TriggerClientEvent("VRP:Client:PlayAnim", source, false, {{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"}}, true)
                SetTimeout(buildTime, function()
                    TriggerClientEvent("VRP:Client:StopAnim", source, false)
                    TriggerClientEvent("farm:Client:DoneCrafting", source, itemData.item)
                    if(getItemsFromInventory(source, user_id, itemData)) then
                        vRP.giveInventoryItem(user_id, itemData.id, itemData.packSize)
                        TriggerClientEvent("Notify", source, "sucesso", "Fabricação concluída para: <b>1x "..itemData.descricao.."</b>.")
                    end
                end)
            else
                TriggerClientEvent("farm:Client:DoneCrafting", source, itemData.item)
            end
        else
            TriggerClientEvent("farm:Client:DoneCrafting", source, itemData.item)
        end
    else
        TriggerClientEvent("farm:Client:DoneCrafting", source, itemData.item)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO LOCAL ]
-----------------------------------------------------------------------------------------------------------------------------------------
function setCraftMarkers()
    local farms = vRP.query("farm/get_markers", {tipo = 'craft'}) or {}
    for i=1, #farms do
        local farm = farms[i]
        table.insert(craftMarkers, {
            id = farm.id,
            blip_id = farm.blip_id,
            nome = farm.nome,
            x = farm.x,
            y = farm.y,
            z = farm.z,
            marker = farm.marker,
            r = farm.r,
            g = farm.g,
            b = farm.b,
            a = farm.a,
            escalaX = farm.escalaX,
            escalaY = farm.escalaY,
            escalaZ = farm.escalaZ,
            upDown = farm.upDown,
            faceCamera = farm.faceCamera,
            rotate = farm.rotate,
            permissoes = farm.permissoes,
            recipes = getItemRecipes(json.decode(farm.categorias))
        })
    end
end

function getCraftMarkers()
    return craftMarkers
end

function checaEspaco(source, user_id, itemData)
    if(vRP.getInventoryWeight(user_id) + vRP.getItemWeight(itemData.id) * itemData.packSize <= vRP.getInventoryMaxWeight(user_id)) then
        return true
    else
        local recipeWeight = 0
        local itemRecipe = itemData.recipe
        if("string" == type(itemRecipe)) then
            itemRecipe = json.decode(itemRecipe)
        end
        for k,v in pairs(itemRecipe) do
            local itemWeight = vRP.getItemWeight(v.id)
            if(isCategoria(v.id, 'armamento')) then
                itemWeight = 0
            end
            recipeWeight = recipeWeight + itemWeight * v.qtd * itemData.packSize
        end
        if(vRP.getInventoryWeight(user_id) - recipeWeight + vRP.getItemWeight(itemData.id) <= vRP.getInventoryMaxWeight(user_id)) then
            return true
        end
    end
    TriggerClientEvent("Notify", source, "erro", "Espaço insuficiente na mochila.")
    return false
end

function checaReceita(source, user_id, itemData)
    local result = {}
    for k,v in pairs(json.decode(itemData.recipe)) do
        local qtd = vRP.getInventoryItemAmount(user_id, v.id) or 0
        if(qtd < v.qtd * itemData.packSize) then
            table.insert(result, {id = v.id, possui = qtd, precisa = v.qtd * itemData.packSize})
        end
    end
    if(#result > 0) then
        local message =
            "Erro ao fabricar: <b>"..itemData.packSize.."x "..itemData.descricao.."</b>,</br>"..
            "recursos disponíveis/necessários:</br>"
            for k,v in pairs(result) do
                local itm = src.getItem(v.id)
                message = message.."<b>"..itm.descricao.."</b> "..v.possui.."/"..v.precisa.."</br>" 
            end
        TriggerClientEvent("Notify", source, "negado", message, 10000)
    end
    return #result == 0
end

function getItemsFromInventory(source, user_id, itemData)
    local itemsRetracted = {}
    for k,v in pairs(json.decode(itemData.recipe)) do
        if(isCategoria(v.id, 'armamento')) then
            if(vRP.tryGetInventoryItem(user_id, v.id, v.qtd * itemData.packSize)) then
                table.insert(itemsRetracted, {id = v.id, qtd = v.qtd * itemData.packSize})
            else
                TriggerClientEvent("Notify", source, "negado", "Erro ao inserir item(ns) para produção.", 10000)
                for k,v in pairs(itemsRetracted) do
                    vRP.giveInventoryItem(user_id, v.id, v.qtd)
                end
                break
                return false
            end
        end
    end
    return true
end

function isCategoria(id, categoria)
    local item = src.getItem(id)
    return item.categoria ~= categoria
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------

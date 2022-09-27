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
AddEventHandler("farm:Server:Producao", function(data)
    local source = source
    local user_id = vRP.getUserId(source)
    local itemData = src.getItem(data.action)
    if(user_id and itemData) then
        if(checaEspaco(source, user_id, itemData, data.packSize)) then
            if(checaReceita(source, user_id, itemData, data.packSize)) then
                local buildMultiplier = data.packSize / 10000
                if(buildMultiplier < 1) then buildMultiplier = 1 end
                local buildTime = itemData.buildTime * buildMultiplier * 1000
                TriggerClientEvent("progress", source, buildTime, string.format("Fabricando: <b>%sx %s</b>", data.packSize, itemData.descricao))
                TriggerClientEvent("VRP:Client:PlayAnim", source, false, {{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"}}, true)
                SetTimeout(buildTime, function()
                    TriggerClientEvent("VRP:Client:StopAnim", source, false)
                    TriggerClientEvent("farm:Client:DoneCrafting", source, itemData.item)
                    if(getItemsFromInventory(source, user_id, itemData, data.packSize)) then
                        local message = ""
                        if(itemData.id == "dinheiro") then
                            vRP.giveMoney(user_id, data.packSize)
                            message = string.format("Lavagem concluída para: $%s", data.packSize)
                        else
                            vRP.giveInventoryItem(user_id, itemData.id, data.packSize)
                            message = string.format("Fabricação concluída para: <b>%sx %s</b>.", data.packSize, itemData.descricao)
                        end
                        TriggerClientEvent("Notify", source, "sucesso", message)
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

function checaEspaco(source, user_id, itemData, packSize)
    if(vRP.getInventoryWeight(user_id) + vRP.getItemWeight(itemData.id) * packSize <= vRP.getInventoryMaxWeight(user_id)) then
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
            recipeWeight = recipeWeight + itemWeight * v.qtd * packSize
        end
        if(vRP.getInventoryWeight(user_id) - recipeWeight + vRP.getItemWeight(itemData.id) <= vRP.getInventoryMaxWeight(user_id)) then
            return true
        end
    end
    TriggerClientEvent("Notify", source, "erro", "Espaço insuficiente na mochila.")
    return false
end

function checaReceita(source, user_id, itemData, packSize)
    local result = {}
    for k,v in pairs(json.decode(itemData.recipe)) do
        local qtd = vRP.getInventoryItemAmount(user_id, v.id) or 0
        if(qtd < parseInt(v.qtd * packSize)) then
            table.insert(result, {id = v.id, possui = qtd, precisa = v.qtd * packSize})
        end
    end
    if(#result > 0) then
        local message =
            "Erro ao fabricar: <b>"..packSize.."x "..itemData.descricao.."</b>,</br>"..
            "recursos disponíveis/necessários:</br>"
            for k,v in pairs(result) do
                local itm = src.getItem(v.id)
                message = message.."<b>"..itm.descricao.."</b> "..v.possui.."/"..v.precisa.."</br>" 
            end
        TriggerClientEvent("Notify", source, "negado", message, 10000)
    end
    return #result == 0
end

function getItemsFromInventory(source, user_id, itemData, packSize)
    local itemsRetracted = {}
    for k,v in pairs(json.decode(itemData.recipe)) do
        if(isCategoria(v.id, 'armamento')) then
            if(vRP.tryGetInventoryItem(user_id, v.id, v.qtd * packSize)) then
                table.insert(itemsRetracted, {id = v.id, qtd = v.qtd * packSize})
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

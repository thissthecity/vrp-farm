-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
farmMarkers = {}
--Garagem MERC ['x'] = 5168.52, ['y'] = -4673.65, ['z'] = 2.45
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ QUERY ]
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
--[ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("farm:Server:Payment")
AddEventHandler("farm:Server:Payment", function(item, blip_id)
    local itemGroup = src.getGroup(item, blip_id)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        math.randomseed(os.time())
        if(itemGroup.subItems) then
            local subItems = json.decode(itemGroup.subItems)
            if(subItems) then
                for k,v in pairs(subItems) do
                    local itm = src.getItem(v.id)
                    if(itm) then
                        givePaymentItem(source, user_id, itm, math.random(v.min, v.max))
                    else
                        TriggerEvent("VRP:Error", string.format("Erro em item: %s", v.id), GetCurrentResourceName())
                    end
                end
            else
                TriggerEvent("VRP:Error", string.format("Subitens de: '%s' com problemas.", item), GetCurrentResourceName())
                TriggerEvent("VRP:Error", vRP.dump(itemGroup.subItems))
            end
        else
            local itm = src.getItem(item)
            if(itm) then
                givePaymentItem(source, user_id, itm, math.random(itemGroup.minimo, itemGroup.maximo))
            else
                TriggerEvent("VRP:Error", string.format("Erro em item: %s", item), GetCurrentResourceName())
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO LOCAL ]
-----------------------------------------------------------------------------------------------------------------------------------------
function setFarmMarkers()
    local farms = vRP.query("farm/get_markers", {tipo = 'farm'}) or {}
    groups = vRP.query("farm/get_groups", {}) or {}
    local points = vRP.query("farm/get_points", {}) or {}
    for i=1, #farms do
        local farm = farms[i]
        table.insert(farmMarkers, {
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
            pontos = getGroups(groups, points, farm.blip_id)
        })
    end
end

function getFarmMarkers()
    return farmMarkers
end

function givePaymentItem(source, user_id, item, qtd)
    if(item) then
        if(vRP.getInventoryWeight(user_id) + (vRP.getItemWeight(item) * qtd) <= vRP.getInventoryMaxWeight(user_id)) then
            vRP.giveInventoryItem(user_id, item.id, qtd)
            TriggerClientEvent("Notify", source, "sucesso", "<b>Você Recebeu "..qtd.."x "..item.descricao.."</b>")
            return true
        else
            TriggerClientEvent("Notify", source, "negado", "<b>Mochila cheia</b>.")
        end
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------

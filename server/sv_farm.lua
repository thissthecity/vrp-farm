-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
farmMarkers = {}
local groups = {}
--Garagem MERC ['x'] = 5168.52, ['y'] = -4673.65, ['z'] = 2.45
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ QUERY ]
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
--[ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
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

function getGroup(item)
    for k,v in pairs(groups) do
        if(v.item == item) then return v end
    end
end

function getFarmMarkers()
    return farmMarkers
end

function givePaymentItem(source, user_id, item, qtd)
    if(vRP.getInventoryWeight(user_id) + (vRP.getItemWeight(item) * qtd) <= vRP.getInventoryMaxWeight(user_id)) then
        vRP.giveInventoryItem(user_id, item.id, qtd)
        TriggerClientEvent("Notify", source, "sucesso", "<b>Você Recebeu "..qtd.."x "..item.descricao.."</b>")
        return true
    else
        TriggerClientEvent("Notify", source, "negado", "<b>Mochila cheia</b>.")
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------
function src.checkFarmPayment(item)
    local itemGroup = getGroup(item)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        math.randomseed(os.time())
        if(itemGroup.subItems) then
            local subItems = json.decode(itemGroup.subItems)
            for k,v in pairs(subItems) do
                givePaymentItem(source, user_id, src.getItem(v.id), math.random(v.min, v.max))    
            end
        else 
            givePaymentItem(source, user_id, src.getItem(item), math.random(itemGroup.minimo, itemGroup.maximo))
        end
    end
end

function src.isLegal()
    local source = source
    local user_id = vRP.getUserId(source)
    if(user_id) then
        return vRP.hasPermission(user_id, 'mecdc.permissao') or vRP.hasPermission(user_id, 'dmdc.permissao') or vRP.hasPermission(user_id, 'dpdc.permissao')
    end
    return false
end

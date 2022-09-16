-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
policiaMarkers = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ COMANDOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ THREADS ]
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO LOCAL ]
-----------------------------------------------------------------------------------------------------------------------------------------
function setPoliciaMarkers()
    local farms = vRP.query("farm/get_markers", {tipo = 'rota'}) or {}
    local groups = vRP.query("farm/get_groups", {}) or {}
    local points = vRP.query("farm/get_points", {}) or {}
    for i=1, #farms do
        local farm = farms[i]
        local grupos = getGroups(groups, points, farm.blip_id)
        table.insert(policiaMarkers, {
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
            pontos = grupos
        })
    end
end

function getPoliciaMarkers()
    return policiaMarkers
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------
function src.checkPoliciaPayment()
    local money = math.random(30, 50)
    local user_id = vRP.getUserId(source)
    if(user_id) then
        vRP.giveBankMoney(user_id, money)
        TriggerClientEvent("Notify", source, "sucesso", "Bônus de patrulha recebido: $"..money, 5000)
    end
end

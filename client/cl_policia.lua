-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
policiaMarkers = {}
local blipPolicia = false
local blipSettings = {
    coordenadas = {x = 0, y = 0, z = 0},
    sprite = 1,
    color = 5,
    scale = 0.4,
    shortRange = false,
    route = true,
    text = "Ponto de Patrulha"
}
local selecionado = 0
local targetDistance = 0
local maxSpeed = 81
local id = false
local vehiclesPolicia = {
    "amg45",
    "cda500xt",
    "amarokpolicia",
    "cdacivic",
    "frontierpolicia"
}
local actualFarmType = nil
local actualRoute = nil
local actualPoint = nil
local actualFarm = nil
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CALLBACK ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("selRota", function(data, cb)
    if(data == "close") then
        ToggleActionMenu('policia')
    else
        actualFarmType = data
        local farmPoint = getRotaPoint()
        if(farmPoint) then
            servicoPolicia = true
            blipSettings.coordenadas = farmPoint
            blipPolicia = vRP.addGpsBlip(scriptName, blipSettings)
            TriggerEvent("Notify","sucesso","Rota iniciada.")
            ToggleActionMenu('policia')
        else
            TriggerEvent("Notify", "negado", "Erro ao iniciar rota.")
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ THREADS ]
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        if(servicoPolicia) then
            local ped = PlayerPedId()
            local rota = getActualFarm()
            local distance = GetDistanceBetweenCoords(GetEntityCoords(ped),rota.x,rota.y,rota.z,true)
            if(distance < 60) then
                sleepTimeMainThread = 1
                local corRota = getCor()
                DrawMarker(27,rota.x,rota.y,rota.z+0.1,0,0,0,0.0,0,0,1.5,1.5,1.4,corRota.r,corRota.g,corRota.b,corRota.a,1,0,0,1)
                if(distance <= 2.5) then
                    local vehicle = GetVehiclePedIsUsing(ped)
                    local vehSpeed = math.ceil(GetEntitySpeed(vehicle)*3.6)
                    if(vehSpeed <= maxSpeed) then
                        if(isValidVehicle(vehicle)) then
                            vRP.removeGpsBlip(scriptName, blipPolicia)
                            local farmPoint = getRotaPoint()
                            vSERVER.checkPoliciaPayment()
                            if(farmPoint ~= nil) then 
                                blipSettings.coordenadas = farmPoint
                                blipPolicia = vRP.addGpsBlip(scriptName, blipSettings)
                            else
                                servicoPolicia = false
                                TriggerEvent("Notify","informativo","Rota finalizada.")
                                sleepTimeMainThread = 1000
                                actualFarmType = nil
                                actualRoute = nil
                                actualPoint = nil
                            end
                        else
                            TriggerEvent("Notify", "negado", "Este veículo não deve ser utilizado na patrulha!</br>Bonificação não recebida!")
                        end
                    else
                        TriggerEvent("Notify","aviso","Patrulha não é corrida!<br>Chegou a "..vehSpeed.."km/h e não recebeu bonificação.", 3000)
                    end
                end
            end
        end
        Citizen.Wait(sleepTimeMainThread)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("farm:Client:Finalizar")
AddEventHandler("farm:Client:Finalizar", function()
    if(servicoPolicia) then
        servicoPolicia = false
        vRP.removeGpsBlip(scriptName, blipPolicia)
        actualFarmType = nil
        actualRoute = nil
        actualPoint = nil
        TriggerEvent("Notify","aviso","Você saiu de serviço.")
        sleepTimeMainThread = 1000
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO LOCAL ]
-----------------------------------------------------------------------------------------------------------------------------------------
function processRotas()
    for k, v in pairs(policiaMarkers) do
        local mkPol = policiaMarkers[k]
        if(not servicoPoliciaPolicia) then
            local ped = PlayerPedId()
            local distance = GetDistanceBetweenCoords(GetEntityCoords(ped),mkPol.x,mkPol.y,mkPol.z,true)
            if(distance <= 30 )then
                sleepTimeMainThread = 1
                local cor = {r=mkPol.r, g=mkPol.g, b=mkPol.b, a=mkPol.a}
                setCor(cor)
                local textoMarker = "PRESSIONE [~y~E~w~] PARA ACESSAR"
                if(atualizacaoPendente) then
                    cor = yellow
                    textoMarker = "ATUALIZACAO PENDENTE, AGUARDE..."
                elseif(atualizando) then
                    cor = red
                    textoMarker = "ATUALIZANDO DADOS, AGUARDE..."
                end
                DrawMarker(mkPol.marker, mkPol.x, mkPol.y, mkPol.z-1.0,
                    0, 0, 0, 0, 0, 0, mkPol.escalaX, mkPol.escalaY, mkPol.escalaZ,
                    cor.r, cor.g, cor.b, cor.a,
                    mkPol.upDown, mkPol.faceCamera, 0, mkPol.rotate)
                if(distance <= 1.2) then
                    vRP.drawTxt(textoMarker,4,0.5,0.93,0.50,255,255,255,180)
                    if(IsControlJustReleased(0,38) and vSERVER.checkPermission(mkPol.permissoes) and not(atualizacaoPendente or atualizando)) then
                        pontos = mkPol.pontos
                        ToggleActionMenu('policia')
                    end
                end
            end
        end
    end
end

function TogglePoliciaMenu()
	policiaMenuActive = not policiaMenuActive
	if policiaMenuActive then
		SetNuiFocus(true,true)
		SendNUIMessage({
            showmenu = true,
            type = 'policia',
            scriptName = scriptName,
            rotas = getRotaNames(pontos)
        })
	else
		SetNuiFocus(false)
		SendNUIMessage({
            hidemenu = true,
            type = 'policia'
        })
	end
end

function isValidVehicle(vehicle)
    for k,v in pairs(vehiclesPolicia) do
        if(IsVehicleModel(vehicle, GetHashKey(v))) then
            return true
        end
    end
    return false
end

function getRotaNames(pts)
    local farms = {}
    for k,v in pairs(pts) do
        table.insert(farms, {id = k, descricao = k, item = k})
    end
    return farms
end

function getActualFarm()
    return actualFarm
end

function setActualFarm(farm)
    actualFarm = farm
end

function getRotaPoint()
    local routes = pontos[actualFarmType] or {}
    print('a')
    if(#routes > 0) then
        local routeIndex = math.random(1, #routes)
        if(actualRoute) then routeIndex = actualRoute end
        actualRoute = routeIndex
        local routePoints = routes[routeIndex] or {}
        print('b')
        if(routePoints) then
            print('c')
            local pointIndex = actualPoint or 0
            if(pointIndex < #routePoints) then
                pointIndex = pointIndex + 1
            else
                pointIndex = -1
            end
            if(pointIndex > 0) then
                print('d')
                actualPoint = pointIndex
                local actualFarm = getPoint(routePoints, pointIndex)
                setActualFarm(actualFarm)
                print('e')
                return actualFarm
            end
        end
    end
    print('f')
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------

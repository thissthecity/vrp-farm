-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
local blip = nil
local blipSettings = {
    coordenadas = {x = 0, y = 0, z = 0},
    sprite = 1,
    color = 5,
    scale = 0.4,
    shortRange = false,
    route = true,
    text = "Ponto de Farm"
}
farmMarkers = {}
local selecionado = 0
local farmCount = 0
local farmLimit = 20
local actualFarmType = nil
local actualRoute = nil
local actualPoint = nil
local actualFarm = nil
local farmMenuActive = false
local cd = 1800
local cooldown = {}
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CALLBACK ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("selFarm",function(data,cb)
	if data == "close" then
		ToggleActionMenu('farm')
	else
        actualFarmType = data
        if(actualFarmType and cooldown[actualFarmType] and cooldown[actualFarmType] > 0) then
            TriggerEvent("Notify","negado","Você está em horário de descanso.</br> Retorne em: "..parseInt(cooldown[actualFarmType]).." segundo(s)")
        else
            local farmPoint = getFarmPoint(false)
            if(farmPoint) then
                if(vSERVER.isLegal()) then
                    cooldown[actualFarmType] = 0
                else    
                    cooldown[actualFarmType] = cd
                end
                servico = true
                blipSettings.coordenadas = farmPoint
                blip = vRP.addGpsBlip(scriptName, blipSettings)
                TriggerEvent("Notify","sucesso","Rota iniciada.")
                ToggleActionMenu('farm')
            else
                TriggerEvent("Notify", "negado", "Erro ao iniciar rota.")
            end
        end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ THREADS ]
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
        if(actualFarmType) then
            if cooldown[actualFarmType] > 0 then
                cooldown[actualFarmType] = cooldown[actualFarmType] - 1
            end
        end
	end
end)

Citizen.CreateThread(function()
	while true do
		if servico then
            local ped = PlayerPedId()
            local farm = getActualFarm()
            if(farm ~= nil) then
                local distance = GetDistanceBetweenCoords(GetEntityCoords(ped),farm.x,farm.y,farm.z,true)
                if distance <= 50 then
                    sleepTimeMainThread = 1
                    local corFarm = getCor()
                    DrawMarker(0,farm.x,farm.y,farm.z+0.1,0,0,0,0.0,0,0,1.5,1.5,1.4,corFarm.r,corFarm.g,corFarm.b,corFarm.a,1,0,0,1)
                    if distance <= 1.2 then
                        if IsControlJustReleased(0,38) then
                            vRP.removeGpsBlip(scriptName, blip)
                            local farmPoint = getFarmPoint(false)
                            vSERVER.checkFarmPayment(actualFarmType)
                            if(farmPoint ~= nil) then 
                                blipSettings.coordenadas = farmPoint
                                blip = vRP.addGpsBlip(scriptName, blipSettings)
                            else
                                servico = false
                                TriggerEvent("Notify","informativo","Rota finalizada.")
                                sleepTimeMainThread = 1000
                                actualFarmType = nil
                                actualRoute = nil
                                actualPoint = nil
                            end
                        end
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
    if(servico) then
        servico = false
        vRP.removeGpsBlip(scriptName, blip)
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
function processFarm()
    for k, v in pairs(farmMarkers) do
        local marker = farmMarkers[k]
        if(not servico) then
            local ped = PlayerPedId()
            local distance = GetDistanceBetweenCoords(GetEntityCoords(ped),marker.x,marker.y,marker.z,true)
            if(distance <= 30 )then
                sleepTimeMainThread = 1
                local cor = {r=marker.r, g=marker.g, b=marker.b, a=marker.a}
                setCor(cor)
                local textoMarker = "PRESSIONE [~y~E~w~] PARA ACESSAR"
                if(atualizacaoPendente) then
                    cor = yellow
                    textoMarker = "ATUALIZACAO PENDENTE, AGUARDE..."
                elseif(atualizando) then
                    cor = red
                    textoMarker = "ATUALIZANDO DADOS, AGUARDE..."
                end
                DrawMarker(marker.marker, marker.x, marker.y, marker.z-0.6,
                    0, 0, 0, 0, 0, 0, marker.escalaX, marker.escalaY, marker.escalaZ,
                    cor.r, cor.g, cor.b, cor.a,
                    marker.upDown, marker.faceCamera, 0, marker.rotate)
                if(distance <= .5) then
                    vRP.drawTxt(textoMarker,4,0.5,0.93,0.50,255,255,255,180)
                    if(IsControlJustReleased(0,38) and vSERVER.checkPermission(marker.permissoes) and not(atualizacaoPendente or atualizando)) then
                        pontos = marker.pontos
                        ToggleActionMenu('farm')
                    end
                end
            end
        end
    end
end

function ToggleFarmMenu()
	farmMenuActive = not farmMenuActive
	if farmMenuActive then
		SetNuiFocus(true,true)
		SendNUIMessage({
            showmenu = true,
            type = 'farm',
            scriptName = scriptName,
            farms = getFarmNames(pontos)
        })
	else
		SetNuiFocus(false)
		SendNUIMessage({
            hidemenu = true,
            type = 'farm'
        })
	end
end

function getFarmNames(pts)
    local farms = {}
    local itens = vSERVER.getItems()
    for k,v in pairs(pts) do
        local itemData = vSERVER.getItem(k)
        table.insert(farms, {id = k, descricao = itemData.descricao, item = itemData.item})
    end
    return farms
end

function getActualFarm()
    return actualFarm
end

function setActualFarm(farm)
    actualFarm = farm
end

function getFarmPoint(randomico)
    local routes = pontos[actualFarmType] or {}
    if(#routes > 0) then
        local routeIndex = math.random(1, #routes)
        if(actualRoute) then routeIndex = actualRoute end
        actualRoute = routeIndex
        local routePoints = routes[routeIndex] or {}
        if(routePoints) then
            local pointIndex = actualPoint or 0
            if(randomico) then
                if(farmCount < farmLimit) then
                    pointIndex = getRandomLocation(actualPoint or 1, #routePoints)
                else 
                    pointIndex = -1
                end
            else
                if(pointIndex < #routePoints) then
                    pointIndex = pointIndex + 1
                else
                    pointIndex = -1
                end
            end
            if(pointIndex > 0) then
                actualPoint = pointIndex
                local actualFarm = getPoint(routePoints, pointIndex)
                setActualFarm(actualFarm)
                return actualFarm
            else
                return nil
            end
        end
    end
    return nil
end

function getRandomLocation(atual, max)
    local novo = atual
    while(novo == atual) do
        novo = math.random(max)
    end
    return novo
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------

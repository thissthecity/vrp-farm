scriptName = "vrp_farm"
-----------------------------------------------------------------------------------------------------------------------------------------
--[ VRP ]
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CONEXAO ]
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface(scriptName)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
red = {r=255, g=0, b=0, a=255}
yellow = {r=255, g=255, b=0, a=255}
sleepTimeMainThread = 1000
atualizacaoPendente = false
atualizacaoSolicitada = false
atualizando = false
cor = {r=255,g=255,b=255,a=180}
pontos = {}
servico = false
servicoPolicia = false
-----------------------------------------------------------------------------------------------------------------------------------------
--[ COMANDOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("farm:finalizar","Finalizar o farm.","keyboard","f7")

RegisterCommand("farm:finalizar", function(source, args)
    TriggerEvent("farm:Client:Finalizar")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ CALLBACK ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeNui",function(data,cb)
	ToggleActionMenu(data)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ THREADS ]
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
	    local ped = PlayerPedId()
        if(servico or servicoPolicia) then
            vRP.drawTxt("PRESSIONE [~y~F7~w~] PARA FINALIZAR", 4, 0.270, 0.905, 0.45, 255, 255, 255, 200)
        end
        Citizen.Wait(1)
	end
end)

Citizen.CreateThread(function()
    vRP.cleanGpsBlips(scriptName)
    while vSERVER.isLoading() do
        Citizen.Wait(1)
    end
    TriggerServerEvent("farm:Server:Reload")
	while true do
        processFarm()
        processCraft()
        processRotas()
		Citizen.Wait(sleepTimeMainThread)
	end
end)

Citizen.CreateThread(function()
    while true do
        if(atualizacaoPendente and not(servico or atualizacaoSolicitada)) then
            TriggerServerEvent("farm:Server:SetMarkers")
            atualizacaoSolicitada = true
        end
        Citizen.Wait(1)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("farm:Client:Reload")
AddEventHandler("farm:Client:Reload", function()
    atualizacaoPendente = true
end)

RegisterNetEvent("farm:Client:SetMarkers", function(type, svMarkers)
    atualizacaoSolicitada = false
    atualizacaoPendente = false
    atualizando = true
    if(type == 'farm') then
        farmMarkers = svMarkers
    elseif(type == 'craft') then
        craftMarkers = svMarkers
    elseif(type == 'policia') then
        policiaMarkers = svMarkers
    end
    atualizando = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO LOCAL ]
-----------------------------------------------------------------------------------------------------------------------------------------
function ToggleActionMenu(data)
    if(data == 'farm') then
        ToggleFarmMenu()
    elseif(data == 'craft') then
        ToggleCraftMenu()
    elseif(data == 'policia') then
        TogglePoliciaMenu()
    end
end

function setCor(corMarker)
    cor = corMarker
end

function getCor()
    return cor
end

function getPoint(points, index)
    for i=1, #points do
        if(points[i].id == index) then
            return points[i]
        end
    end
    return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------

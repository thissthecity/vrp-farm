-----------------------------------------------------------------------------------------------------------------------------------------
-- [ VARIAVEIS ]
-----------------------------------------------------------------------------------------------------------------------------------------
craftMarkers = {}
craftMenuActive = false
crafting = false
recipes = {}
-----------------------------------------------------------------------------------------------
--[ CALLBACK ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("selCraft", function(data,cb)
	if data.action == "close" then
		ToggleActionMenu('craft')
	else
        TriggerServerEvent("farm:Server:Producao", data)
        crafting = true
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ THREADS ]
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        if(craftMenuActive) then
            DisableControlAction(2,199,true)
            DisableControlAction(2,200,true)
        end
        Citizen.Wait(1)
    end
end)

function processCraft()
    for k, v in pairs(craftMarkers) do
        local marker = craftMarkers[k]
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
                DrawMarker(marker.marker, marker.x, marker.y, marker.z-1.0,
                    0, 0, 0, 0, 0, 0, marker.escalaX, marker.escalaY, marker.escalaZ,
                    cor.r, cor.g, cor.b, cor.a,
                    marker.upDown, marker.faceCamera, 0, marker.rotate)
                if(distance <= 1.2) then
                    vRP.drawTxt(textoMarker,4,0.5,0.93,0.50,255,255,255,180)
                    if(IsControlJustReleased(0,38) and vSERVER.checkPermission(marker.permissoes) and not(atualizacaoPendente or atualizando)) then
                        recipes = marker.recipes
                        ToggleActionMenu('craft')
                    end
                end
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ EVENTOS ]
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("farm:Client:DoneCrafting")
AddEventHandler("farm:Client:DoneCrafting", function(data)
    SendNUIMessage({
        type = 'craft',
        enable = data,
    })
    crafting = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO LOCAL ]
-----------------------------------------------------------------------------------------------------------------------------------------
function ToggleCraftMenu()
    if(crafting) then return end
	craftMenuActive = not craftMenuActive
	if craftMenuActive then
		SetNuiFocus(true,true)
		SendNUIMessage({
            showmenu = true,
            type = 'craft',
            scriptName = scriptName,
            recipes = recipes
        })
	else
		SetNuiFocus(false)
		SendNUIMessage({
            hidemenu = true,
            type = 'craft'
        })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- [ FUNCOES ACESSO REMOTO ]
-----------------------------------------------------------------------------------------------------------------------------------------

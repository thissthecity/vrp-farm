var scriptName = "vrp_farm";
var uri = `http://${scriptName}/`;
var type = 'farm';

$(function() {
	var actionContainer = undefined;
	window.addEventListener('message',function(event) {
		var item = event.data;

        if(item.scriptName != undefined && item.scriptName != "") {
            scriptName = item.scriptName;
        }

        if(item.farms) {
            loadFarms(item.farms);
        }

        if(item.recipes) {
            loadItems(item.recipes);
        }

        if(item.rotas) {
            loadRotas(item.rotas);
        }

        if(item.type == 'farm') {
            type = 'farm';
            actionContainer = $("#content-farm");
        } else if(item.type == 'craft') {
            type = 'craft';
            actionContainer = $("#content-craft");
            if(item.enable) {
                $(`.craft-btn`).prop("disabled", false);
                $(`#btn-${item.enable}`).text('FABRICAR');
            }
        } else if(item.type == 'policia') {
            type = 'policia';
            actionContainer = $('#content-policia');
        }

        if(actionContainer != undefined) {
            if(item.showmenu) {
                actionContainer.show();
            }

            if(item.hidemenu) {
                actionContainer.hide();
            }
        }
	});

	document.onkeyup = function(data) {
		if(data.which == 27) {
			if(actionContainer != undefined && actionContainer.is(":visible")) {
				sendData("closeNui", type)
			}
		}
	};
})

function sendData(endpoint, requestData) {
	$.post(`${uri}${endpoint}`,JSON.stringify(requestData),function(responseData){});
}

function upperCase(texto) {
    let result = "" + texto;
    return result.toUpperCase();
}

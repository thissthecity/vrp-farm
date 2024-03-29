function loadItems(items) {
    $("#items-craft").empty();
    const sorted = items.sort((a, b) => (a.descricao > b.descricao) ? 1 : -1);
    let i = 1;
    for(item of sorted) {
        $("#items-craft").append(`
            <div class="craft-item-info">
                <div class="craft-item-foto">
                    <img src="https://img.thissthe.city/items/${item.item}.png">
                    <div class="craft-item-qtd"><span>x${item.packSize}</span></div>
                </div>
                <div class="craft-item-dados">
                    <div class="craft-item-title">
                        <div class="craft-item-nome">${upperCase(item.descricao)}</div>
                        <button class="craft-btn" onclick="disableAndSendData('btn-${item.item}', 'selCraft', '${item.id}', ${item.packSize})" id="btn-${item.item}">INICIAR</button>
                    </div>
                    <div class="craft-items-data" id="${item.item}-${i}">
                    </div>
                </div>
            </div>
        `);
        for(recipeItem of item.recipe) {
            $(`#${item.item}-${i}`).append(`
                <div class="craft-item-item">
                    <img src="https://img.thissthe.city/items/${recipeItem.item}.png">
                    <div class="craft-item-qtd"><span>x${recipeItem.qtd}</span></div>
                </div>
            `);
        }
        i++;
    }
}

function disableAndSendData(btn, endpoint, action, packSize) {
    $(`#${btn}`).text('FABRICANDO...');
    $(`.craft-btn`).prop("disabled", true);
    let data = {
        action,
        packSize
    }
    sendData(endpoint, data)
}

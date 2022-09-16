function loadRotas(rotas) {
    $("#menu-policia").empty();
    const sorted = rotas.sort((a, b) => (a.descricao > b.descricao) ? 1 : -1);
    for(item of sorted) {
        $("#menu-policia").append(`
            <div class="farm-item-info no-margin no-padding">
                <button class="btn-farm" onclick="sendData('selRota', '${item.id}')">
                    <div class="farm-item-foto">
                        <img src="https://img.thissthe.city/items/patrulha-${item.item}.png">
                    </div>
                    <span>${upperCase(item.descricao)}</span>
                </button>
            </div>
        `);
    }
}

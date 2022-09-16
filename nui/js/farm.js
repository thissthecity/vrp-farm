function loadFarms(farms) {
    $("#menu-farm").empty();
    const sorted = farms.sort((a, b) => (a.descricao > b.descricao) ? 1 : -1);
    for(item of sorted) {
        $("#menu-farm").append(`
            <div class="farm-item-info no-margin no-padding">
                <button class="btn-farm" onclick="sendData('selFarm', '${item.id}')">
                    <div class="farm-item-foto">
                        <img src="https://img.thissthe.city/items/${item.item}.png">
                    </div>
                    <span>${upperCase(item.descricao)}</span>
                </button>
            </div>
        `);
    }
}

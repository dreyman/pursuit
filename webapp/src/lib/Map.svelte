<script>
import { onMount } from 'svelte'

/** @type {import('./$types').PageProps} */
const { leaflet: Leaflet, route } = $props()
/** @type {any} */
let map
/** @type {HTMLElement} */
let map_el

onMount(async () => {
    map = init_leaflet_map(Leaflet)
    const latlons = []
    for (let i = 2; i < route.length; i += 2) {
        latlons.push(Leaflet.latLng(route[i], route[i + 1]))
    }
    draw_route(latlons)
})

/** @param {any[]} latlons */
function draw_route(latlons) {
    Leaflet.polyline(latlons, { color: 'red' }).addTo(map)
}

/** @param {any} Leaflet */
function init_leaflet_map(Leaflet) {
    const map = Leaflet.map(map_el, { zoomControl: false }).setView([48.95, 32.2], 11)
    Leaflet.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }).addTo(map)
    return map
}
</script>

<div class="map" bind:this={map_el}></div>

<style>
.map {
    width: 700px;
    height: 600px;
}
</style>

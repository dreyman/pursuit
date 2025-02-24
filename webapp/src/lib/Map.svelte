<script>
import { onMount } from 'svelte'

const { leaflet: Leaflet } = $props()
let map
/** @type {HTMLElement} */
let map_el

onMount(async () => {
    map = init_leaflet_map(Leaflet)
    let resp = await fetch('http://localhost:7070/1738503741/latlon')
    let blob = await resp.blob()
    let arrayBuffer = await blob.arrayBuffer()
    let floats = new Float32Array(arrayBuffer)
    const latlons = []
    for (let i = 2; i < floats.length; i += 2) {
        latlons.push([floats[i], floats[i + 1]])
    }
    draw_route(latlons)
})

function draw_route(latlons) {
    Leaflet.polyline(latlons, { color: 'red' }).addTo(map)
}

function read_len(bytes) {
    let len = 0
    for (let i = 3; i >= 0; i--) {
        num = num * 256 + bytes[i]
    }
    return len
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

<div class="map absolute w-full" bind:this={map_el}></div>

<style>
.map {
    /*    width: 500px;*/
    height: 600px;
}
</style>

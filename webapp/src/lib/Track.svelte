<script>
import { onMount } from 'svelte'
import Leaflet from 'leaflet'
import * as util from '$lib/util.js'
import * as api from '$lib/api.js'

/** @type {{id: number}} */
const { id } = $props()
/** @type {any} */
let map
/** @type {HTMLElement} */
let map_el
let failed_to_load = $state(false)

onMount(async () => {
    api.get_track(fetch, id).then(track_points => {
        if (!track_points) {
            failed_to_load = true
            return
        }
        const points = []
        for (let i = 1; i < track_points.length; i += 2) {
            points.push(Leaflet.latLng(track_points[i], track_points[i + 1]))
        }
        draw_track(points)
    })
    map = util.init_leaflet_map(Leaflet, map_el)
})

/** @param {any[]} points */
function draw_track(points) {
    Leaflet.polyline(points, { color: 'red' }).addTo(map)
}
</script>

{#if failed_to_load}
    <span class="text-red-500">FAILED TO LOAD TRACK</span>
{/if}
<div class="map" bind:this={map_el}></div>

<style>
.map {
    width: 600px;
    height: 600px;
}
</style>

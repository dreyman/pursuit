<script>
import { onMount } from 'svelte'
import Leaflet from 'leaflet'
import * as util from '$lib/util.js'
import * as api from '$lib/api.js'
import * as app from '$lib/app.js'

const { id, cfg } = $props()
let map
/** @type {HTMLElement} */
let map_el
let failed_to_load = $state(false)

const start_emoji = '🟢' // '▶️'
const finish_emoji = '🟥' // '🏁'

onMount(async () => {
    if (app.debug.use_map_placeholder) return
    api.get_track(fetch, id).then(track_points => {
        if (!track_points) {
            failed_to_load = true
            return
        }
        const points = []
        for (let i = 0; i < track_points.length; i += 2) {
            if (isNaN(track_points[i])) console.log(i)
            if (isNaN(track_points[i + 1])) console.log(i + 1)
            points.push(Leaflet.latLng(track_points[i], track_points[i + 1]))
        }
        draw_track(points)
    })
    map = util.initLeafletMap(Leaflet, map_el, cfg)
})

function draw_track(points) {
    Leaflet.polyline(points, { color: 'red' }).addTo(map)
    Leaflet.marker(points[0], {
        icon: Leaflet.divIcon({ className: 'emoji-marker', html: start_emoji }),
    }).addTo(map)
    Leaflet.marker(points[points.length - 1], {
        icon: Leaflet.divIcon({ className: 'emoji-marker', html: finish_emoji }),
    }).addTo(map)
}
</script>

{#if failed_to_load}
    <span class="text-red-500">FAILED TO LOAD TRACK</span>
{/if}
<div class="map" bind:this={map_el}></div>

<style>
.map {
    width: 100%;
    height: 600px;
    background: #a0a0a0;
}

/* this must be global, otherwise it doesn't work with leaflet */
:global {
    .emoji-marker {
        position: absolute;
        top: -7px;
        left: -4px;
        font-size: 1rem;
    }
}
</style>

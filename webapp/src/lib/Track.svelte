<script>
import { onMount, getContext } from 'svelte'
import Leaflet from 'leaflet'
import Marker from '$lib/Marker.svelte'
import * as api from '$lib/api.js'

const { id } = $props()
let map
let track_points = []
/* svelte-ignore non_reactive_update */
let start, finish
let failed_to_load = $state(false)
let mounted = $state(false)

onMount(async () => {
    map = getContext('map')
    if (!map) return
    api.getTrack(fetch, id).then(raw_track => {
        if (!raw_track) {
            failed_to_load = true
            return
        }
        for (let i = 0; i < raw_track.length; i += 2) {
            track_points.push(Leaflet.latLng(raw_track[i], raw_track[i + 1]))
        }
        start = track_points[0]
        finish = track_points[track_points.length - 1]
        drawTrack(track_points)
        mounted = true
    })
})

function drawTrack(points) {
    Leaflet.polyline(points, { color: 'red' }).addTo(map)
}
</script>

{#if failed_to_load}
    <span class="text-red-500">FAILED TO LOAD TRACK</span>
{/if}

{#if mounted}
    <Marker lat={start.lat} lon={start.lng} icon="🟢" />
    <Marker lat={finish.lat} lon={finish.lng} icon="🟥" />
{/if}

<style>
</style>

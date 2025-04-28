<script>
import { onMount, setContext } from 'svelte'
import Leaflet from 'leaflet'
import * as app from '$lib/app.js'

const { children, config, onclick, onmovestart } = $props()
let map
let mapelement
let mounted = $state(false)

onMount(async () => {
    if (app.debug.use_map_placeholder) return
    // fixme get rid of hardcoded default config
    const cfg = config || {
        center: [49.03836, 31.451241],
        zoom: 6.5,
    }
    map = initLeafletMap(Leaflet, mapelement, cfg)
    setContext('map', map)
    if (onclick) map.on('click', onclick)
    if (onmovestart) map.on('movestart', onmovestart)
    mounted = true
})

/**
 * @param {any} Leaflet
 * @param {HTMLElement} mapelement
 * @param {MapCfg} cfg
 * @returns {any} leaflet map object
 * */
export function initLeafletMap(Leaflet, mapelement, cfg) {
    const map = Leaflet.map(mapelement, {
        zoomControl: false,
        zoomSnap: 0.5,
    }).setView(cfg.center, cfg.zoom ?? 12)
    Leaflet.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }).addTo(map)
    if (cfg.bounds) {
        map.fitBounds(cfg.bounds)
    }
    return map
}
</script>

<div class="map" bind:this={mapelement}></div>
{#if mounted && children}
    {@render children()}
{/if}

<style>
.map {
    width: 100%;
    height: 100%;
    background: #777;
}
</style>

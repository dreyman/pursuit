<script>
import { goto } from '$app/navigation'
import Map from '$lib/Map.svelte'
import Marker from '$lib/Marker.svelte'

let { children } = $props()

let selected_point = $state(null)

function onMapClick(map_click) {
    const latlng = map_click.latlng
    selected_point = {
        lat: latlng.lat,
        lon: latlng.lng,
    }
    goto(`/map/@${latlng.lat.toFixed(6)},${latlng.lng.toFixed(6)}`, { replaceState: true })
}

function mapOnMoveStart() {
    selected_point = null
    goto('/map')
}
</script>

<div class="fixed h-full w-full">
    <Map onclick={onMapClick} onmovestart={mapOnMoveStart}>
        {#if selected_point}
            <Marker lat={selected_point.lat} lon={selected_point.lon} icon="🔴" />
        {/if}
    </Map>
</div>

{#if children}
    {@render children()}
{/if}

<style>
</style>

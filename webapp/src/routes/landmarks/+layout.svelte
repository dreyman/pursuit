<script>
import { setContext } from 'svelte'
import { goto } from '$app/navigation'
import Map from '$lib/Map.svelte'
import Marker from '$lib/Marker.svelte'
import Dialog from '$lib/Dialog.svelte'
import LandmarkForm from './LandmarkForm.svelte'

const { data, children } = $props()
let landmarks = $state(data.landmarks)
let new_landmark = $state(null)

setContext('remove', removeLandmark)

function onMapClick(event) {
    goto('/landmarks')
    const point = event.latlng
    new_landmark = {
        lat: point.lat,
        lon: point.lng,
    }
}

function onMarkerClick(id) {
    new_landmark = null
    goto('/landmarks/' + id)
}

function newLandmark(lm) {
    landmarks.push(lm)
    new_landmark = null
}

function removeLandmark(id) {
    const idx = landmarks.findIndex(lm => lm.id == id)
    if (idx == -1) {
        return
    }
    landmarks.splice(idx, 1)
}

function onMapMoveStart() {
    clear()
}

function pageOnKeyDown(e) {
    if (e.key == 'Escape') {
        clear()
    }
}

function clear() {
    new_landmark = null
    goto('/landmarks')
}
</script>

<svelte:window onkeydown={pageOnKeyDown} />

<div class="landmarks-map">
    <Map onclick={onMapClick} onmovestart={onMapMoveStart}>
        {#each landmarks as landmark (landmark.id)}
            <Marker
                lat={landmark.lat}
                lon={landmark.lon}
                icon="🟣"
                onclick={() => onMarkerClick(landmark.id)}
            />
        {/each}
    </Map>
</div>

{#if !!new_landmark}
    <Dialog title="Create" bg={false} top="1rem" onclose={() => (new_landmark = null)}>
        <LandmarkForm landmark={new_landmark} onsubmit={newLandmark} />
    </Dialog>
{/if}

{#if children}
    {@render children()}
{/if}

<style>
.landmarks-map {
    height: 100%;
    width: 100%;
}
</style>

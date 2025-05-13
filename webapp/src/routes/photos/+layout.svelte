<script>
import { setContext } from 'svelte'
import { goto } from '$app/navigation'
import Map from '$lib/Map.svelte'
import Marker from '$lib/Marker.svelte'
import Dialog from '$lib/Dialog.svelte'

const { data, children } = $props()
let photos = $state(data.photos)
// let landmark_form = $state(null)
// let selected_point = $state(null)

// setContext('removeLandmark', removeLandmark)

function onMapClick(map_click) {
    // selected_point = {
    //     lat: map_click.latlng.lat,
    //     lon: map_click.latlng.lng,
    // }
    // landmark_form = null
    // goto('/landmarks')
}

function onMarkerClick(id) {
    // selected_point = null
    // landmark_form = null
    goto('/photos/' + id)
}

// function newLandmark(lm) {
//     landmarks.push(lm)
//     landmark_form = null
// }

// async function removeLandmark(id) {
//     await Landmarks.remove(id)
//     const idx = landmarks.findIndex(lm => lm.id == id)
//     if (idx == -1) {
//         return
//     }
//     landmarks.splice(idx, 1)
// }

function pageOnKeyDown(e) {
    // if (e.key == 'Escape') clear()
}

function clear() {
    // landmark_form = null
    // selected_point = null
    // goto('/landmarks')
}

// function showLandmarkForm(point) {
//     clear()
//     landmark_form = {
//         lat: point.lat,
//         lon: point.lon,
//     }
// }
</script>

<svelte:window onkeydown={pageOnKeyDown} />

<div class="h-full w-full">
    <Map onclick={onMapClick} onmovestart={clear}>
        {#each photos as photo (photo.id)}
            {#if photo.derived_location}
                <Marker
                    lat={photo.derived_location.lat}
                    lon={photo.derived_location.lon}
                    icon="🟣"
                    onclick={() => onMarkerClick(photo.id)}
                />
            {/if}
        {/each}
    </Map>
</div>

<!-- {#if !!selected_point}
    <Dialog
        title={selected_point.lat.toFixed(6) + ', ' + selected_point.lon.toFixed(6)}
        bg={false}
        top="1rem"
        onclose={() => (selected_point = null)}
    >
        <div class="flex justify-center gap-2">
            <button onclick={() => showLandmarkForm(selected_point)}>Save</button>
        </div>
    </Dialog>
{:else if !!landmark_form}
    <Dialog title="Create" bg={false} top="1rem" onclose={() => (landmark_form = null)}>
        <LandmarkForm landmark={landmark_form} onsubmit={newLandmark} />
    </Dialog>
{/if} -->

{#if children}
    {@render children()}
{/if}

<style>
</style>

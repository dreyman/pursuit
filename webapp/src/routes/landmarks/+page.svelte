<script>
import Map from '$lib/Map.svelte'
import Marker from '$lib/Marker.svelte'

const { data } = $props()
</script>

<div class="landmarks-map">
    <Map>
        {#each data.landmarks as landmark}
            <Marker lat={landmark.lat} lon={landmark.lon} icon="🟣" />
        {/each}
    </Map>
</div>

<style>
.landmarks-map {
    height: 100%;
    width: 100%;
}
</style>

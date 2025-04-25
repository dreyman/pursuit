<script>
import { onMount, onDestroy, getContext } from 'svelte'
import Leafet from 'leaflet'

const { lat, lon, icon = '🟣', onclick } = $props()

let map
let leaflet_marker

onMount(() => {
    map = getContext('map')
    if (!map) return
    const options = {
        icon: Leafet.divIcon({ className: 'emoji-marker', html: icon }),
    }
    leaflet_marker = Leafet.marker([lat, lon], options)
    leaflet_marker.addTo(map)
    if (onclick) leaflet_marker.on('click', onclick)
})

onDestroy(() => {
    if (leaflet_marker) leaflet_marker.remove()
})
</script>

<style>
/* this must be global, otherwise it doesn't work with leaflet */
:global {
    .emoji-marker-lg {
        position: absolute;
        top: -15px;
        left: -10px;
        font-size: 1.5rem;
    }

    .emoji-marker {
        position: absolute;
        top: -7px;
        left: -4px;
        font-size: 1rem;
    }
}
</style>

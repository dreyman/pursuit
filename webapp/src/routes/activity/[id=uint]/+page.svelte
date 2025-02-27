<script>
import L from 'leaflet'
import Map from '$lib/Map.svelte'

const { data } = $props()
</script>

<Map leaflet={L} route={data.route} />

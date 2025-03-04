<script>
import Track from '$lib/Track.svelte'
import * as util from '$lib/util.js'

const { data } = $props()
const route = data.route
</script>

<div class="page mt-5 flex flex-col items-center gap-2">
    <h1>{route.name}</h1>
    <h2 class="date">{util.timestamp_to_string(route.stats.start * 1000)}</h2>
    <div class="flex gap-6">
        <span class="stats-item">{route.stats.distance / 100}km</span>
        <span class="stats-item">{util.seconds_to_string(route.stats.totalTime)}</span>
        <span class="stats-item">{util.seconds_to_string(route.stats.movingTime)}</span>
        <span class="stats-item"
            ><span class="font-bold"
                >{((36 * route.stats.distance) / route.stats.movingTime).toFixed(1)}</span
            >km/h</span
        >
    </div>
    <Track id={route.id} />
</div>

<style>
.page {
    /*    margin-top: 3rem;*/
}

h1 {
    font-size: 2rem;
    line-height: 2rem;
}

.date {
    font-size: 1.25rem;
}

.stats-item {
    font-size: 1rem;
}
</style>

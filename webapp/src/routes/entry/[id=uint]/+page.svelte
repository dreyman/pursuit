<script>
import Track from '$lib/Track.svelte'
import Time from '$lib/Time.svelte'
import Distance from '$lib/Distance.svelte'
import Icon from '$lib/icons/Icon.svelte'
import Edit from '$lib/icons/edit.svg.svelte'
import * as util from '$lib/util.js'

const { data } = $props()
const route = data.route

function onedit() {
    console.log('EDIT')
}
</script>

<div class="page mt-5 flex flex-col items-center gap-2">
    <h1 class="flex items-center gap-1">
        <span>{route.name}</span>
        <button onclick={onedit}><Icon Icon={Edit} size="lg" /></button>
    </h1>
    <div class="testr"></div>
    <h2 class="date">{util.timestamp_to_string(route.start * 1000)}</h2>
    <div class="flex gap-6">
        <Distance val={route.distance} />
        <Time seconds={route.total_time} />
        <Time seconds={route.moving_time} />
        <span class="text-xl"
            ><span class="bold">{((36 * route.distance) / route.moving_time).toFixed(1)}</span
            >km/h</span
        >
    </div>
    <Track id={route.id} />
</div>

<style>
.page {
    margin-top: 1rem;
}

h1 {
    font-size: 2rem;
    line-height: 2rem;
}

.bold {
    font-weight: bold;
}

.date {
    font-size: 1.25rem;
}
</style>

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

<div class="page mt-5 ml-10 flex flex-col gap-2">
    <h1 class="flex items-center gap-1">
        <span>{route.name}</span>
        <button onclick={onedit}><Icon Icon={Edit} size="lg" /></button>
    </h1>
    <h2 class="date">{util.timestamp_to_string(route.start_time * 1000)}</h2>
    <div class="flex gap-6">
        <Distance val={route.distance} />
        <Time seconds={route.total_time} />
        <Time seconds={route.moving_time} />
        <span class="text-xl"
            ><span class="bold">{(route.avg_speed / 1000).toFixed(1)}</span>km/h</span
        >
    </div>
    <Track id={route.id} />
</div>

<style>
.page {
    margin-top: 1rem;
}

h1 {
    font-size: 1.5rem;
    line-height: 2rem;
}

.bold {
    font-weight: bold;
}

.date {
    font-size: 1rem;
}
</style>

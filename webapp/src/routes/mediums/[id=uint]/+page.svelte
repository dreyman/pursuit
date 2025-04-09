<script>
import * as util from '$lib/util.js'
import * as app from '$lib/app.js'
import PursuitList from '$lib/PursuitList.svelte'
import Pace from '$lib/Pace.svelte'
import Distance from '$lib/Distance.svelte'

const { data } = $props()
const seconds_in_day = 86_400
const seconds_in_hour = 3_600

function timeAsString(seconds) {
    const full_days = Math.floor(seconds / seconds_in_day)
    let result = ''
    if (full_days > 4) {
        result += full_days + 'd'
        const hours = Math.floor((seconds - full_days * seconds_in_day) / seconds_in_hour)
        if (hours == 0) {
            let minutes = Math.floor((seconds % seconds_in_hour) / 60)
            result += ' ' + minutes + 'm'
        } else {
            result += ' ' + hours + 'h'
        }
        return result
    }
    return '' + Math.floor(seconds / seconds_in_hour) + 'h'
}
</script>

<div class="flex flex-col items-center gap-2">
    <h1 class="text-3xl">{data.medium.name}</h1>
    <div class="flex gap-8">
        <div class="stats-item flex flex-col items-center">
            <span class="text-sm text-gray-400">Distance</span>
            <Distance val={data.medium.distance} rounded={true} />
        </div>
        <div class="flex flex-col items-center">
            <span class="text-sm text-gray-400">Time</span>
            <span class="font-mono text-xl">{timeAsString(data.medium.time)}</span>
        </div>
        {#if data.medium.kind == app.MediumKind.bike}
            <div class="flex flex-col items-center">
                <span class="text-sm text-gray-400">Avg Speed</span>
                <span class="font-mono text-xl">
                    {util.avgSpeedKmh(data.medium.distance, data.medium.time).toFixed(2)}km/h
                </span>
            </div>
        {:else if data.medium.kind == app.MediumKind.shoes}
            <div class="flex flex-col items-center">
                <span class="text-sm text-gray-400">Avg Pace</span>
                <Pace distance={data.medium.distance} time={data.medium.time} />
            </div>
        {/if}
    </div>

    <section>
        <div class="section-title mb-1 flex items-center">
            <span class="grow-2"></span>
            <h2 class="mx-1 text-gray-400">Last pursuits</h2>
            <span class="grow-2"></span>
        </div>
        <PursuitList items={data.medium.last_pursuits} showicon={false} />
    </section>
</div>

<style>
.section-title span {
    border-top: 2px solid var(--grey-200);
}

.section-title h2 {
    font-size: 1rem;
    font-family: monospace;
    text-transform: uppercase;
}
</style>

<script>
import { getContext } from 'svelte'
import * as util from '$lib/util.js';
import PursuitList from '$lib/PursuitList.svelte'

const { data } = $props()
const seconds_in_day = 86_400
const seconds_in_hour = 3_600

function timeAsString(seconds) {
    const full_days = Math.floor(seconds / seconds_in_day)
    let result = ''
    if (full_days > 4) {
        result += full_days + ' days'
        const hours = Math.floor((seconds - full_days * seconds_in_day) / seconds_in_hour)
        if (hours == 0) {
            let minutes = Math.floor((seconds % seconds_in_hour) / 60)
            result += ' ' + minutes + ' minutes'
        } else {
            result += ' ' + hours + ' hours'
        }
        return result
    }
    return '' + Math.floor(seconds / seconds_in_hour)

}
</script>

<div class="flex flex-col items-center gap-4">
    <h1 class="text-3xl">{data.medium.name}</h1>
    <div class="flex gap-8">
        <div class="stats-item flex flex-col items-center">
            <span class="text-sm">Distance (km)</span>
            <span class="text-xl">
                {util.metersToKm(data.medium.distance)}
            </span>
        </div>
        <div class="flex flex-col items-center">
            <span class="text-sm">Time</span>
            <span class="text-xl">{timeAsString(data.medium.time)}</span>
        </div>
    </div>

    <section>
        <h2 class="text-lg">Last pursuits:</h2>
        <PursuitList items={data.medium.last_pursuits} />
    </section>
</div>

<style></style>
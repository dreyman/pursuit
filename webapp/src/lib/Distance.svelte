<script>
import * as util from '$lib/util.js'

const { val, size = 'xl', rounded = false } = $props()

let km = $derived(Math.floor(val / 1000))
let meters = $derived(val % 1000)
let rounded_val = $derived(rounded ? (val / 1000).toFixed(0) : 0)
</script>

<div class="text-{size} font-mono">
    {#if rounded}
        <span>{rounded_val}km</span>
    {:else}
        <span class="font-bold">{km}</span><span class="text-semi"
            >.{util.leftPad(Math.trunc(meters / 10), '0', 2)}km
        </span>
    {/if}
</div>

<style>
</style>

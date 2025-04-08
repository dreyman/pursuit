<script>
import * as util from '$lib/util.js'

/** @type {{val: number}} */
const { val, size = 'xl' } = $props()
let km = $derived(Math.floor(val / 1000))
let meters = $derived(val - km * 1000)
</script>

<div class="text-{size}">
    <span class="bold">{km}</span><span>.{util.leftPad(Math.trunc(meters / 10), '0', 2)}km</span>
</div>

<style>
.bold {
    font-weight: bold;
}
</style>

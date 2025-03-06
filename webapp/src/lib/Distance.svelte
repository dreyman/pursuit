<script>
import * as util from '$lib/util.js'

/** @type {{val: number}} */
const { val } = $props()
let km = $derived(Math.floor(val / 100))
let meters = $derived(val - km * 100)
</script>

<div class="text-xl">
    <span class="bold">{km}</span><span>.{util.leftPad(meters, '0', 2)}km</span>
</div>

<style>
.bold {
    font-weight: bold;
}
</style>

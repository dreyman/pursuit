<script>
import * as util from '$lib/util.js'

/** @type {{seconds: number}} */
const { seconds } = $props()
let h = $derived(Math.floor(seconds / 3600))
let m = $derived(Math.floor((seconds - h * 3600) / 60))
let s = $derived(seconds % 60)
</script>

<div class="text-xl">
    <span class="bold">{util.leftPad(h, '0', 2)}</span>:<span class="bold">{m}</span>:{s}
</div>

<style>
.bold {
    font-weight: bold;
}
</style>

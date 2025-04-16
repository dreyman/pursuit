<script>
import * as util from '$lib/util.js'

/** @type {{seconds: number}} */
const { seconds } = $props()
let h = $derived(Math.floor(seconds / 3600))
let m = $derived(Math.floor((seconds - h * 3600) / 60))
let s = $derived(seconds % 60)
</script>

<div class="font-mono text-xl">
    <span class="bold">{util.leftPad(h, '0', 2)}</span>:<span class="bold"
        >{util.leftPad(m, '0', 2)}</span
    >:<span class="text-semi">{util.leftPad(s, '0', 2)}</span>
</div>

<style>
.bold {
    font-weight: bold;
}
</style>

<script>
import * as util from '$lib/util.js'

const { distance, time, size = 'xl' } = $props()
let pace = util.minutesPerKm(distance, time)
let minutes = Math.floor(pace)
let seconds = Math.floor((pace - minutes) * 60)
</script>

<div class="text-{size}">
    <span>{util.leftPad(minutes, '0', 2)}:{util.leftPad(seconds, '0', 2)}</span>
</div>

<style>
.bold {
    font-weight: bold;
}
</style>

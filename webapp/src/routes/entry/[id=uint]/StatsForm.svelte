<script>
import * as api from '$lib/api.js'

const { id, onsubmit } = $props()

let payload = $state({
    min_speed: 0,
    max_time_gap: 5,
})
let loading = $state(false)
let invalid = $state({})

async function submit() {
    if (loading) return
    loading = true
    invalid = {}
    const [resp, err] = await api.Stats.recalc(fetch, id, payload)
    loading = false
    if (err != null) {
        invalid = err
        return
    }
    onsubmit(resp)
}
</script>

<div class="align-center mt-2 flex w-62 flex-col items-center gap-4">
    <label class="flex w-full flex-col">
        <span class:text-red-400={!!invalid.min_speed}>Min speed:</span>
        <span class="text-sm">{invalid.min_speed ?? ''}</span>
        <input bind:value={payload.min_speed} type="number" class="w-full" />
    </label>
    <label class="flex w-full flex-col">
        <span class:text-red-400={!!invalid.max_time_gap}>Max time gap:</span>
        <span class="text-sm">{invalid.max_time_gap ?? ''}</span>
        <input bind:value={payload.max_time_gap} type="number" class="w-full" />
    </label>

    <button class="submit-btn" onclick={submit}>submit</button>
</div>

<style>
input[type='number'] {
    max-width: 15rem;
}
</style>

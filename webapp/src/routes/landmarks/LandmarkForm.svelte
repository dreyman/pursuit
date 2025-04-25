<script>
import * as Landmarks from '$lib/landmarks.api.js'

const { landmark, onsubmit } = $props()

let invalid = $state({})
let loading = $state(false)

async function submit() {
    if (loading) return
    loading = true
    invalid = {}
    const [resp, err] = await Landmarks.create(landmark)
    loading = false
    if (err != null) {
        invalid = err
        return
    }
    onsubmit(landmark)
}
</script>

<div class="align-center mt-2 flex w-62 flex-col items-center gap-4">
    <label class="flex w-full flex-col">
        <span class:text-red-400={!!invalid.lat}>Latitude:</span>
        <span class="text-sm">{invalid.lat ?? ''}</span>
        <input bind:value={landmark.lat} type="text" class="w-full" />
    </label>
    <label class="flex w-full flex-col">
        <span class:text-red-400={!!invalid.lon}>Longitude:</span>
        <span class="text-sm">{invalid.lon ?? ''}</span>
        <input bind:value={landmark.lon} type="text" class="w-full" />
    </label>

    <label>
        <span class:text-red-400={!!invalid.name}>Name:</span>
        <span class="text-sm">{invalid.name ?? ''}</span>
        <input class="w-full" bind:value={landmark.name} type="text" />
    </label>
    <button class="submit-btn" onclick={submit}>save</button>
</div>

<style></style>

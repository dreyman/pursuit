<script>
import * as api from '$lib/api.js'

/** @type {{
        onsave: function(PursuitMetadata):void,
        id: number,
        pursuit: PursuitMetadata,
 }} */
const { id, pursuit, onsave } = $props()
let loading = $state(false)
let err = $state(null)
let form = $state({
    name: pursuit.name,
    description: pursuit.description,
})

async function submit() {
    if (loading) return
    loading = true
    let payload = {}
    if (form.name != pursuit.name) payload.name = form.name
    if (form.description != pursuit.description) payload.description = form.description
    if (Object.keys(payload).length > 0) {
        payload.id = id
        const updated = await api.updatePursuit(fetch, payload)
        loading = false
        if (updated) onsave(form)
        else err = 'Error'
    }
}
</script>

<div class="form mt-2 flex flex-col items-center gap-4">
    {#if err != null}
        <span class="text-red-500">{err}</span>
    {/if}
    <label>
        <span>Name:</span>
        <input bind:value={form.name} type="text" class="grow" />
    </label>
    <label>
        <span>Description:</span>
        <textarea bind:value={form.description} rows="5"></textarea>
    </label>
    <button class="submit-btn" onclick={submit}>save</button>
</div>

<style>
.form {
    width: 25rem;
}

label {
    width: 100%;
}

input,
textarea {
    width: 100%;
}
</style>

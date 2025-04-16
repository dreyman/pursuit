<script>
import { getContext } from 'svelte'
import * as app from '$lib/app.js'
import * as api from '$lib/api.js'

const { pursuit, onsave } = $props()

let loading = $state(false)
const null_medium_id = 0
const mediums = getContext('mediums')
const bikes = mediums.filter(m => m.kind == 'bike')
const shoes = mediums.filter(m => m.kind == 'shoes')
let err = $state(null)
let form = $state({
    name: pursuit.name,
    description: pursuit.description,
    kind: pursuit.kind,
    medium_id: pursuit.medium_id,
})

async function submit() {
    if (loading) return
    let payload = {}
    if (form.name != pursuit.name) payload.name = form.name
    if (form.description != pursuit.description) payload.description = form.description
    if (form.kind != pursuit.kind) payload.kind = form.kind
    if (form.medium_id != pursuit.medium_id) payload.medium_id = form.medium_id
    if (Object.keys(payload).length > 0) {
        loading = true
        const updated = await api.Pursuit.update(fetch, pursuit.id, payload)
        loading = false
        if (updated) onsave(payload)
        else err = 'Error'
    }
}

function changeKind(kind) {
    form.kind = kind
    form.medium_id = 0
}
</script>

<div class="form mt-2 flex w-120 flex-col items-center gap-4">
    {#if err != null}
        <span class="text-red-500">{err}</span>
    {/if}
    <label>
        <span>Name:</span>
        <input bind:value={form.name} type="text" />
    </label>
    <div class="flex items-center gap-2 self-start">
        <span>Type:</span>
        {#each app.kinds as kind}
            <button
                onclick={() => changeKind(kind)}
                class="option-btn"
                class:selected={form.kind == kind}>{kind}</button
            >
        {/each}
    </div>
    {#if form.kind == 'cycling'}
        <div class="flex items-center gap-2 self-start">
            <span>Bike:</span>
            <button
                onclick={() => (form.medium_id = null_medium_id)}
                class="option-btn"
                class:selected={form.medium_id == null_medium_id}>None</button
            >
            {#each bikes as bike}
                <button
                    onclick={() => (form.medium_id = bike.id)}
                    class="option-btn"
                    class:selected={form.medium_id == bike.id}
                    >{bike.id == app.default_bike_id ? 'None' : bike.name}</button
                >
            {/each}
        </div>
    {/if}
    {#if form.kind == 'running' || form.kind == 'walking'}
        <div class="flex items-center gap-2 self-start">
            <span>Shoes:</span>
            <button
                onclick={() => (form.medium_id = null_medium_id)}
                class="option-btn"
                class:selected={form.medium_id == null_medium_id}>None</button
            >
            {#if shoes.length == 0}Create{/if}
            {#each shoes as item}
                <button
                    onclick={() => (form.medium_id = item.id)}
                    class="option-btn"
                    class:selected={form.medium_id == item.id}
                    >{item.id == app.default_shoes_id ? 'None' : item.name}</button
                >
            {/each}
        </div>
    {/if}
    <label>
        <span>Description:</span>
        <textarea bind:value={form.description} rows="5"></textarea>
    </label>
    <button class="submit-btn" onclick={submit}>save</button>
</div>

<style>
label {
    width: 100%;
}

.option-btn {
    color: var(--light-grey);
}

.option-btn.selected {
    color: var(--pc);
    font-weight: bold;
}

input,
textarea {
    width: 100%;
}
</style>

<script>
import * as app from '$lib/app.js'
import * as api from '$lib/api.js'

const { onsave } = $props()

let payload = $state({
    name: '',
    kind: null,
})
let err = $state(null)

async function submit() {
    const new_medium = await api.Medium.create(payload)
    if (!new_medium) {
        err = 'Error'
        return
    }
    onsave(new_medium)
}
</script>

<div class="form mt-2 flex flex-col items-center gap-4">
    {#if err != null}
        <span class="text-red-500">{err}</span>
    {/if}
    <label>
        <span>Name:</span>
        <input bind:value={payload.name} type="text" />
    </label>
    <div class="flex items-center self-start">
        <span>Type:</span>
        {#each app.medium_kinds as kind}
            <button
                onclick={() => payload.kind = kind}
                class="option-btn"
                class:selected={payload.kind == kind}>{kind}</button
            >
        {/each}
    </div>
    <button class="submit-btn" onclick={submit}>save</button>
</div>

<style>
.form {
    width: 20rem;
}

label {
    width: 100%;
}

.option-btn {
    color: var(--light-grey);
}

.option-btn.selected {
    color: var(--primary-color);
    font-weight: bold;
}

input,
textarea {
    width: 100%;
}
</style>
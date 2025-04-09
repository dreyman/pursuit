<script>
import { getContext } from 'svelte'
import Icon from '$lib/Icon.svelte'
import Dialog from '$lib/Dialog.svelte'
import MediumForm from '$lib/MediumForm.svelte'

const { data } = $props()
let mediums = getContext('mediums')
let form_dialog_visible = $state(false)

function onsave(new_medium) {
    mediums.push(new_medium)
    form_dialog_visible = false
}
</script>

{#if data.mediums.length == 0}
    <h1>Nothing here yet</h1>
{/if}

{#if form_dialog_visible}
    <Dialog title="Create" onclose={() => (form_dialog_visible = false)}>
        <MediumForm {onsave} />
    </Dialog>
{/if}

<button onmousedown={() => (form_dialog_visible = true)} class="icon-btn create-btn">
    <Icon name="circle-plus" size={2} />
</button>

<div class="mt-4 flex flex-col gap-2">
    {#each mediums as medium}
        <a href="/mediums/{medium.id}" class="text-xl">{medium.name}</a>
    {/each}
</div>

<style>
.create-btn {
    padding: 0;
}
</style>

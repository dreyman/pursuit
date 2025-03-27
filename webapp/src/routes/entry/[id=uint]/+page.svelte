<script>
import Dialog from '$lib/Dialog.svelte'
import PursuitForm from '$lib/PursuitForm.svelte'
import Track from '$lib/Track.svelte'
import Time from '$lib/Time.svelte'
import Distance from '$lib/Distance.svelte'
import Icon from '$lib/icons/Icon.svelte'
import Edit from '$lib/icons/edit.svg.svelte'
import * as util from '$lib/util.js'

const { data } = $props()
const prst = $state(data.pursuit)
let metadata = $derived({
    name: prst.name,
    description: prst.description,
})
let edit_form_dialog_visible = $state(false)

/** @param {any} updated_fields */
function onsave(updated_fields) {
    Object.assign(prst, updated_fields)
    edit_form_dialog_visible = false
}
</script>

{#if edit_form_dialog_visible}
    <Dialog title="Edit" onclose={() => (edit_form_dialog_visible = false)}>
        <PursuitForm id={prst.id} pursuit={metadata} {onsave} />
    </Dialog>
{/if}

<div class="page mt-5 ml-10 flex flex-col gap-2">
    <h1 class="flex items-center gap-1">
        <span>{prst.name}</span>
        <button onclick={() => (edit_form_dialog_visible = true)} class="edit-btn"
            ><Icon Icon={Edit} size="lg" /></button
        >
    </h1>
    <h2 class="date">{util.timestamp_to_string(prst.start_time * 1000)}</h2>
    <div class="flex gap-6">
        <Distance val={prst.distance} />
        <Time seconds={prst.moving_time} />
        <Time seconds={prst.total_time} />
        <span class="text-xl"
            ><span class="bold">{(prst.avg_speed / 1000).toFixed(1)}</span>km/h</span
        >
    </div>
    <Track id={prst.id} cfg={util.mapCfg(prst)} />
</div>

<style>
.page {
    margin-top: 1rem;
}

h1 {
    font-size: 1.5rem;
    line-height: 2rem;
}

.bold {
    font-weight: bold;
}

.date {
    font-size: 1rem;
}

.edit-btn {
    color: var(--light-grey);
}
</style>

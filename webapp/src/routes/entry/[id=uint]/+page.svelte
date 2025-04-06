<script>
import { getContext } from 'svelte'
import Dialog from '$lib/Dialog.svelte'
import PursuitForm from '$lib/PursuitForm.svelte'
import Track from '$lib/Track.svelte'
import Time from '$lib/Time.svelte'
import Distance from '$lib/Distance.svelte'
import Icon from '$lib/Icon.svelte'
import * as util from '$lib/util.js'
import * as app from '$lib/app.js'

const { data } = $props()

const pursuit = $state(data.pursuit)
const mediums = getContext('mediums')
let medium = findMedium(pursuit.medium_id)
let medium_name = $state(medium.name)
let edit_form_dialog_visible = $state(false)

function onsave(updated_fields) {
    Object.assign(pursuit, updated_fields)
    if (updated_fields.medium_id !== undefined) {
        medium = findMedium(pursuit.medium_id)
        medium_name = medium.name
    }
    edit_form_dialog_visible = false
}

function findMedium(id) {
    for (let i = 0; i < mediums.length; i++)
        if (mediums[i].id == pursuit.medium_id)
            return mediums[i]
    return app.unknown_medium
}
</script>

{#if edit_form_dialog_visible}
    <Dialog title="Edit" onclose={() => (edit_form_dialog_visible = false)}>
        <PursuitForm id={pursuit.id} pursuit={pursuit} {onsave} />
    </Dialog>
{/if}

<div class="page mt-5 ml-10 flex flex-col items-center gap-1">
    <h1 class="flex items-center gap-1">
        <span>{pursuit.name}</span>
        <button onclick={() => (edit_form_dialog_visible = true)} class="icon-btn"
            ><Icon name="pencil" /></button
        >
    </h1>
    <h2 class="date">{util.timestampToString(pursuit.start_time * 1000)}</h2>
    <h3>{medium_name}</h3>
    <p>{pursuit.description}</p>
    <div class="flex gap-6">
        <Distance val={pursuit.distance} />
        <Time seconds={pursuit.moving_time} />
        <Time seconds={pursuit.total_time} />
        <span class="text-xl"
            ><span class="bold">{(pursuit.avg_speed / 1000).toFixed(1)}</span>km/h</span
        >
    </div>
    <Track id={pursuit.id} cfg={util.mapCfg(pursuit)} />
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
</style>

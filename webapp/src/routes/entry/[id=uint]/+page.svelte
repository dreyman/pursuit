<script>
import { getContext } from 'svelte'
import Dialog from '$lib/Dialog.svelte'
import PursuitForm from '$lib/PursuitForm.svelte'
import StatsForm from './StatsForm.svelte'
import Track from '$lib/Track.svelte'
import Map from '$lib/Map.svelte'
import Time from '$lib/Time.svelte'
import Distance from '$lib/Distance.svelte'
import Pace from '$lib/Pace.svelte'
import Icon from '$lib/Icon.svelte'
import * as util from '$lib/util.js'
import * as maputil from '$lib/maputil.js'
import * as app from '$lib/app.js'

const { data } = $props()

const pursuit = $state(data.pursuit)
const stats = $derived(pursuit.stats)
const mediums = getContext('mediums')

let medium = $state(findMedium(pursuit.medium_id))
let edit_form_dialog_visible = $state(false)
let stats_dialog_visible = $state(false)

function onsave(updated_fields) {
    Object.assign(pursuit, updated_fields)
    if (updated_fields.medium_id !== undefined) {
        medium = findMedium(pursuit.medium_id)
    }
    edit_form_dialog_visible = false
}

function findMedium(id) {
    for (let i = 0; i < mediums.length; i++) {
        if (mediums[i].id == id) return mediums[i]
    }
    return app.unknown_medium
}

function updateStats(updated_stats) {
    stats_dialog_visible = false
    Object.assign(pursuit.stats, updated_stats)
}
</script>

{#if edit_form_dialog_visible}
    <Dialog title="Edit" onclose={() => (edit_form_dialog_visible = false)}>
        <PursuitForm id={pursuit.id} {pursuit} {onsave} />
    </Dialog>
{/if}

{#if stats_dialog_visible}
    <Dialog title="Recalculate" onclose={() => (stats_dialog_visible = false)}>
        <StatsForm id={pursuit.id} onsubmit={updateStats} />
    </Dialog>
{/if}

<div class="mt-4 flex w-full flex-col items-center gap-1 md:w-180">
    <h1 class="relative w-full text-center">
        <span>{pursuit.name}</span>
        <button
            onclick={() => (edit_form_dialog_visible = true)}
            class="icon-btn absolute right-0 text-gray-500"><Icon name="pencil" /></button
        >
    </h1>
    <h2 class="text-semi">{util.timestampToFullDate(stats.start_time * 1000)}</h2>
    <h3>{app.mediumLabel(pursuit.kind)}: <a href="/mediums/{medium.id}">{medium.name}</a></h3>
    <section class="relative flex w-full flex-wrap items-center justify-center gap-6 px-12">
        <span class="flex gap-6">
            <div class="flex flex-col items-center">
                <span class="text-semi text-sm">Distance</span>
                <Distance val={stats.distance} />
            </div>
            <div class="flex flex-col items-center">
                <span class="text-semi text-sm">
                    {#if pursuit.kind == app.Kind.running}Pace{:else}Avg Speed{/if}
                </span>
                {#if pursuit.kind == app.Kind.running}
                    <Pace distance={stats.distance} time={stats.moving_time} />
                {:else}
                    <span class="font-mono text-xl"
                        ><span class="bold">{(stats.avg_speed / 1000).toFixed(1)}</span>km/h</span
                    >
                {/if}
            </div>
        </span>
        <span class="flex gap-6">
            <div class="flex flex-col items-center">
                <span class="text-semi text-sm">Moving Time</span>
                <Time seconds={stats.moving_time} />
            </div>
            <div class="flex flex-col items-center">
                <span class="text-semi text-sm">Total Time</span>
                <Time seconds={stats.total_time} />
            </div>
        </span>
        <button
            onclick={() => (stats_dialog_visible = true)}
            class="icon-btn absolute right-0 text-gray-500"
        >
            <Icon name="settings" />
        </button>
    </section>
    <p>{pursuit.description}</p>
    <div class="h-140 w-full">
        <Map config={maputil.mapCfg(stats)}>
            <Track id={pursuit.id} />
        </Map>
    </div>
</div>

<style>
.bold {
    font-weight: bold;
}
</style>

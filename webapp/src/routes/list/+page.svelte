<script>
import { page } from '$app/state'
import { goto } from '$app/navigation'
import * as api from '$lib/api.js'
import Icon from '$lib/Icon.svelte'
import Dialog from '$lib/Dialog.svelte'
import PursuitList from '$lib/PursuitList.svelte'

let { data } = $props()
let pursuits = $state(data.pursuits)

let params = null
let kind = $derived(page.url.searchParams.get('kind') ?? null)
let filters_dialog_visible = $state(false)
let load_more_visible = $state(true)
let filters = $state({
    distance: {
        min: null,
        max: null,
    },
})

$effect(() => {
    params = new URLSearchParams(page.url.search)
    filters = initFilters(params)
})

function setKind(val) {
    if (kind == val) return
    if (val == null) {
        params.delete('kind')
    } else {
        params.set('kind', val)
    }
    goto('?' + params.toString())
}

function applyFilters() {
    if (filters.distance.min == null) {
        params.delete('distance_min')
    } else {
        params.set('distance_min', filters.distance.min)
    }
    if (filters.distance.max == null) {
        params.delete('distance_max')
    } else {
        params.set('distance_max', filters.distance.max)
    }
    filters_dialog_visible = false
    goto('?' + params.toString())
}

function initFilters(params) {
    let dmin = params.get('distance_min')
    dmin = parseInt(dmin)
    if (isNaN(dmin)) dmin = null

    let dmax = params.get('distance_max')
    dmax = parseInt(dmax)
    if (isNaN(dmax)) dmax = null

    return {
        distance: {
            min: dmin,
            max: dmax,
        },
    }
}

async function loadMore() {
    params.set('offset', pursuits.length)
    const query_str = '?' + params.toString()
    params.delete('offset')
    const more = await api.Pursuit.list(fetch, query_str)
    if (more.length == 0) load_more_visible = false
    else pursuits.push(...more)
}
</script>

<ul class="btns-select mt-4">
    <button onmousedown={() => setKind(null)} class:active={kind == null}>all</button>
    <button onmousedown={() => setKind('cycling')} class:active={kind == 'cycling'}>cycling</button>
    <button onmousedown={() => setKind('running')} class:active={kind == 'running'}>running</button>
    <button onmousedown={() => setKind('walking')} class:active={kind == 'walking'}>walking</button>
    <button onmousedown={() => (filters_dialog_visible = true)}
        ><Icon name="adjustments-horizontal" /></button
    >
</ul>

<PursuitList items={pursuits} showicon={kind == null} className="mt-4" />
{#if load_more_visible}
    <button onclick={loadMore} class="my-2">load more</button>
{/if}

{#if filters_dialog_visible}
    <Dialog title="Filter" onclose={() => (filters_dialog_visible = false)}>
        <div class="form mt-2 flex flex-col items-center gap-4">
            <label class="flex items-center gap-2">
                <span>Distance:</span>
                <span>min:</span>
                <input bind:value={filters.distance.min} type="number" class="w-16" />
                <span>max:</span>
                <input bind:value={filters.distance.max} type="number" class="w-16" />
            </label>
            <button class="submit-btn" onclick={applyFilters}>apply</button>
        </div>
    </Dialog>
{/if}

<style>
</style>

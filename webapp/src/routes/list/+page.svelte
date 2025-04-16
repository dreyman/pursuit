<script>
import { page } from '$app/state'
import { goto } from '$app/navigation'
import Icon from '$lib/Icon.svelte'
import Dialog from '$lib/Dialog.svelte'
import PursuitList from '$lib/PursuitList.svelte'

let { data } = $props()

let params = null
let kind = $derived(page.url.searchParams.get('kind') ?? null)
let filters_dialog_visible = $state(false)
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
</script>

<ul class="filter-btns mb-4 flex">
    <button onmousedown={() => setKind(null)} class:active={kind == null}>all</button>
    <button onmousedown={() => setKind('cycling')} class:active={kind == 'cycling'}>cycling</button>
    <button onmousedown={() => setKind('running')} class:active={kind == 'running'}>running</button>
    <button onmousedown={() => setKind('walking')} class:active={kind == 'walking'}>walking</button>
    <button onmousedown={() => (filters_dialog_visible = true)}
        ><Icon name="adjustments-horizontal" /></button
    >
</ul>

<PursuitList items={data.pursuits} showicon={kind == null} />

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
.filter-btns button {
    border-radius: 0;
}

.filter-btns button:hover {
    background-color: var(--grey-200);
}

.filter-btns button.active {
    color: var(--link-color);
}

.filter-btns button:first-child {
    border-bottom-left-radius: var(--btn-radius);
    border-top-left-radius: var(--btn-radius);
}

.filter-btns button:last-child {
    border-bottom-right-radius: var(--btn-radius);
    border-top-right-radius: var(--btn-radius);
}
</style>

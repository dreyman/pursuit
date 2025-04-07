<script>
import { page } from '$app/state'
import { goto } from '$app/navigation'
import PursuitList from '$lib/PursuitList.svelte'

/** @type {import('./$types').PageProps} */
let { data } = $props()

let params = new URLSearchParams(page.url.search)
let kind = $derived(page.url.searchParams.get('kind') ?? null);

function setKind(val) {
    if (kind == val) return;
    if (val == null) {
        params.delete('kind')
    } else {
        params.set('kind', val)
    }
    goto('?' + params.toString())
}
</script>

<ul class="kind-btns flex mb-4">
    <button onclick={() => setKind(null)} class:active={kind == null}>all</button>
    <button onclick={() => setKind('cycling')} class:active={kind == 'cycling'}>cycling</button>
    <button onclick={() => setKind('running')} class:active={kind == 'running'}>running</button>
    <button onclick={() => setKind('walking')} class:active={kind == 'walking'}>walking</button>
</ul>

<PursuitList items={data.pursuits} />

<style>
.kind-btns button {
    border-radius: 0;
}
.kind-btns button.active {
    color: var(--primary-color);
}

.kind-btns button:first-child {
    border-bottom-left-radius: var(--btn-radius);
    border-top-left-radius: var(--btn-radius);
}

.kind-btns button:last-child {
    border-bottom-right-radius: var(--btn-radius);
    border-top-right-radius: var(--btn-radius);
}
</style>

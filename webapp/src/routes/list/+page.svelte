<script>
import { page } from '$app/state'
import { goto } from '$app/navigation'
import * as util from '$lib/util.js'

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
</ul>



<ul class="flex flex-col gap-4">
    {#each data.pursuits as pursuit}
        <li>
            <a href="/entry/{pursuit.id}">
                {pursuit.name}
            </a>
            <span>{util.timestampToString(pursuit.start_time * 1000)}</span>
        </li>
    {/each}
</ul>

<style>
.kind-btns button.active {
    color: var(--primary-color);
}
</style>

<script>
import { page } from '$app/state'
import { goto } from '$app/navigation'
import * as util from '$lib/util.js'
import * as app from '$lib/app.js'
import Icon from '$lib/Icon.svelte'

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

<ul class="flex flex-col gap-4">
    {#each data.pursuits as pursuit}
        <li class="flex items-center gap-1">
            {#if pursuit.kind == app.Kind.cycling}
                <Icon name="bike" size={1.3} />
            {:else if pursuit.kind == app.Kind.running || pursuit.kind == app.Kind.walking}
                <Icon name="run" size={1.3} />
            {:else}
                <Icon name="question-mark" size={1.3} />
            {/if}
            <a href="/entry/{pursuit.id}" class="text-lg">
                {pursuit.name}
            </a>
            <span class="text-sm text-gray-400">{util.timestampToString(pursuit.start_time * 1000)}</span>
        </li>
    {/each}
</ul>

<style>
.kind-btns button.active {
    color: var(--primary-color);
}
</style>

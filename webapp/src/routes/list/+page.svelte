<script>
import * as util from '$lib/util.js'
/** @type {import('./$types').PageProps} */
let { data } = $props()
const entries = data.entries
</script>

<ul class="flex flex-col gap-4">
    {#each entries as entry}
        <li>
            <a href="/entry/{entry.id}">
                {entry.name}
            </a>
            <span>{util.timestamp_to_string(entry.start_time * 1000)}</span>
        </li>
    {/each}
</ul>

<style>
</style>

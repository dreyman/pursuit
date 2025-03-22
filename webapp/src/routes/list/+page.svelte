<script>
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
        </li>
    {/each}
</ul>

<style>
</style>

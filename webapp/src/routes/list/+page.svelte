<script>
/** @type {import('./$types').PageProps} */
let { data: activities } = $props()

console.log('list: ', activities.items)
</script>

<ul>
    {#each activities.items as item}
        <li>
            <a href="/activity/{item}">
                {item}
            </a>
        </li>
    {/each}
</ul>

<style>
</style>

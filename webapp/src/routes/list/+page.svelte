<script>
/** @type {import('./$types').PageProps} */
let { data } = $props()
const routes = data.routes
console.log('ROUTES COUNT: ', routes.length)
</script>

<ul class="flex flex-col gap-4">
    {#each routes as route}
        <li>
            <a href="/entry/{route.id}">
                {route.name.substring(0, 10)}: {route.stats.distance / 100}km
            </a>
        </li>
    {/each}
</ul>

<style>
</style>

<script>
import { page } from '$app/state'
import { goto } from '$app/navigation'
import Dialog from '$lib/Dialog.svelte'

let page_title = $state(null)

$effect(() => {
    const lat = parseFloat(page.params.lat)
    const lon = parseFloat(page.params.lon)
    page_title = lat.toFixed(6) + ', ' + lon.toFixed(6)
})
</script>

{#if page_title}
    <Dialog title={page_title} bg={false} top="1rem" onclose={() => goto('/map')}>
        <div class="w-full">
            <a href={page.url.pathname + '/flybys'}>Flybys</a>
        </div>
    </Dialog>
{/if}

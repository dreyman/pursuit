<script>
import { page } from '$app/state'
import { goto } from '$app/navigation'
import * as util from '$lib/util.js'
import Dialog from '$lib/Dialog.svelte'
import PursuitList from '$lib/PursuitList.svelte'

const { data } = $props()

let page_title = $state(null)

$effect(() => {
    const lat = parseFloat(page.params.lat)
    const lon = parseFloat(page.params.lon)
    page_title = lat.toFixed(6) + ', ' + lon.toFixed(6)
})
</script>

{#if page_title}
    <Dialog title={page_title} bg={false} top="1rem" onclose={() => goto('/map')}>
        {#if data.flybys.length == 0}
            Nothing
        {:else}
            <div class="flex w-full flex-col gap-6">
                {#each data.flybys as flyby (flyby.timestamp)}
                    <div class="">
                        <span class="font-bold">{util.timestampToFullDate(flyby.timestamp)}</span>
                        <PursuitList items={[flyby.pursuit]} showicon={true} />
                    </div>
                {/each}
            </div>
        {/if}
    </Dialog>
{/if}

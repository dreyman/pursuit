<script>
import { getContext } from 'svelte'
import Dialog from '$lib/Dialog.svelte'
import BikeForm from '$lib/BikeForm.svelte'
import Distance from '$lib/Distance.svelte'
import Time from '$lib/Time.svelte'

const { data } = $props()
// let mediums = $state(data.mediums)
let mediums = getContext('mediums')
// let bike_form_dialog_visible = $state(false)

// function onsave(new_bike) {
//     bike_form_dialog_visible = false
//     bikes.unshift(new_bike)
// }
</script>

<!-- {#if bike_form_dialog_visible}
    <Dialog title="new bike" onclose={() => (bike_form_dialog_visible = false)}>
        <BikeForm {onsave} />
    </Dialog>
{/if} -->

{#if mediums.length == 0}
    <h1>Nothing here yet</h1>
{/if}

<!-- <button onclick={() => (bike_form_dialog_visible = true)} class="submit-btn">add</button> -->

{#each mediums as medium}
    <div class="flex gap-6">
        <span class="text-xl">{medium.name}</span>
    </div>
{/each}

<style>
h1 {
    font-size: 1.5rem;
}
</style>

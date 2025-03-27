<script>
import Dialog from '$lib/Dialog.svelte'
import BikeForm from '$lib/BikeForm.svelte'
import Distance from '$lib/Distance.svelte'
import Time from '$lib/Time.svelte'

const { data } = $props()
let bikes = $state(data.bikes)
let bike_form_dialog_visible = $state(false)

/** @param {NewBike} new_bike */
function onsave(new_bike) {
    bike_form_dialog_visible = false
    bikes.unshift(new_bike)
}
</script>

{#if bike_form_dialog_visible}
    <Dialog title="new bike" onclose={() => (bike_form_dialog_visible = false)}>
        <BikeForm {onsave} />
    </Dialog>
{/if}

{#if bikes.length == 0}
    <h1>No bikes</h1>
{/if}

<button onclick={() => (bike_form_dialog_visible = true)} class="submit-btn">add</button>

{#each bikes as bike}
    <div class="flex gap-6">
        <span class="text-xl">{bike.name}</span>
        <Distance val={bike.distance} />
        <Time seconds={bike.time} />
    </div>
{/each}

<style>
h1 {
    font-size: 1.5rem;
}
</style>

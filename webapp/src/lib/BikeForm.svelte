<script>
import * as api from '$lib/api.js'

/** @type {{
        onsave: function(NewBike):void
 }} */
const { onsave } = $props()
/** @type {NewBike} */
let bike = $state({
    name: '',
})

/** @param {NewBike} bike */
async function submit(bike) {
    const new_bike = await api.createBike(fetch, bike)
    if (new_bike) {
        onsave(new_bike)
    } else {
        // fixme handle failure
    }
}
</script>

<div class="mt-2 flex flex-col items-center gap-4">
    <label>
        <span>Name:</span>
        <input bind:value={bike.name} type="text" class="w-70" />
    </label>
    <button class="submit-btn" onclick={e => submit(bike)}>save</button>
</div>

<style></style>

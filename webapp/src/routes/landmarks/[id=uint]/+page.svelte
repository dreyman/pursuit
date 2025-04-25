<script>
import { getContext } from 'svelte'
import { goto } from '$app/navigation'
import Icon from '$lib/Icon.svelte'
import Dialog from '$lib/Dialog.svelte'
import * as Landmarks from '$lib/landmarks.api.js'

const { data } = $props()
const removeLandmark = getContext('remove')

async function remove() {
    await Landmarks.remove(data.landmark.id)
    removeLandmark(data.landmark.id)
    goto('/landmarks')
}
</script>

<Dialog title={data.landmark.name} bg={false} top="1rem" onclose={() => goto('/landmarks')}>
    <div class="flex flex-col items-center">
        <button onclick={remove} class="icon-btn">
            <Icon name="trash" />
        </button>
    </div>
</Dialog>

<style></style>

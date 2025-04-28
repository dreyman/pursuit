<script>
import { getContext } from 'svelte'
import { goto } from '$app/navigation'
import Icon from '$lib/Icon.svelte'
import Dialog from '$lib/Dialog.svelte'

const { data } = $props()
const removeLandmark = getContext('removeLandmark')

async function remove() {
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

<script>
import { getContext } from 'svelte'
import { goto } from '$app/navigation'
import * as Photos from '$lib/photos.api.js'
import * as util from '$lib/util.js'
import Icon from '$lib/Icon.svelte'
import Dialog from '$lib/Dialog.svelte'

const { data } = $props()
const full_date_str = $derived(util.timestampToFullDate(data.photo.timestamp))

// const removeLandmark = getContext('removeLandmark')

async function remove() {
    // removeLandmark(data.landmark.id)
    // goto('/landmarks')
}
</script>

<Dialog title={full_date_str} top="1rem" onclose={() => goto('/photos')}>
    <div class="flex flex-col items-center">
        <img src={Photos.photoSrc(data.photo.id)} alt={full_date_str} />
    </div>
</Dialog>

<style>
img {
    /*    width: 100%;*/
    max-width: 100%;
    max-height: 90dvh;
}
</style>

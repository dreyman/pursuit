<script>
import { goto } from '$app/navigation'
import * as cache from '$lib/shared_state.js'
import FileUpload from '$lib/FileUpload.svelte'

function onupload(entry) {
    cache.entries.push(entry)
    goto('/entry/' + entry.id)
}
</script>

<div class="mt-4">
    <FileUpload {onupload} />
</div>

<style></style>

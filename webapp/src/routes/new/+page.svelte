<script>
import { goto } from '$app/navigation'
import * as cache from '$lib/shared_state.js'
// fixme use bind:files

async function onFileUpload(e) {
    if (!e.target || !e.target.files || !e.target.files[0]) return
    const fd = new FormData()
    fd.append('file', e.target.files[0])
    try {
        const resp = await fetch('http://localhost:7070/api/gpsfile', {
            method: 'POST',
            body: fd,
        })
        if (resp.status == 200) {
            const entry = await resp.json()
            cache.entries.push(entry)
            goto('/entry/' + entry.id)
        } else {
            alert('Something went wrong')
        }
    } catch (e) {
        alert('Failed to upload file')
        // fixme handle error
        console.error(e)
    }
}
</script>

<div class="page">
    <input
        type="file"
        id="fileupload"
        accept=".fit, .fit.gz, .gpx, .gpx.gz"
        onchange={onFileUpload}
    />
</div>

<style>
</style>

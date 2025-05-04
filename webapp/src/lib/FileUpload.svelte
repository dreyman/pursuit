<script>
import * as api from '$lib/api.js'
// fixme use bind:files
const { onupload } = $props()

const supported_files = '.fit, .gpx, .fit.gz, .gpx.gz'

async function onFileUpload(e) {
    if (!e.target || !e.target.files || !e.target.files[0]) return
    const fd = new FormData()
    fd.append('file', e.target.files[0])
    try {
        const resp = await api.uploadFile(fd)
        if (resp.status == 200) {
            const resp_body = await resp.json()
            onupload(resp_body)
        } else {
            // fixme proper error handling
            alert('Something went wrong')
        }
    } catch (e) {
        alert('Failed to upload file')
        // fixme handle error
        console.error(e)
    }
}
</script>

<div class="flex flex-col items-center gap-2">
    <h1>Upload activity file: {supported_files}</h1>
    <input type="file" id="fileupload" accept={supported_files} onchange={onFileUpload} />
</div>

<style>
</style>

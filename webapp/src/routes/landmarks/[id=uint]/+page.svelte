<script>
import { goto } from '$app/navigation'
import Dialog from '$lib/Dialog.svelte'

const { data } = $props()
</script>

<Dialog title={data.landmark.name} bg={false} top="1rem" onclose={() => goto('/landmarks')}
></Dialog>

<style></style>

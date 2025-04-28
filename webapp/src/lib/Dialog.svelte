<script>
import Overlay from '$lib/Overlay.svelte'
import Icon from '$lib/Icon.svelte'

let { children, title, onclose, bg = true, top = '20%' } = $props()
</script>

<Overlay {top} {bg} {onclose}>
    <button class="icon-btn absolute top-0 right-0" onclick={onclose}>
        <Icon name="x" />
    </button>
    <header class="mb-4">
        <h1 class="text-center">{title}</h1>
    </header>
    {#if children}
        {@render children()}
    {/if}
</Overlay>

<style>
h1 {
    font-weight: bold;
    font-size: 1.25rem;
    line-height: 1.25rem;
    margin: 0 2rem;
}
</style>

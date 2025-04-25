<script>
import { scale, fade } from 'svelte/transition'
import Icon from '$lib/Icon.svelte'

let { children, title, onclose, bg = true, top = '20%' } = $props()
</script>

{#if bg}
    <!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_static_element_interactions -->
    <div class="dialog-bg" onclick={onclose}></div>
{/if}
<div
    class="dialog"
    style:top
    in:scale={{ duration: 100, start: 0.75 }}
    out:fade={{ duration: 100 }}
>
    <button class="icon-btn absolute top-0 right-0" onclick={onclose}>
        <Icon name="x" />
    </button>
    <header class="mb-4">
        <h1 class="text-center">{title}</h1>
    </header>
    {#if children}
        {@render children()}
    {/if}
</div>

<style>
.dialog-bg {
    z-index: 1100;
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
}

.dialog {
    z-index: 1101;
    background: #27282c;
    padding: 0.5rem 1rem;
    border-radius: 0.5rem;
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    box-shadow: var(--shadow-sm);
}

h1 {
    font-weight: bold;
    font-size: 1.25rem;
    line-height: 1.25rem;
    margin: 0 2rem;
}
</style>

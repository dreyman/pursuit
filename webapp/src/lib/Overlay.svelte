<script>
import { scale, fade } from 'svelte/transition'

let { children, bg = true, top = '20%', onclose = () => {} } = $props()
</script>

{#if bg}
    <!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_static_element_interactions -->
    <div class="overlay-bg" onclick={onclose}></div>
{/if}
<div
    class="overlay"
    style:top
    in:scale={{ duration: 100, start: 0.75 }}
    out:fade={{ duration: 100 }}
>
    {#if children}
        {@render children()}
    {/if}
</div>

<style>
.overlay-bg {
    z-index: 1100;
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
}

.overlay {
    position: absolute;
    z-index: 1101;
    background: #27282c;
    padding: 0.5rem 1rem;
    overflow-y: auto;
    border-radius: 0.5rem;
    /*left: 50%;
    transform: translateX(-50%);*/
    box-shadow: var(--shadow-sm);
}
</style>

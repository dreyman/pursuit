<script>
import Icon from '$lib/Icon.svelte'

let { children, title, onclose } = $props()
</script>

<!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_static_element_interactions -->
<div class="dialog-bg" onclick={onclose}></div>
<div class="dialog">
    <button class="icon-btn absolute top-0 right-0" onclick={onclose}>
        <Icon name="x" />
    </button>
    <header class="mb-4">
        <h1 class="text-center">{title}</h1>
    </header>
    {@render children()}
</div>

<style>
.dialog-bg {
    z-index: 1000;
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.6);
}

.dialog {
    z-index: 1001;
    background: #27282c;
    padding: 0.5rem 1rem;
    border-radius: 0.5rem;
    position: absolute;
    left: 50%;
    top: 20%;
    transform: translateX(-50%);
    box-shadow: var(--dialog-shadow);
}

h1 {
    font-weight: bold;
    font-size: 1.25rem;
    line-height: 1.25rem;
    margin: 0 2rem;
}
</style>

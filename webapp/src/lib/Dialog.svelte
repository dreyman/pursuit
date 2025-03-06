<script>
import Icon from '$lib/icons/Icon.svelte'
import Cross from '$lib/icons/cross.svg.svelte'

/** @type {{
     * children: any,
     * title: string,
     * onclose: function():void
     }}*/
let { children, title, onclose } = $props()
</script>

<!-- svelte-ignore a11y_click_events_have_key_events, a11y_no_static_element_interactions -->
<div class="dialog-bg" onclick={onclose}></div>
<div class="dialog">
    <button class="absolute top-0 right-0" onclick={onclose}>
        <Icon Icon={Cross} size="xl" />
    </button>
    <header class="mb-4">
        <h1 class="text-center">{title}</h1>
    </header>
    {@render children()}
</div>

<style>
.dialog-bg {
    position: absolute;
    inset: 0;
    background: #000;
    opacity: 0.5;
}

.dialog {
    background: #28292d;
    padding: 0.5rem 1rem;
    border-radius: 0.5rem;
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
}

h1 {
    font-weight: bold;
    font-size: 1.25rem;
    line-height: 1.25rem;
}
</style>

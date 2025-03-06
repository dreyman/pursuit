<script>
let { size = 'lg', color = '#c6c6c6', hover_color = '#c6c6c6', Icon, className = '' } = $props()
/** @type {HTMLElement} */
let wrapper
/** @type {any} */
let svg

// $effect(() => {
//     svg = wrapper.children[0]
//     svg.setAttribute('stroke', color)
// })

// function onmouseenter() {
//     svg.setAttribute('stroke', hover_color)
//     wrapper.style.backgroundColor = 'color-mix(in srgb, #fff 20%, transparent)'
// }

// function onmouseleave() {
//     svg.setAttribute('stroke', color)
//     wrapper.style.backgroundColor = 'inherit'
// }
</script>

<!-- svelte-ignore a11y_no_static_element_interactions -->
<i class={className + ' size-' + size} bind:this={wrapper}>
    <Icon />
</i>

<style>
i {
    display: block;
    border-radius: 100%;
    padding: 0.25rem;
    /*    padding: 0.25rem;*/
}

i:hover {
    background: color-mix(in srgb, #fff 20%, transparent);
}

.size-xs {
    width: 1rem;
    height: 1rem;
}

.size-sm {
    width: 1.25rem;
    height: 1.25rem;
}

.size-md {
    width: 1.5rem;
    height: 1.5rem;
}

.size-lg {
    width: 1.75rem;
    height: 1.75rem;
}

.size-xl {
    width: 2rem;
    height: 2rem;
}
</style>

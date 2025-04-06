<script>
/** @type {{value: string, options: any[]}} */
let { value = $bindable(), options } = $props()
</script>

<ul class="flex flex-wrap">
    {#each options as option}
        {#if typeof option == 'string'}
            <li class:selected={option == value}>
                <button onclick={() => (value = option)}>{option}</button>
            </li>
        {:else}
            <li class:selected={option.id == value}>
                <button onclick={() => (value = option.id)}>{option.name}</button>
            </li>
        {/if}
    {/each}
</ul>

<style>
ul {
    background: var(---light-grey);
}

button {
    width: 100%;
    padding: 0.15rem 0.75rem;
}

ul li:first-child {
    border-right: none;
}

ul li:last-child {
    border-left: 1px solid var(--light-grey);
    border-right: 1px solid var(--light-grey);
}

ul li {
    color: var(--light-grey);
    min-width: 6rem;
    text-align: center;
    border: 1px solid var(--light-grey);
}

ul li.selected {
    font-weight: bold;
    color: var(--primary-color);
    background: var(--grey-500);
}
</style>

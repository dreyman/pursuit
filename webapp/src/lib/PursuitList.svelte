<script>
import * as app from '$lib/app.js'
import Icon from '$lib/Icon.svelte'
import * as util from '$lib/util.js'

const { items } = $props()
</script>

<ul class="flex flex-col gap-1">
    {#each items as pursuit}
        <li class="flex items-center gap-1">
            {#if pursuit.kind == app.Kind.cycling}
                <Icon name="bike" size={1.3} />
            {:else if pursuit.kind == app.Kind.running || pursuit.kind == app.Kind.walking}
                <Icon name="run" size={1.3} />
            {:else}
                <Icon name="question-mark" size={1.3} />
            {/if}
            <a href="/entry/{pursuit.id}" class="text-lg">
                {pursuit.name}
            </a>
            <span class="text-sm text-gray-400">{util.timestampToString(pursuit.start_time * 1000)}</span>
        </li>
    {/each}
</ul>

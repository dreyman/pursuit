<script>
import * as app from '$lib/app.js'
import Icon from '$lib/Icon.svelte'
import * as util from '$lib/util.js'
import Distance from '$lib/Distance.svelte'

const { items, showicon = true, className = '' } = $props()
</script>

<ul class="flex flex-col gap-1 {className}">
    {#each items as pursuit}
        <li class="flex items-center gap-2">
            {#if showicon}
                {#if pursuit.kind == app.Kind.cycling}
                    <Icon name="bike" size={1.3} />
                {:else if pursuit.kind == app.Kind.running || pursuit.kind == app.Kind.walking}
                    <Icon name="run" size={1.3} />
                {:else}
                    <Icon name="question-mark" size={1.3} />
                {/if}
            {/if}
            <a href="/entries/{pursuit.id}" class="text-lg">
                {pursuit.name}
            </a>
            <Distance val={pursuit.distance} size="sm" rounded={true} />
            <span class="text-sm text-gray-400">{util.timestampToString(pursuit.start_time)}</span>
        </li>
    {/each}
</ul>

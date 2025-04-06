<script>
import 'leaflet/dist/leaflet.css'
import '../app.css'
import { setContext } from 'svelte'
import { page } from '$app/state'
import Icon from '$lib/Icon.svelte'

let { data, children } = $props()
const icon_size = 1.75
const mediums = data.mediums
setContext('mediums', mediums)
</script>

<div class="flex h-full w-full">
    <nav class="flex flex-col">
        <a href="/list" class:active={page.route.id?.startsWith('/list')}>
            <Icon name="list" size={icon_size} />
        </a>
        <a href="/new" class:active={page.route.id?.startsWith('/new')}>
            <Icon name="circle-plus" size={icon_size} />
        </a>
        <a href="/garage" class:active={page.route.id?.startsWith('/garage')}>
            <Icon name="tool" size={icon_size} />
        </a>
        <a href="/settings" class:active={page.route.id?.startsWith('/settings')}>
            <Icon name="settings" size={icon_size} />
        </a>
    </nav>

    <div class="page-content flex grow flex-col items-center">
        {@render children()}
    </div>
</div>

<style>
nav {
    background: #1c1c1c;
}

nav a {
    white-space: nowrap;
    font-weight: 500;
    padding: 0.5rem 0.75rem;
    color: #fff;
}

nav a:hover {
    color: var(--primary-color);
}

nav a.active {
    background: var(--primary-color);
    color: #000;
}

.page-content {
    margin-top: 1rem;
    width: 100%;
}
</style>

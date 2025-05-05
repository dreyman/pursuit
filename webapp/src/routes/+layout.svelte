<script>
import 'leaflet/dist/leaflet.css'
import '../app.css'
import '../misc.css'
import { setContext } from 'svelte'
import { page } from '$app/state'
import Icon from '$lib/Icon.svelte'

let { data, children } = $props()
const icon_size = 1.8
const mediums = $state(data.mediums)
setContext('mediums', mediums)
</script>

<div class="flex h-full w-full">
    <nav class="flex flex-col">
        <a href="/" class:active={page.route.id == '/'}>
            <Icon name="circle-plus" size={icon_size} />
        </a>
        <a href="/entries" class:active={page.route.id?.startsWith('/entries')}>
            <Icon name="list" size={icon_size} />
        </a>
        <a href="/mediums" class:active={page.route.id?.startsWith('/mediums')}>
            <Icon name="tool" size={icon_size} />
        </a>
        <a href="/map" class:active={page.route.id?.startsWith('/map')}>
            <Icon name="map" size={icon_size} />
        </a>
        <a href="/landmarks" class:active={page.route.id?.startsWith('/landmarks')}>
            <Icon name="map-pin" size={icon_size} />
        </a>
        <!-- <a href="/settings" class:active={page.route.id?.startsWith('/settings')}>
            <Icon name="settings" size={icon_size} />
        </a> -->
    </nav>

    <div class="flex w-full grow flex-col items-center">
        {@render children()}
    </div>
</div>

<style>
nav {
    background: #1e1f1f;
    height: 100%;
    width: 3.4rem;
    position: fixed;
    z-index: 500;
}

nav a {
    white-space: nowrap;
    font-weight: 500;
    padding: 0.5rem 0.8rem;
    color: #fff;
}

nav a:hover {
    color: var(--pc);
}

nav a.active {
    background: var(--pc);
    color: #000;
}
</style>

<script>
import 'leaflet/dist/leaflet.css'
import '../app.css'
import { page } from '$app/state'

let { children } = $props()
</script>

<div class="flex h-full w-full">
    <nav class="flex flex-col">
        <a href="/list" class:active={page.route.id?.startsWith('/list')}>List</a>
        <a href="/new" class:active={page.route.id?.startsWith('/new')}>New</a>
        <a href="/garage" class:active={page.route.id?.startsWith('/garage')}>Garage</a>
        <!-- <ul class="flex flex-col">
            <li>
                <a href="/list" class="active">List</a>
            </li>
            <li>
                <a href="/new">New</a>
            </li>
            <li>
                <a href="/garage">Garage</a>
            </li>
        </ul> -->
    </nav>

    <div class="page-content ml-12 flex grow flex-col items-start">
        {@render children()}
    </div>
</div>

<style>
nav {
    /*    background: #1c1c1c;*/
    /*    color: #ccc;*/
    /*    font-size: 1.25rem;*/
    padding: 1.5rem 0;
}

/*nav li {
    border: 1px solid green;
}*/

nav a {
    white-space: nowrap;
    font-size: 14px;
    font-weight: 500;
    padding: 0.5rem 2rem;
    color: #fff;
    border-bottom-right-radius: 1rem;
    border-top-right-radius: 1rem;
}

nav a.active {
    background: var(--sky-11);
    color: #000;
}

.page-content {
    margin-top: 1rem;
    width: 100%;
}
</style>

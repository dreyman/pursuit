<script>
import 'leaflet/dist/leaflet.css'
import '../app.css'

let { children } = $props()
</script>

<div class="flex h-full w-full">
    <aside class="flex flex-col">
        <nav class="space-between flex flex-wrap px-2">
            <ul class="flex flex-col">
                <li>
                    <a href="/list">List</a>
                </li>
                <li>
                    <a href="/new">New</a>
                </li>
                <li>
                    <a href="/garage">Garage</a>
                </li>
            </ul>
        </nav>
    </aside>

    <div class="page-content flex flex-col">
        {@render children()}
    </div>
</div>

<style>
aside {
    background: #1c1c1c;
}

nav {
    background: #1c1c1c;
    color: #ccc;
    font-size: 1.25rem;
}

.page-content {
    margin-top: 1rem;
    width: 100%;
}
</style>

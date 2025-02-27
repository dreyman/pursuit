<script>
import 'leaflet/dist/leaflet.css'
import '../app.css'

let { children } = $props()
</script>

<nav class="w-full px-4 py-1">
    <ul>
        <li>
            <a href="/list">List</a>
        </li>
    </ul>
</nav>
{@render children()}

<style>
nav {
    background: #ccc;
    color: #000;
    font-size: 1.5rem;
}
</style>

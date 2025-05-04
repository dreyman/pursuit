import * as api from '$lib/api.js';

export async function load({ fetch, url, params }) {
    const lat = parseFloat(params.lat)
    const lon = parseFloat(params.lon)
    const flybys = await api.locationFlybys(fetch, lat, lon)
    return { flybys }
}

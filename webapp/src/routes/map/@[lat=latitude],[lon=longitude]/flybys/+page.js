import * as api from '$lib/api.js';

export async function load({ fetch, url, params }) {
    // return { location_info: JSON.parse(fake_resp) }
    const flybys = await api.locationFlybys(fetch, parseFloat(params.lat), parseFloat(params.lon))
    return { flybys }
}

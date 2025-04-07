import * as api from '$lib/api.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
    const medium = await api.Medium.getById(fetch, +params.id)
    if (medium != null) {
        return { medium }
    } else {
        error(404, 'Not Found')
    }
}

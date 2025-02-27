import * as api from '$lib/api.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
    return { items: await api.listActivities(fetch) }
}

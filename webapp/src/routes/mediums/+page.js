import * as api from '$lib/api.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch }) {
    return { mediums: await api.Medium.list(fetch) }
}

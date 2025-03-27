import * as api from '$lib/api.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch }) {
    return { entries: await api.getPursuits(fetch) }
}

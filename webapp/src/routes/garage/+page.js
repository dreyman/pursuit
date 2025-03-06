import * as api from '$lib/api.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch }) {
    return { bikes: await api.getBikes(fetch) }
}

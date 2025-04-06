import * as api from '$lib/api.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, url }) {
    return { pursuits: await api.Pursuit.list(fetch, url.search) }
}

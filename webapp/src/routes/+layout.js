import * as api from '$lib/api.js'

export const ssr = false;
export const prerender = true;

/** @type {import('./$types').PageLoad} */
export async function load({ fetch }) {
    return { mediums: await api.Medium.list(fetch) }
}

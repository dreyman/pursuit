import * as Landmarks from '$lib/landmarks.api.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, url }) {
    return { landmarks: await Landmarks.list(fetch, url.search) }
}

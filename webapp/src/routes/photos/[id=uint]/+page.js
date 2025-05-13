import * as Photos from '$lib/photos.api.js';

export async function load({ fetch, params }) {
    return { photo: await Photos.get(fetch, +params.id) }
}

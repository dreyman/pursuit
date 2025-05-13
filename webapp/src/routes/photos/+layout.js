import * as Photos from '$lib/photos.api.js';

export async function load({ fetch }) {
    return {
        photos: await Photos.list(fetch)
    }
}

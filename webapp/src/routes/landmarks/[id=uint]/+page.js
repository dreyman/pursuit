import * as Landmarks from '$lib/landmarks.api.js';

export async function load({ fetch, params }) {
    return { landmark: await Landmarks.get(fetch, +params.id) }
}

import * as Landmarks from '$lib/landmarks.api.js';

export async function load({ fetch }) {
    return {
        landmarks: await Landmarks.list(fetch)
    }
}

import { error } from '@sveltejs/kit'
import * as api from '$lib/api.js'

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
    const route = await api.activityRoute(fetch, params.id)
    if (route != null) {
        return { route }
    } else {
        error(404, 'Not Found')
    }
}
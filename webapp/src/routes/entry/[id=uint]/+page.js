import { error } from '@sveltejs/kit'
import * as api from '$lib/api.js'
import * as state from '$lib/shared_state.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
    const last = state.entries[state.entries.length - 1];
    if (last && last.id == params.id) {
        return { route: state.entries.pop() }
    }
    const route = await api.get_route(fetch, +params.id)
    if (route != null) {
        return { route }
    } else {
        error(404, 'Not Found')
    }
}
import { error } from '@sveltejs/kit'
import * as api from '$lib/api.js'
import * as cache from '$lib/shared_state.js';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
    const last = cache.entries[cache.entries.length - 1];
    if (last && last.id == params.id) {
        return { pursuit: cache.entries.pop() }
    }
    const pursuit = await api.Pursuit.getById(fetch, +params.id)
    if (pursuit != null) {
        return { pursuit }
    } else {
        error(404, 'Not Found')
    }
}
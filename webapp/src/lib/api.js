const API_URL = 'http://localhost:7070/api';

/**
 * @param {any} fetch
 * @param {number} id
 */
export async function get_route(fetch, id) {
    try {
        const resp = await fetch(`${API_URL}/routes/${id}`)
        if (resp.status != 200) return null
        return await resp.json()
    } catch (err) {
        return null
    }
}



/** @param {any} fetch */
export async function get_routes(fetch) {
    try {
        const resp = await fetch(`${API_URL}/routes`)
        if (resp.status != 200) return []
        return await resp.json()
    } catch (err) {
        return []
    }
}

/**
 * @param {any} fetch
 * @param {number} id
 */
export async function get_track(fetch, id) {
    try {
        const resp = await fetch(`${API_URL}/routes/${id}/track`)
        if (resp.status != 200) return null
        const blob = await resp.blob()
        const arrayBuffer = await blob.arrayBuffer()
        return new Float32Array(arrayBuffer)
    } catch (err) {
        return null
    }
}

const API_URL = 'http://localhost:7070/api';

/**
 * @param {any} fetch
 * @param {number} id
 */
export async function getPursuit(fetch, id) {
    try {
        const resp = await fetch(`${API_URL}/pursuit/${id}`)
        if (resp.status != 200) return null
        return await resp.json()
    } catch (err) {
        return null
    }
}



/** @param {any} fetch */
export async function getPursuits(fetch) {
    try {
        const resp = await fetch(`${API_URL}/pursuit?order_by=start_time&desc=true`)
        if (resp.status != 200) return []
        return await resp.json()
    } catch (err) {
        return []
    }
}

/**
 * @param {any} fetch
 * @param {any} payload
 */
export async function updatePursuit(fetch, payload) {
    try {
        const resp = await fetch(`${API_URL}/pursuit`, {
            method: 'PUT',
            body: JSON.stringify(payload),
        })
        if (resp.status != 200) return false
        return true
    } catch (err) {
        return false
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

/** @param {any} fetch */
export async function getBikes(fetch) {
    try {
        const resp = await fetch(`${API_URL}/bikes`)
        if (resp.status != 200) return []
        return await resp.json()
    } catch (err) {
        return []
    }
}

/**
 * @param {any} fetch
 * @param {NewBike} bike
 */
export async function createBike(fetch, bike) {
    try {
        const resp = await fetch(`${API_URL}/bikes`, {
            method: 'POST',
            body: JSON.stringify(bike),
        })
        if (resp.status != 200) return null
        return await resp.json()
    } catch (err) {
        return null
    }
}

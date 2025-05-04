const API_URL = 'http://localhost:7070/api';

export const Medium = {
    list: async (fetch) => {
        try {
            const resp = await fetch(`${API_URL}/medium`)
            if (resp.status != 200)
                return []
            return await resp.json()
        } catch (err) {
            return []
        }
    },
    getById: async (fetch, id) => {
        try {
            const resp = await fetch(`${API_URL}/medium/${id}`)
            if (resp.status != 200)
                return null
            return await resp.json()
        } catch (err) {
            return null
        }
    },
    create: async (payload) => {
        try {
            const resp = await fetch(`${API_URL}/medium/new`, {
                method: 'POST',
                body: JSON.stringify(payload),
            })
            if (resp.status != 200)
                return null
            return await resp.json()
        } catch (err) {
            return null
        }
    }
}

export const Pursuit = {
    list: async (fetch, query) => {
        try {
            const resp = await fetch(`${API_URL}/pursuit${query}`)
            if (resp.status != 200) return []
            return await resp.json()
        } catch (err) {
            return []
        }
    },
    getById: async (fetch, id) => {
        try {
            const resp = await fetch(`${API_URL}/pursuit/${id}`)
            if (resp.status != 200)
                return null
            return await resp.json()
        } catch (err) {
            return null
        }
    },
    update: async (fetch, id, payload) => {
        try {
            const resp = await fetch(`${API_URL}/pursuit/${id}`, {
                method: 'PUT',
                body: JSON.stringify(payload),
            })
            if (resp.status != 200)
                return false
            return true
        } catch (err) {
            return false
        }
    }
}

export const Stats = {
    recalc: async (fetch, id, payload) => {
        try {
            const resp = await fetch(`${API_URL}/pursuit/${id}/stats`, {
                method: 'PUT',
                body: JSON.stringify(payload),
            })
            const resp_body = await resp.json()
            if (resp.status != 200)
                return [null, resp_body]
            return [resp_body, null]
        } catch (err) {
            console.log(err)
            return null
        }
    }
}

/**
 * @param {any} fetch
 * @param {number} id
 * @returns {Float32Array}
 */
export async function getTrack(fetch, id) {
    try {
        const resp = await fetch(`${API_URL}/pursuit/${id}/track`)
        if (resp.status != 200)
            return null
        const blob = await resp.blob()
        const arrayBuffer = await blob.arrayBuffer()
        return new Float32Array(arrayBuffer)
    } catch (err) {
        return null
    }
}

export async function locationFlybys(fetch, lat, lon) {
    try {
        const resp = await fetch(`${API_URL}/location/flybys`, {
            method: 'POST',
            body: JSON.stringify({ lat, lon }),
        })
        if (resp.status != 200)
            return null
        return await resp.json()
    } catch (err) {
        return null
    }
}

const API_URL = 'http://localhost:7070';

export const Activity = {
    list: listActivities,
    route: activityRoute,
}

export async function listActivities(fetch) {
    try {
        const resp = await fetch(`${API_URL}/list`)
        return await resp.json()
    } catch (err) {
        return []
    }
}

export async function activityRoute(fetch, id) {
    try {
        const resp = await fetch(`${API_URL}/${id}/route`)
        if (resp.status != 200) return null
        const blob = await resp.blob()
        const arrayBuffer = await blob.arrayBuffer()
        return new Float32Array(arrayBuffer)
    } catch (err) {
        return null
    }
}

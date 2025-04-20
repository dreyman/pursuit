const API_URL = 'http://localhost:7070/api';

export async function list(fetch, query) {
    try {
        const resp = await fetch(`${API_URL}/landmarks/list${query}`)
        if (resp.status != 200)
            return []
        return await resp.json()
    } catch (err) {
        return []
    }
}
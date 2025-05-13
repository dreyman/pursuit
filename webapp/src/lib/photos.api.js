const API_URL = 'http://localhost:7070/api';

export async function list(fetch) {
    try {
        const resp = await fetch(`${API_URL}/photos/list`)
        if (resp.status != 200)
            return []
        return await resp.json()
    } catch (err) {
        return []
    }
}

export function photoSrc(photo_id) {
    return `${API_URL}/photos/${photo_id}/file`
}

export async function get(fetch, id) {
    try {
        const resp = await fetch(`${API_URL}/photos/${id}`)
        if (resp.status != 200)
            return null
        return await resp.json()
    } catch (err) {
        return null
    }
}

// export async function create(payload) {
//     try {
//         const resp = await fetch(`${API_URL}/landmarks/new`, {
//             method: 'POST',
//             body: JSON.stringify(payload),
//         })
//         const resp_body = await resp.json()
//         if (resp.status != 200)
//             return [null, resp_body]
//         return [resp_body, null]
//     } catch (err) {
//         console.log(err)
//         return null
//     }
// }

// export async function remove(id) {
//     try {
//         const resp = await fetch(`${API_URL}/landmarks/${id}`, {
//             method: 'DELETE',
//         })
//         const resp_body = await resp.json()
//         if (resp.status != 200)
//             return [null, resp_body]
//         return [resp_body, null]
//     } catch (err) {
//         console.log(err)
//         return null
//     }
// }


const dev_routes_json = '[{"id":1739197380,"name":"2025-02-10T14:23:00Z","stats":{"start":1739197380,"end":1739200917,"distance":1405,"totalTime":3537,"movingTime":2793,"pausesCount":7,"pausesLen":744,"untrackedDistance":7}},{"id":1721895450,"name":"2024-07-25T08:17:30Z","stats":{"start":1721895450,"end":1721938643,"distance":30196,"totalTime":43193,"movingTime":42677,"pausesCount":13,"pausesLen":516,"untrackedDistance":3}},{"id":1738499475,"name":"2025-02-02T12:31:15Z","stats":{"start":1738499475,"end":1738503372,"distance":1495,"totalTime":3897,"movingTime":3039,"pausesCount":5,"pausesLen":858,"untrackedDistance":7}}]';
const dev_routes = JSON.parse(dev_routes_json);

/**
 * @param {any} fetch
 * @param {number} id
 */
export async function get_route(fetch, id) {
    return dev_routes.find(r => r.id == id);
}

/** @param {any} fetch */
export async function get_routes(fetch) {
    return new Promise(resolve => {
        resolve(JSON.parse(dev_routes_json));
    });
}

/**
 * @param {any} fetch
 * @param {number} id
 */
export async function get_track(fetch, id) {
    try {
        const resp = await fetch(`/track`)
        if (resp.status != 200) {
            alert('failed to fetch static track, status = ' + resp.status)
            return null
        }
        const blob = await resp.blob()
        const arrayBuffer = await blob.arrayBuffer()
        return new Float32Array(arrayBuffer)
    } catch (err) {
        alert('failed to fetch static track, err = ' + err)
        return null
    }
}

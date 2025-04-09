/**
 * @param {any} pursuit
 * @returns {MapCfg}
 */
export function mapCfg(pursuit) {
    const center = [
        (pursuit.westernmost_lat + pursuit.easternmost_lat) / 2,
        (pursuit.northernmost_lon + pursuit.southernmost_lon) / 2,
    ]
    const bounds = [
        [pursuit.northernmost_lat, pursuit.westernmost_lon],
        [pursuit.southernmost_lat, pursuit.easternmost_lon]
    ]
    return { center, bounds }
}

/**
 * @param {number} timestamp
 * @returns {string}
 */
export function timestampToString(timestamp) {
    const d = new Date(timestamp)
    return d.toDateString()
}

/**
 * @param {number} timestamp
 * @returns {string}
 */
export function timestampToFullDate(timestamp) {
    const d = new Date(timestamp)
    return d.toLocaleTimeString() + ' ' + d.toDateString()
}

/**
 * @param {number} seconds
 * @returns {string}
 */
export function secondsToString(seconds) {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds - h * 3600) / 60)
    const s = seconds % 60
    return `${timeUnitStr(h)}:${timeUnitStr(m)}:${timeUnitStr(s)}`
}

/**
 * @param {number} distance in meters
 * @param {number} time in seconds
 */
export function minutesPerKm(distance, time) {
    return time / distance * 1000 / 60
}

/**
 * @param {number} distance in meters
 * @param {number} time in seconds
 */
export function avgSpeedKmh(distance, time) {
    return distance / time * 3.6
}

/**
 * @param {number} meters
 * @returns {number}
 */
export function metersToKm(meters) {
    return Math.floor(meters / 1000);
}

/**
 * @param {number} val
 * @returns {string}
 */
function timeUnitStr(val) {
    return val < 10 ? '0' + val : '' + val
}

/**
 * @param {any} Leaflet
 * @param {HTMLElement} map_el
 * @param {MapCfg} cfg
 * @returns {any} leaflet map object
 * */
export function initLeafletMap(Leaflet, map_el, cfg) {
    const map = Leaflet.map(map_el, { zoomControl: false }).setView(cfg.center, 12)
    Leaflet.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }).addTo(map)
    map.fitBounds(cfg.bounds)
    return map
}

/**
 * @param {string | number} val
 * @param {string} char
 * @param {number} len
 */
export function leftPad(val, char, len) {
    let str = val.toString()
    if (str.length >= len) return str
    let offset = ''
    for (let i = 0; i < len - str.length; ++i)
        offset += char
    return offset + str
}

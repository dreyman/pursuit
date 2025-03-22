/**
 * @param {number} timestamp
 * @returns {string}
 */
export function timestamp_to_string(timestamp) {
    const d = new Date(timestamp)
    return d.toDateString() + ' ' + d.toLocaleTimeString();
}

/**
 * @param {number} seconds
 * @returns {string}
 */
export function seconds_to_string(seconds) {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds - h * 3600) / 60)
    const s = seconds % 60
    return `${time_unit_str(h)}:${time_unit_str(m)}:${time_unit_str(s)}`
}

/**
 * @param {number} val
 * @returns {string}
 */
function time_unit_str(val) {
    return val < 10 ? '0' + val : '' + val
}

/**
 * @param {any} Leaflet
 * @param {HTMLElement} map_el
 * @returns {any} leaflet map object
 * */
export function init_leaflet_map(Leaflet, map_el) {
    const map = Leaflet.map(map_el, { zoomControl: false }).setView([48.95, 32.2], 11)
    Leaflet.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }).addTo(map)
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

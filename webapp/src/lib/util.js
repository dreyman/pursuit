const today = new Date()
const current_year = today.getFullYear()

/**
 * @param {number} timestamp
 * @returns {string}
 */
export function timestampToString(timestamp) {
    const d = new Date(timestamp * 1000)
    return dateStrWithoutCurrentYear(d)
}

/**
 * @param {number} timestamp
 * @returns {string}
 */
export function timestampToFullDate(timestamp) {
    const d = new Date(timestamp * 1000)
    return d.toLocaleTimeString() + ' ' + dateStrWithoutCurrentYear(d)
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
 * @param {Date} date
 * @returns {string}
 */
function dateStrWithoutCurrentYear(date) {
    const date_str = date.toDateString()
    if (date.getFullYear() == current_year)
        return date_str.substring(0, date_str.length - 5)
    return date_str
}

/**
 * @param {number} val
 * @returns {string}
 */
function timeUnitStr(val) {
    return val < 10 ? '0' + val : '' + val
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

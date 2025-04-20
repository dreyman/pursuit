/**
 * @param {any} stats
 * @returns {MapCfg}
 */
export function mapCfg(stats) {
    const center = [
        (stats.westernmost_lat + stats.easternmost_lat) / 2,
        (stats.northernmost_lon + stats.southernmost_lon) / 2,
    ]
    const bounds = [
        [stats.northernmost_lat, stats.westernmost_lon],
        [stats.southernmost_lat, stats.easternmost_lon]
    ]
    return { center, bounds }
}

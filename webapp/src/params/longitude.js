const longitude_min = -180;
const longitude_max = 180;

export function match(param) {
    const val = parseFloat(param);
    return val >= longitude_min && val <= longitude_max;
}

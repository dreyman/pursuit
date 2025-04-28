const latitude_min = -90;
const latitude_max = 90;

export function match(param) {
    const val = parseFloat(param);
    return val >= latitude_min && val <= latitude_max;
}

export const kinds = ['cycling', 'running', 'walking', 'other']
export const medium_kinds = ['bike', 'shoes']

export const Kind = {
    cycling: 'cycling',
    running: 'running',
    walking: 'walking',
    unknown: 'unknown',
};

export const unknown_medium = {
    id: 0,
    name: 'Unknown'
}

export function mediumLabel(pursuit_kind) {
    if (pursuit_kind == 'cycling') return 'Bike'
    if (pursuit_kind == 'running') return 'Shoes'
    if (pursuit_kind == 'walking') return 'Shoes'
    return 'Unknown'
}

export const debug = {
    use_map_placeholder: false,
}

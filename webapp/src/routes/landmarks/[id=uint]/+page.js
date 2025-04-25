export async function load({ fetch, url, parent, params }) {
    const data = await parent()
    const landmarks = data.landmarks
    const id = +params.id
    return { landmark: landmarks.find(lm => lm.id === id) }
}

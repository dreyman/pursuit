// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
    namespace App {
        // interface Error {}
        // interface Locals {}
        // interface PageData {}
        // interface PageState {}
        // interface Platform {}
    }

    type Bike = {
        id: string,
        name: string,
        distance: number,
    }

    type NewBike = {
        name: string,
    }
}

export {};

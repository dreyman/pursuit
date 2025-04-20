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

    type MapCfg = {
        center: [number, number];
        bounds?: [[number, number], [number, number]];
        zoom?: number;
    }

    type Bike = {
        id: string;
        name: string;
        distance: number;
    }

    type NewBike = {
        name: string;
    }

    type PursuitMetadata = {
        name: string;
        description: string;
        kind: PursuitKind;
    }

    enum PursuitKind {
        cycling,
        running,
    }
}

export {};

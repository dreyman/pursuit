package stats;

import engine.Engine;

public class Api {

    Engine engine;
    pursuit.Api pursuit_api;

    public Api(Engine engine, pursuit.Api pursuit_api) {
        this.engine = engine;
        this.pursuit_api = pursuit_api;
    }

    public Stats recalcStats(int id, int min_speed, int max_time_gap) {
        try {
            engine.recalcStats(id, min_speed, max_time_gap);
            // fixme just retrieve stats (or even only recalculated fields)
            var pursuit = pursuit_api.getById(id);
            return pursuit.stats;
        } catch (Engine.Err e) {
            e.printStackTrace();
            throw new api.InternalError();
        }
    }
}

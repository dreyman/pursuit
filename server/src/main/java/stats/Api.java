package stats;

import core.Engine;

public class Api {

    Engine engine;
    pursuit.Api pursuitApi;

    public Api(Engine engine, pursuit.Api pursuitApi) {
        this.engine = engine;
        this.pursuitApi = pursuitApi;
    }

    public Stats recalcStats(int id, int min_speed, int max_time_gap) {
        try {
            engine.recalcStats(id, min_speed, max_time_gap);
            // fixme just retrieve stats (or even only recalculated fields)
            var pursuit = pursuitApi.getById(id);
            return pursuit.stats;
        } catch (Engine.Err e) {
            e.printStackTrace();
            throw new api.InternalError();
        }
    }
}

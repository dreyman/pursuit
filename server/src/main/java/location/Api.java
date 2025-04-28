package location;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import core.Engine;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

public class Api {

    Engine engine;
    pursuit.Api pursuitApi;
    Gson gson;

    public Api(Engine engine, pursuit.Api pursuitApi) {
        this.engine = engine;
        this.pursuitApi = pursuitApi;
        this.gson = new Gson();
    }

    public List<Flyby> locationFlybys(Query query) {
        try {
            String json = engine.locationVisits(
                    query.lat,
                    query.lon,
                    query.max_distance,
                    query.time_gap
            );
            Type FlybysListType = new TypeToken<ArrayList<Flyby>>() {}.getType();
            List<Flyby> flybys = gson.fromJson(json, FlybysListType);
            var q = new pursuit.Query();
            q.ids = flybys.stream().map(v -> v.pursuit_id).toList();
            q.limit = flybys.size();
            var pursuits = pursuitApi.query(q);
            flybys.forEach(item ->
                    item.pursuit = pursuits.stream()
                            .filter(p -> p.id == item.pursuit_id)
                            .findFirst()
                            .orElseThrow(api.InternalError::new));
            return flybys;
        } catch (Engine.Err e) {
            throw new RuntimeException(e);
        }
    }
}

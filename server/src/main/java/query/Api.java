package query;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import core.Engine;

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

    public List<LocationVisit> locationFlybys(LocationVisitsParams params) {
        try {
            String json = engine.locationVisits(
                    params.lat,
                    params.lon,
                    params.max_distance,
                    params.time_gap
            );
            List<LocationVisit> items = gson.fromJson(json, new TypeToken<ArrayList<LocationVisit>>() {
            }.getType());
            var q = new pursuit.QueryParams();
            q.ids = items.stream().map(v -> v.id).toList();
            q.limit = items.size();
            var pursuits = pursuitApi.query(q);
            items.forEach(item ->
                    item.pursuit = pursuits.stream()
                            .filter(p -> p.id == item.id)
                            .findFirst()
                            .orElseThrow(api.InternalError::new));
            return items;
        } catch (Engine.Err e) {
            throw new RuntimeException(e);
        }
    }
}

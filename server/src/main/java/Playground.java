import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import core.Engine;
import core.ForeignEngine;
import query.LocationVisit;

import java.util.ArrayList;

public class Playground {

    public static void main(String[] args) {
        var gson = new Gson();
        var lib_path = "/home/ihor/code/pursuit/engine/zig-out/lib/libpursuit.so";
        var storage_path = "/home/ihor/code/pursuit/server/dev/storage/";
        Engine engine = new ForeignEngine(lib_path, storage_path);
        //48.902685 32.881959 0.1 60
        float lat = 48.902685f;
        float lon = 32.881959f;
        double max_dist = 0.1;
        int time_gap = 60;
        try {
            var json = engine.locationVisits(lat, lon, max_dist, time_gap);
            var points = gson.fromJson(json, new TypeToken<ArrayList<LocationVisit>>(){}.getType());
            System.out.println(points);
        } catch (Engine.Err e) {
            throw new RuntimeException(e);
        }
    }
}

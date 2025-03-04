package app.model;

import com.google.gson.annotations.SerializedName;

public class Route {
    public record Stats(
            Type routeType,
            int start,
            int end,
            int distance,
            int totalTime,
            int movingTime,
            int stopsCount,
            int stopsDuration,
            int untrackedDistance,
            float minLat,
            float maxLat,
            float minLon,
            float maxLon) {
    }

    public enum Type {
        @SerializedName("cycling") CYCLING,
        @SerializedName("running") RUNNING,
        @SerializedName("walking") WALKING,
        @SerializedName("hiking") HIKING,
        @SerializedName("unknown") UNKNOWN
    }

    public int id;
    public String name;
    public Route.Stats stats;

}

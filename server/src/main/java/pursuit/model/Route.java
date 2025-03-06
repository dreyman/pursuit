package pursuit.model;

import com.google.gson.annotations.SerializedName;

public class Route {
    public enum Type {
        @SerializedName("cycling") CYCLING,
        @SerializedName("running") RUNNING,
        @SerializedName("walking") WALKING,
        @SerializedName("hiking") HIKING,
        @SerializedName("unknown") UNKNOWN
    }

    public int id;
    public String name;
    public Type type;
    public String bike;
    // readonly stats
    public int start;
    public int end;
    public int distance;
    public int total_time;
    public int moving_time;
    public int stops_count;
    public int stops_duration;
    public int untracked_distance;
    public float min_lat;
    public float max_lat;
    public float min_lon;
    public float max_lon;

}

package core;

public class Location {
    public float lat;
    public float lon;

    public Location(float latitude, float longitude) {
        this.lat = latitude;
        this.lon = longitude;
    }

    public String toString() {
        return lat + ", " + lon;
    }
}

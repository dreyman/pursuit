package app.model;

public class Route {
    public record Stats(int start,
                        int end,
                        int distance,
                        int totalTime,
                        int movingTime,
                        int pausesCount,
                        int pausesLen,
                        int untrackedDistance) {
    }

    public int id;
    public String name;
    public Route.Stats stats;

}

package fields.wild.storage;

public record Entry(int timestamp,
                    int distance,
                    int total_time,
                    int moving_time,
                    int pauses_count,
                    int pauses_len,
                    int untracked_distance) {
}

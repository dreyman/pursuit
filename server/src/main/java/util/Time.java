package util;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;

public class Time {

public static int offsetTimestampForTimezone(int timestamp, ZoneId tz) {
    var ldt = LocalDateTime.ofInstant(Instant.ofEpochSecond(timestamp), ZoneId.of("UTC"));
    var offset_seconds = ZonedDateTime
            .of(ldt.getYear(), ldt.getMonth().getValue(), ldt.getDayOfMonth(),
                    ldt.getHour(), ldt.getMinute(), ldt.getSecond(), ldt.getNano(), tz)
            .getOffset()
            .getTotalSeconds();
    return timestamp - offset_seconds;
}

private Time() {}

}

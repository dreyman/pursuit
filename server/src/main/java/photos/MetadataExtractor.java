package photos;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Directory;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.drew.metadata.exif.GpsDirectory;
import core.Location;

import java.io.File;
import java.io.IOException;
import java.util.Date;

import static com.drew.metadata.exif.ExifDirectoryBase.*;

public class MetadataExtractor {

public static class ExtractException extends Exception {
    public ExtractException(Throwable cause) {
        super(cause);
    }
}

//public static class NoExifData extends Exception {}
//public static class NoTimestamp extends Exception {}
public record ReadMetadataResult(Metadata metadata, Exception err) {}

public ReadMetadataResult readMetadata(File file) {
    try {
        var metadata = readFromFile(file);
        return new ReadMetadataResult(metadata, null);
    } catch (NullPointerException npe) {
        throw npe;
    } catch (Exception x) {
        return new ReadMetadataResult(null, x);
    }
}

public Metadata readFromFile(File file) throws IOException, ExtractException {
    com.drew.metadata.Metadata all_metadata;
    try {
        all_metadata = ImageMetadataReader.readMetadata(file);
    } catch (ImageProcessingException e) {
        throw new ExtractException(e);
    }
    var exif_dir = all_metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
    var exif_sub_dir = all_metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
    var gps_dir = all_metadata.getFirstDirectoryOfType(GpsDirectory.class);

    String timezone = null;
    // Timezone
    if (exif_dir != null) {
        timezone = getTimezone(exif_dir);
        if (timezone == null) timezone = getTimezone(exif_sub_dir);
    }
    // Timestamp
    Integer timestamp = null;
    if (exif_sub_dir != null) {
        var original_date = exif_sub_dir.getDateOriginal();
        if (original_date != null) {
            var t = (int) original_date.toInstant().getEpochSecond();
            if (t > 0)
                timestamp = t;
        }
    }
    // GPS Data
    Location location = null;
    Integer gps_timestamp = null;
    if (gps_dir != null) {
        var geo = gps_dir.getGeoLocation();
        if (geo != null) {
            location = new Location(
                    (float) geo.getLatitude(),
                    (float) geo.getLongitude()
            );
        }
        Date gps_date = gps_dir.getGpsDate();
        if (gps_date != null) {
            gps_timestamp = (int) gps_date.toInstant().getEpochSecond();
        }
    }
    // Other data
    String make = null;
    String model = null;
    if (exif_dir != null)
        make = exif_dir.getString(TAG_MAKE);
    if (exif_dir != null)
        model = exif_dir.getString(TAG_MODEL);

    return new Metadata(timestamp, timezone, location, gps_timestamp, make, model);
}

//public Metadata readFromFile(File file) throws
//        IOException, ExtractException, NoExifData, NoTimestamp {
//    com.drew.metadata.Metadata metadata;
//    try {
//        metadata = ImageMetadataReader.readMetadata(file);
//    } catch (ImageProcessingException e) {
//        throw new ExtractException(e);
//    }
//    var exif_sub_dir = metadata.getFirstDirectoryOfType(ExifSubIFDDirectory.class);
//    if (exif_sub_dir == null)
//        throw new NoExifData();
//    var exif_dir = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
//    var exif_image_dir = metadata.getFirstDirectoryOfType(ExifImageDirectory.class);
//    var interop = metadata.getFirstDirectoryOfType(ExifInteropDirectory.class);
//
//    Object tag_time_zone = exif_sub_dir.getObject(TAG_TIME_ZONE);
//    var exif_timezone = exif_sub_dir.getString(TAG_TIME_ZONE);
//    Object tag_time_zone_original = exif_sub_dir.getObject(TAG_TIME_ZONE_ORIGINAL);
//    Object tag_time_zone_digitized = exif_sub_dir.getObject(TAG_TIME_ZONE_DIGITIZED);
//    Object tag_time_zone_offset_tiff_ep = exif_sub_dir.getObject(TAG_TIME_ZONE_OFFSET_TIFF_EP);
//
//    Date original_date = exif_sub_dir.getDateOriginal(UTC);
//    if (original_date == null)
//        throw new NoTimestamp();
//
//    var result = new Metadata();
//    result.timestamp = (int) original_date.toInstant().getEpochSecond();
//
//    var gps_dir = metadata.getFirstDirectoryOfType(GpsDirectory.class);
//    if (gps_dir != null) {
//        var tag_time_stamp = gps_dir.getObject(GpsDirectory.TAG_TIME_STAMP);
//        var tag_date_stamp = gps_dir.getObject(GpsDirectory.TAG_DATE_STAMP);
//        var gps_date_obj = gps_dir.getGpsDate();
//        var geo = gps_dir.getGeoLocation();
//        if (geo != null) {
//            result.location = new core.Location(
//                    (float) geo.getLatitude(),
//                    (float) geo.getLongitude()
//            );
//        }
//        Date gps_date = gps_dir.getGpsDate();
//        if (gps_date != null) {
//            result.gps_timestamp = (int) gps_date.toInstant().getEpochSecond();
//        }
//    }
//
//    return result;
//}

String getTimezone(Directory dir) {
    var tz = dir.getString(TAG_TIME_ZONE);
    if (tz != null) return tz;
    tz = dir.getString(TAG_TIME_ZONE_ORIGINAL);
    if (tz != null) return tz;
    tz = dir.getString(TAG_TIME_ZONE_DIGITIZED);
    if (tz != null) return tz;
    tz = dir.getString(TAG_TIME_ZONE_OFFSET_TIFF_EP);
    if (tz != null) return tz;

    return null;
}

}

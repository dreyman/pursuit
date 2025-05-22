package photos;

import tag.Tag;

import java.sql.SQLException;
import java.time.ZoneId;
import java.util.List;

public class Api {
public Repository repo;
public tag.Repository tag_repo;

public Api(String sqlite_db_file) {
    repo = new photos.Repository(sqlite_db_file);
    tag_repo = new tag.Repository(sqlite_db_file);
}

public void importFromDirectory(String dir) {
    var init = new Init(repo);
    try {
        init.fromDirectory(dir);
    } catch (Init.Err e) {
        throw new RuntimeException(e);
    }
}

public List<Photo> query() {
    try {
        return repo.listWithoutTags();
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }
}

public void addTag(int photo_id, int tag_id) {
    try {
        repo.addTag(photo_id, tag_id);
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }
}

public int addTag(int photo_id, String tag_name) {
    try {
        Tag tag = tag_repo.getByName(tag_name);
        int tag_id = tag != null ? tag.id : tag_repo.insert(tag_name);
        repo.addTag(photo_id, tag_id);
        return tag_id;
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }
}

public List<Tag> getTags(int photo_id) {
    try {
        return repo.getTags(photo_id);
    } catch (SQLException e) {
        throw new RuntimeException(e);
    }
}

//public List<Tag> distinctTags() {
//    repo.distinctTags()
//}

public Photo getById(int id) {
    try {
        return repo.getById(id);
    } catch (SQLException x) {
        throw new RuntimeException(x);
    }
}

public void setup() {
    try {
        repo.setup();
    } catch (SQLException x) {
        x.printStackTrace();
        throw new RuntimeException(x);
    }
}

public void adjustTimezone(ZoneId tz) {

}
}

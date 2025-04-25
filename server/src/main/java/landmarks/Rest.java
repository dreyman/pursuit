package landmarks;

public class Rest {

    Api api;

    public Rest(Api api) {
        this.api = api;
    }

    public void create(String json) {
        var req = landmarks.Payload.fromJson(json);
        api.create(req);
    }
}

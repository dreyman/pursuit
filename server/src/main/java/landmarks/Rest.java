package landmarks;

public class Rest {

    Api api;

    public Rest(Api api) {
        this.api = api;
    }

    public int create(String json) {
        var req = landmarks.Payload.fromJson(json);
        return api.create(req);
    }
}

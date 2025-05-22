package landmarks;

import io.javalin.Javalin;
import io.javalin.http.NotFoundResponse;
import io.javalin.router.JavalinDefaultRoutingApi;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static io.javalin.http.HttpStatus.NOT_FOUND;
import static io.javalin.http.HttpStatus.OK;

public class Rest {

Service service;

public Rest(Service service) {
    this.service = service;
}

public List<Landmark> list() {
    return service.query();
}

public int create(String json) {
    var req = Payload.fromJson(json);
    return service.create(req);
}

public Optional<Landmark> getById(int id) {
    return Optional.ofNullable(service.getById(id));
}

public boolean delete(int id) {
    return service.delete(id);
}

public void initJavalin(JavalinDefaultRoutingApi<Javalin> api, String prefix) {
    api.get(prefix + "/list", ctx -> ctx.json(
            list()
    ));

    api.get(prefix + "/{id}", ctx -> ctx.json(
            getById(util.Rest.getId(ctx)
                    .orElseThrow(NotFoundResponse::new)
            ).orElseThrow(NotFoundResponse::new)
    ));

    api.post(prefix + "/new", ctx -> ctx.json(
            Map.of("id", create(ctx.body()))
    ));

    api.delete(prefix + "/{id}", ctx -> ctx.status(
            delete(util.Rest.getId(ctx)
                    .orElseThrow(NotFoundResponse::new)
            ) ? OK : NOT_FOUND
    ));
}

}

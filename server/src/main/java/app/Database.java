package app;

import app.model.Route;

import java.util.List;

public interface Database {

    void saveRoute(Route route) throws Exception;

    Route getRoute(int id) throws Exception;

    List<Route> getRoutes() throws Exception;
}

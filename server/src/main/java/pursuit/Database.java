package pursuit;

import pursuit.model.Bike;
import pursuit.model.Route;

import java.util.List;

public interface Database {

    void saveRoute(Route route) throws Exception;

    Route getRoute(int id) throws Exception;

    List<Route> getRoutes() throws Exception;

    void saveBike(Bike bike) throws Exception;

    List<Bike> getBikes() throws Exception;
}

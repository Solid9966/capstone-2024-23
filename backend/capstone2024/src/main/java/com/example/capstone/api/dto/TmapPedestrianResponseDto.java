package com.example.capstone.api.dto;

import com.example.capstone.api.model.Route;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Setter
@ToString
public class TmapPedestrianResponseDto {
    @JsonProperty("type")
    private String type;
    @JsonProperty("features")
    private List<Feature> features;

    public TmapPedestrianResponseDto filteredPoint() {
        final List<Feature> features = new ArrayList<>();
        for (Feature feature : this.features) {
            if (feature.getGeometry().getType().equalsIgnoreCase("point")) {
                features.add(feature);
            }
        }
        return new TmapPedestrianResponseDto(
                this.type,
                features
        );
    }

    public List<Route> toEntities() {
        TmapPedestrianResponseDto tmapPedestrianResponseDto = filteredPoint();
        List<Feature> features = tmapPedestrianResponseDto.features;

        List<Route> routes = new ArrayList<>();

        for (Feature feature : features) {
            Properties properties = feature.getProperties();
            List<Double> coordinates = (List<Double>) feature.getGeometry().getCoordinates();
            Route route = new Route();

            String lon = String.valueOf(coordinates.getFirst());
            route.setLon(lon);

            String lat = String.valueOf(coordinates.getLast());
            route.setLat(lat);

            Long pointIndex = Long.valueOf(properties.getPointIndex());
            route.setPointIndex(pointIndex);

            String description = properties.getDescription();
            route.setDescription(description);

            routes.add(route);
        }
        return routes;
    }
}


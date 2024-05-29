package com.example.capstone.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class Feature {
    @JsonProperty("type")
    private String type;

    /*
    geometry.coordinate -> 노드별 위도, 경도
     */
    @JsonProperty("geometry")
    private Geometry
            geometry;

    /*
    properties.pointIndex -> 목적지까지 순차적인 노드 번호
     */
    @JsonProperty("properties")
    private Properties properties;

}

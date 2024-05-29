package com.example.capstone.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class DistanceInfo {
    @JsonProperty("distance")
    private String distance;

    private int pointIndex;

    private String description;

    private String lat;
    private String lon;

    private String dir;

    private int cnt;

}

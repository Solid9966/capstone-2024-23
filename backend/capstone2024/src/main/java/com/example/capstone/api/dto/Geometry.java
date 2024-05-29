package com.example.capstone.api.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class Geometry {
    @JsonProperty("type")
    private String type;

    @JsonProperty("coordinates")
    private Object coordinates;

}

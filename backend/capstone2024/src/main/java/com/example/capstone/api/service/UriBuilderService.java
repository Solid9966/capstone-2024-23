package com.example.capstone.api.service;

import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;

@Service
public class UriBuilderService {

    //좌표 변환
    private static final String TMAP_GEO_CODING_URL = "https://apis.openapi.sk.com/tmap/geo/fullAddrGeo";
    //보행자 경로 검색
    private static final String TMAP_PEDESTRIAN_URL = "https://apis.openapi.sk.com/tmap/routes/pedestrian";
    //POI 검색
    private static final String TMAP_POI_URL = "https://apis.openapi.sk.com/tmap/pois";
    // 두 좌표 간 직선 거리 계산
    private static final String TMAP_DISTANCE = "https://apis.openapi.sk.com/tmap/routes/distance";

    public URI buildUriGeoCodingByAddress(String address) {
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(TMAP_GEO_CODING_URL);
        uriBuilder.queryParam("coordType", "WGS84GEO");
        uriBuilder.queryParam("fullAddr", address);
        uriBuilder.queryParam("addressFlag", "F00");

        URI uri = uriBuilder.build().encode().toUri();
        System.out.println("uri = " + uri);
        return uri;
    }

    //출발지 좌표값, 목적지 좌표값, 출발지 도착지 지명 필요
    public URI buildUriPedestrianByCoord() {
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(TMAP_PEDESTRIAN_URL);
        uriBuilder.queryParam("version", "1");
        URI uri = uriBuilder.build().encode().toUri();
        System.out.println("pede uri = " + uri);
        return uri;
    }

    public URI buildUriPoiByCoord(String address) {
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(TMAP_POI_URL)
                .queryParam("version", "1")
                .queryParam("searchKeyword", address)
                .queryParam("resCoordType", "WGS84GEO")
                .queryParam("reqCoordType", "WGS84GEO");
        URI uri = uriBuilder.build().encode().toUri();
        System.out.println("uri = " + uri);
        return uri;
    }

    public URI buildUriDistanceInfo(String startX, String startY, String endX, String endY){
        UriComponentsBuilder uriComponentsBuilder = UriComponentsBuilder.fromHttpUrl(TMAP_DISTANCE)
                .queryParam("version","1")
                .queryParam("startX",startX)
                .queryParam("startY",startY)
                .queryParam("endX",endX)
                .queryParam("endY",endY);
        URI uri = uriComponentsBuilder.build().encode().toUri();
        System.out.println("uri = " + uri);
        return uri;


    }
}

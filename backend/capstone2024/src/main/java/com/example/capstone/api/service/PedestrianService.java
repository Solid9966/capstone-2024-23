package com.example.capstone.api.service;

import com.example.capstone.api.dto.*;
import com.example.capstone.api.model.Route;
import com.example.capstone.api.repository.RouteRepository;
import com.example.capstone.member.model.Member;
import com.example.capstone.member.repository.MemberRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;


@Service
@RequiredArgsConstructor
public class PedestrianService {
    private final RestTemplate restTemplate;
    private final UriBuilderService uriBuilderService;
    private final PoiService poiService;
    private final ObjectMapper objectMapper;
    private final RouteRepository routeRepository;
    private final MemberRepository memberRepository;

    private static final String APPKEY = "qnMdq4E5hK6Jiying7vO84rBBYBMqE0L8JibODZN";

    public TmapPedestrianResponseDto requestPedestrian(String startLat, String startLon, String endAddress) throws Exception {

        if (ObjectUtils.isEmpty(startLat) || ObjectUtils.isEmpty(startLon) || ObjectUtils.isEmpty(endAddress))
            return null;
        //lon 경도 X
        //lat 위도 Y
        TmapPoiResponseDto tmapPoiResponseDto = poiService.requestPoi(endAddress);

        String endLat = tmapPoiResponseDto.getSearchPoiInfo().getPois().getPoi().getFirst().getFrontLat();
        String endLon = tmapPoiResponseDto.getSearchPoiInfo().getPois().getPoi().getFirst().getFrontLon();


        System.out.println("변환 완료");
        System.out.println("startLat = " + startLat);
        System.out.println("startLon = " + startLon);
        System.out.println("endLat = " + endLat);
        System.out.println("endLon = " + endLon);
        URI uri = uriBuilderService.buildUriPedestrianByCoord();

        HttpHeaders headers = new HttpHeaders();
        headers.add("appKey", APPKEY);

        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("startX", startLon);
        requestBody.put("startY", startLat);
        requestBody.put("endX", endLon);
        requestBody.put("endY", endLat);
        requestBody.put("reqCoordType", "WGS84GEO");
        requestBody.put("startName", "출발지");
        requestBody.put("endName", endAddress);
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(requestBody, headers);
//
        String jsonBody = objectMapper.writeValueAsString(requestBody);
        // 콘솔에 출력
        System.out.println("Request JSON Body: " + jsonBody);

        //api 호출

        // API 호출 및 응답 받기 (String 형태로)
        String rawResponse = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class).getBody();

        // 불법 문자 전처리 (예제: Null 문자 제거)
        String cleanedResponse = rawResponse.replace("\u0000", "");

        // 전처리된 응답을 DTO로 변환
        TmapPedestrianResponseDto responseDto = objectMapper.readValue(
                cleanedResponse, TmapPedestrianResponseDto.class
        );




        return responseDto;
    }


    public TmapPedestrianResponseDto startPedestrianNavi(String startLat, String startLon, String endAddress, String uuid) throws Exception {
        if (ObjectUtils.isEmpty(startLat) || ObjectUtils.isEmpty(startLon) || ObjectUtils.isEmpty(endAddress) || ObjectUtils.isEmpty(uuid))
            return null;
        //lon 경도 X
        //lat 위도 Y
        TmapPoiResponseDto tmapPoiResponseDto = poiService.requestPoi(endAddress);

        String endLat = tmapPoiResponseDto.getSearchPoiInfo().getPois().getPoi().getFirst().getFrontLat();
        String endLon = tmapPoiResponseDto.getSearchPoiInfo().getPois().getPoi().getFirst().getFrontLon();


        System.out.println("변환 완료");
        System.out.println("startLat = " + startLat);
        System.out.println("startLon = " + startLon);
        System.out.println("endLat = " + endLat);
        System.out.println("endLon = " + endLon);
        URI uri = uriBuilderService.buildUriPedestrianByCoord();

        HttpHeaders headers = new HttpHeaders();
        headers.add("appKey", APPKEY);

        Map<String, String> requestBody = new HashMap<>();
        requestBody.put("startX", startLon);
        requestBody.put("startY", startLat);
        requestBody.put("endX", endLon);
        requestBody.put("endY", endLat);
        requestBody.put("reqCoordType", "WGS84GEO");
        requestBody.put("startName", "출발지");
        requestBody.put("endName", endAddress);
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(requestBody, headers);
//
        // 콘솔에 출력
        String jsonBody = objectMapper.writeValueAsString(requestBody);
        System.out.println("Request JSON Body: " + jsonBody);


        // API 호출 및 응답 받기 (String 형태로)
        String rawResponse = restTemplate.exchange(uri, HttpMethod.POST, entity, String.class).getBody();

        // 불법 문자 전처리 (예제: Null 문자 제거)
        String cleanedResponse = rawResponse.replace("\u0000", "");

        // 전처리된 응답을 DTO로 변환
        TmapPedestrianResponseDto responseDto = objectMapper.readValue(cleanedResponse, TmapPedestrianResponseDto.class)
                .filteredPoint();
        System.out.println();
        List<Route> entities = responseDto.toEntities();

        Member member = memberRepository.findByUuid(uuid).getFirst();
        for (Route e : entities) {
            e.setMember(member);
        }
        routeRepository.saveAll(entities);
        return responseDto;
    }

    public DistanceInfo currentLocationCheck(String curLat, String curLon,
                                                    String uuid, int pointIndex, int cnt, int distance){

        List<Route> path = routeRepository.findByMemberUuid(uuid);
        String nextLon = path.get(pointIndex).getLon();
        String nextLat = path.get(pointIndex).getLat();




        URI uri = uriBuilderService.buildUriDistanceInfo(curLon, curLat, nextLon, nextLat);
        HttpHeaders headers = new HttpHeaders();
        headers.set("appKey", APPKEY);

        HttpEntity<Object> httpEntity = new HttpEntity<>(headers);

        //api 호출
        DistanceResponseDTO body = restTemplate.exchange(uri, HttpMethod.GET, httpEntity, DistanceResponseDTO.class).getBody();

        DistanceInfo info = new DistanceInfo();
        int dist = Integer.parseInt(body.getDistanceInfo().getDistance());
        if (dist > distance)
            cnt++;



        if (dist <= 5){
            info.setDistance(String.valueOf(dist));
            info.setPointIndex(pointIndex+1);
            info.setCnt(cnt);
            info.setLat(nextLat);
            info.setLon(nextLon);
            if(pointIndex == path.size()-1){
                info.setDescription("도착");
                System.out.println("dist = " + dist);
                System.out.println("path 최대 인덱스 = " + (path.size()-1));
            }
            else {
                info.setDescription(path.get(pointIndex).getDescription());
                System.out.println("dist = " + dist);
                System.out.println("path 최대 인덱스 = " + (path.size()-1));
            }

            return info;
        }
        else {
            info.setDistance(String.valueOf(dist));
            info.setPointIndex(pointIndex);
            if (cnt >= 4) {
                info.setDescription("재탐색");
                info.setCnt(0);
            }
            else {
                info.setCnt(cnt);
                info.setDescription("이동중");
            }
            info.setLat(nextLat);
            info.setLon(nextLon);

            System.out.println("dist = " + dist);
            System.out.println("path 최대 인덱스 = " + (path.size()-1));
            return info;
        }

    }
    public DirectionInfo directionCheck(String curLat, String curLon,
                                       String uuid, int pointIndex, String curDir){

        List<Route> path = routeRepository.findByMemberUuid(uuid);
        String nextLon = path.get(pointIndex).getLon();
        String nextLat = path.get(pointIndex).getLat();
        //방향 계산

        double startLatDouble = Double.parseDouble(curLat);
        double startLonDouble = Double.parseDouble(curLon);
        double endLatDouble = Double.parseDouble(nextLat);
        double endLonDouble = Double.parseDouble(nextLon);

        double lat1 = Math.toRadians(startLatDouble);
        double lon1 = Math.toRadians(startLonDouble);
        double lat2 = Math.toRadians(endLatDouble);
        double lon2 = Math.toRadians(endLonDouble);

        double dLon = lon2 - lon1;

        double x = Math.cos(lat2) * Math.sin(dLon);
        double y = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);

        double initialBearing = Math.atan2(x, y);

        // Convert bearing from radians to degrees
        initialBearing = Math.toDegrees(initialBearing);
        initialBearing = (initialBearing + 360) % 360;

        // Convert to 45 degree compass directions
        String[] compassDirections = {"N", "E", "S", "W"};
        int index = (int) Math.round(initialBearing / 90) % 4;

        String targetDir = compassDirections[index];

        int currentIndex = -1;
        int targetIndex = -1;
        String dirMsg;

        for (int i = 0; i < compassDirections.length; i++) {
            if (compassDirections[i].equals(curDir)) {
                currentIndex = i;
            }
            if (compassDirections[i].equals(targetDir)) {
                targetIndex = i;
            }
        }
        if (currentIndex == -1 || targetIndex == -1) {
            dirMsg = "방위 계산 오류";
        }


        int difference = targetIndex - currentIndex;
        if (difference < 0) {
            difference += 4;
        }

        if (difference == 0) {
            dirMsg = "해당 방향으로 진행하세요";
        } else if (difference == 1) {
            dirMsg = "오른쪽으로 몸을 돌리세요";
        } else if (difference == 2) {
            dirMsg = "뒤로 돌리세요";
        } else {
            dirMsg = "왼쪽으로 몸을 돌리세요";
        }
        DirectionInfo dirInfo = new DirectionInfo();
        dirInfo.setDirMsg(dirMsg);
        return dirInfo;
    }
    public void cancelNavi(String uuid){
        routeRepository.deleteAllByMemberUuid(uuid);
        System.out.println("uuid = " + uuid + "삭제 중");
    }

}

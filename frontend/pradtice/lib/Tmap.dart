
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:tmap_ui_sdk/tmap_ui_sdk.dart';
//
// // Tmap SDK 인증 및 초기화
// Future<void> initTmap() async {
//   try {
//     // 사용자 단말의 플랫폼 버전을 획득
//     String? platformVersion = await TmapUiSdk().getPlatformVersion();
//
//     // 사용자 인증 입력
//     AuthData authData = AuthData(
//       clientApiKey: "4m4ftbOA1eahz7OJQgmfDAi7P7ugSO89PeiYSEA7", // 필수
//       userKey: "",
//       clientServiceName: "",
//       clientID: "",
//       clientDeviceId: "",
//       clientAppVersion: "",
//       clientApCode: "",
//     );
//
//     // 사용자 인증, 초기화
//     InitResult? result = await TmapUISDKManager().initSDK(authData);
//
//     if (platformVersion != null && result != null && result == InitResult.granted) {
//       print("초기화 성공 : $platformVersion / $result");
//     } else {
//       print("초기화 실패 : $platformVersion / $result");
//     }
//   } catch (e) {
//     print("error ${e.toString()}");
//   }
// }
//
// // 사용자의 차량 정보와 SDK UI의 속성을 설정하는 클래스
// class ConfigCarModel {
//   SDKConfig get normalCar => SDKConfig(
//     carType: UISDKCarModel.normal,
//     fuelType: UISDKFuel.gas,
//     showTrafficAccident: true,
//     mapTextSize: UISDKMapFontSize.small,
//     nightMode: UISDKAutoNightModeType.auto,
//     isUseSpeedReactMapScale: true,
//     isShowTrafficInRoute: false,
//     isShowExitPopupWhenStopDriving: true,
//   );
// }
//
// // 프로젝트 전역에서 사용할 Home 위젯
// class Home extends StatelessWidget {
//   const Home({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         Provider(create: (context) => ConfigCarModel()),
//       ],
//       child: MaterialApp.router(
//         title: "NAVI SDK SAMPLE",
//         theme: ThemeData(primarySwatch: Colors.blue),
//         debugShowCheckedModeBanner: false,
//         routerConfig: _router,
//       ),
//     );
//   }
// }
//
// // 차량 설정 적용
// Future<bool?> setCarConfig(BuildContext context) async {
//   ConfigCarModel model = context.read<ConfigCarModel>();
//
//   bool? result = await TmapUISDKManager().setConfigSDK(model.normalCar);
//
//   return result;
// }
//
// // 경로 요청 위젯
// TmapViewWidget getTmapViewWidget() {
//   RouteRequestData data = RouteRequestData(
//     source: null, // 출발지, null 일 때 SDK 내부적으로 현재위치에서 시작
//     destination: RoutePoint(
//       latitude: 37.566491,
//       longitude: 126.985146,
//       name: "SKT Tower",
//     ), // 목적지, 필수
//     routeOption: [
//       PlanningOption.recommend,
//       PlanningOption.shortest,
//     ], // 경로 옵션
//     wayPoints: null, // 경유지
//     safeDriving: false, // 안전 운행
//     guideWithoutPreview: false, // 선택 없이 바로 안내
//   );
//
//   return TmapViewWidget(data: data);
// }

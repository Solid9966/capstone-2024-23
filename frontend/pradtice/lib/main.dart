import 'package:flutter/material.dart';
import 'ObjectRecognitionMode.dart';
import 'sever.dart'; // 서버 연동 파일 import
import 'dart:async'; //탭 시간차 패키지
import 'package:speech_to_text/speech_recognition_result.dart'; // 음성 인식 패키지
import 'package:speech_to_text/speech_to_text.dart'; // stt -> tts 패키지
import 'STT.dart'; //음성인식 패키지
import 'package:permission_handler/permission_handler.dart';

// import 'Tmap.dart';
import 'GoogleMap.dart';
import 'TextToSpeech.dart';


void main() {
  runApp(
      MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home : MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //sever.dart 에서의 Sever 클래스 상속
  Sever sever = Sever();
  TTS tts = TTS(message: '기본');

  // GoogleMap.dart 에서의 GoogleMap 클래스 상속
  MyGoogleMap mygoogleMap = MyGoogleMap();
  //앱 실행시 백그라운드 실행

  @override
  void initState() {
    super.initState();
    requestPermissions(); //권한 허가
    tts.setMessage('화면을 탭하세요');
    tts.speak();
  }

  //권한 허가
  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.microphone,

    ].request();

    final locationStatus = statuses[Permission.location];
    final cameraStatus = statuses[Permission.camera];
    final micStatus = statuses[Permission.microphone];

    print('위치 권한: $locationStatus');
    print('카메라 권한: $cameraStatus');
    print('마이크 권한: $micStatus');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // _tapCount 변수를 사용하지 않고 바로 Navigator.push를 사용하여
        // 싱글 탭 이벤트 처리 시 SttTab() 호출
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SttTab()),
        );
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(4.0), // 밑줄의 높이 설정
              child: Container(
                color: Colors.black, // 밑줄의 색상 설정
                height: 0, // 밑줄의 두께 설정
              ),
            ),
          ),

          backgroundColor: Colors.blueGrey, // Scaffold의 배경색을 설정
          body:Container(
            color: Colors.blueGrey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 150.0), // 마이크 아이콘과 모드 버튼들 사이의 간격을 조정
                  child: Center(
                    child: Image.asset('assets/eye_u_mono.png'),
                    // child: ElevatedButton(
                    //   onPressed: (){
                    //     Navigator.push(context,
                    //       MaterialPageRoute(builder: (context) => SttTab()),
                    //     );
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     shape: CircleBorder(), // 버튼을 원형으로 만듦
                    //     padding: EdgeInsets.all(20), // 원형 버튼 내부의 아이콘과의 padding
                    //   ),
                    //   child: Icon(Icons.mic, size: 40.0,color: Colors.blueGrey,), // 아이콘 크기를 조정하여 화면 비중 감소
                    // ),
                  ),
                ),
              ],
            ),
          )



      ),
    );
  }
}

class ConvenienceMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('편의 기능 모드'),
      ),
      body: Center(
        child: Text('여기에 편의 기능 모드의 기능을 구현해주세요.'),
      ),
    );
  }
}

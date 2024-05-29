import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'TextToSpeech.dart';
import 'package:vibration/vibration.dart';

import 'sever.dart';
enum Options { none, imagev5, imagev8, imagev8seg, frame }

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  runApp(
    const MaterialApp(
      home: ObjectReco(tabnum: 1,),
    ),
  );
}


class ObjectReco extends StatefulWidget {
  const ObjectReco({Key? key,required this.tabnum}) : super(key: key);
  final int tabnum;

  @override
  State<ObjectReco> createState() => _ObjectRecoState();
}

class _ObjectRecoState extends State<ObjectReco> {
  late FlutterVision vision;
  Options option = Options.frame;

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
  }

  @override
  void dispose() async {
    super.dispose();
    await vision.closeTesseractModel();
    await vision.closeYoloModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: task(option),
    );
  }

  Widget task(Options option) {
    if (option == Options.frame) {
      return YoloVideo(vision: vision,tabnum: widget.tabnum,);
    }
    return const Center(child: Text("Choose Task"));
  }
}

class YoloVideo extends StatefulWidget {
  final FlutterVision vision;
  final int tabnum;
  const YoloVideo({Key? key, required this.vision, required this.tabnum}) : super(key: key);

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller;
  late List<Map<String, dynamic>> yoloResults;
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;
  TTS tts = TTS(message: '');
  Sever sever = Sever();

  Timer? timer;

  @override
  void initState() {
    super.initState();
    init();
  }

  // 카메라 초기화
  void init() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    await loadYoloModel();
    sever.setid();
    setState(() {
      isLoaded = true;
      isDetecting = false;
      yoloResults = [];
    });
  }

  @override
  void dispose() async {
    super.dispose();
    timer?.cancel();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    if(widget.tabnum==1){
      return GestureDetector(
        onTap: () {
          startDetection();
          sever.current_location();
        },
        onDoubleTap: () {
          sever.ttsread();
        },
        onLongPress: () {
          tts.setMessage('경로안내를 취소하려면 한번, 아니면 두번을 터치하세요');
          tts.speak();
          showDialog(
              context: context,
              builder: (context) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      timer?.cancel();
                      sever.cancel_navi();
                    },
                    onDoubleTap: () {
                      Navigator.pop(context);
                    },
                  ));
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
            ...displayBoxesAroundRecognizedObjects(size),

            //탐지 확인용 아이콘
            // Positioned(
            //   bottom: 75,
            //   width: MediaQuery.of(context).size.width,
            //   child: Center(
            //     child: Icon(
            //       isDetecting ? Icons.stop : Icons.play_arrow,
            //       color: isDetecting ? Colors.red : Colors.white, // Adjust icon color
            //       size: 80, // Adjust icon size
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    } else{
      return GestureDetector(
        onTap: () {
          if (!isDetecting) {
            startDetection();
          } else {
            // Execute stopDetection when isDetecting is true
            stopDetection();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
            ...displayBoxesAroundRecognizedObjects(size),

            //탐지 확인용 아이콘
            // Positioned(
            //   bottom: 75,
            //   width: MediaQuery.of(context).size.width,
            //   child: Center(
            //     child: Icon(
            //       isDetecting ? Icons.stop : Icons.play_arrow,
            //       color: isDetecting ? Colors.red : Colors.white, // Adjust icon color
            //       size: 80, // Adjust icon size
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    }
  }

  // YOLO 모델 로드
  Future<void> loadYoloModel() async {
    await widget.vision.loadYoloModel(
      labels: 'assets/labels.txt',
      modelPath: 'assets/yolov5n.tflite',
      modelVersion: "yolov5",
      numThreads: 2,
      useGpu: true,
    );
  }

  // 객체 탐지 시작
  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (!controller.value.isStreamingImages) {
      await controller.startImageStream((image) {
        if (isDetecting) {
          cameraImage = image;
          yoloOnFrame(image);
        }
      });
    }
  }

  // 객체 탐지 중지
  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      yoloResults.clear();
    });
  }

  // 카메라 프레임에서 YOLO 객체 탐지
  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await widget.vision.yoloOnFrame(
      bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      iouThreshold: 0.4,
      confThreshold: 0.4,
      classThreshold: 0.5,
    );

    if (result.isNotEmpty) {
      setState(() {
        // 필터링할 클래스 레이블
        List<String> targetLabels = [
          "bicycle",
          "car",
          "motorbike",
          "traffic light",
          "fire hydrant",
          "stop sign",
          "parking meter",
          "person",
          "chair",
        ];

        // 필터링된 결과를 저장할 리스트
        List<Map<String, dynamic>> filteredResults = [];

        // 필터링된 결과를 추출
        for (var obj in result) {
          if (targetLabels.contains(obj['tag'])) {
            filteredResults.add(obj);
          }
        }

        // 필터링된 결과를 사용하여 작업 수행
        for (var obj in filteredResults) {
          double bottomY = obj['box'][1] + obj['box'][3];
          if (bottomY > 730 && targetLabels.contains(obj['tag'])) {
            // tts.setMessage('위험');
            // tts.speak();
            Vibration.vibrate(duration: 500);
          }
        }

        // 필터링된 결과를 yoloResults에 업데이트
        yoloResults = filteredResults;
      });
    }
  }

  // 객체를 인식하여 박스 표시
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];

    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);

    // 필터링할 클래스 레이블
    List<String> targetLabels = [
      "bicycle",
      "car",
      "motorbike",
      "traffic light",
      "fire hydrant",
      "stop sign",
      "parking meter",
      "person",
      "chair"
    ];

    // 필터링된 결과를 저장할 리스트
    List<Map<String, dynamic>> filteredResults = [];

    // 필터링된 결과를 추출
    for (var result in yoloResults) {
      if (targetLabels.contains(result['tag'])) {
        filteredResults.add(result);
      }
    }

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return filteredResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}

class PolygonPainter extends CustomPainter {
  final List<Map<String, double>> points;

  PolygonPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(129, 255, 2, 124)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0]['x']!, points[0]['y']!);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i]['x']!, points[i]['y']!);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

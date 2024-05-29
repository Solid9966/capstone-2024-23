import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class TTS{
  String message;
  final FlutterTts tts = FlutterTts();

  TTS({required this.message}){
    initialize();
  }

  void initialize() async {
    await tts.setLanguage('ko-KR');
    await tts.setSpeechRate(0.5);
  }

  void setMessage(String setMessage){
    message = setMessage;
  }

  void speak(){
    tts.speak(message);
  }
}
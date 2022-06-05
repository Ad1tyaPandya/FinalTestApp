import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:rxdart/src/streams/value_stream.dart';

import 'package:rxdart/src/subjects/behavior_subject.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'api.dart';
import "dart:typed_data";
import 'dart:convert';
import 'package:wav/wav.dart';

enum RecordState { ready, recording, paused, error }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Male VS Female',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Gender identification through voice'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _pressed = false;
  final Record _record = Record();

  final _recordStateSubject =
      BehaviorSubject<RecordState>.seeded(RecordState.ready);
  ValueStream<RecordState> get recordStateStream => _recordStateSubject.stream;
  set recordState(RecordState v) => _recordStateSubject.add(v);
  int bitRate = 128000;
  double samplingRate = 22050;
  String fileFormat = "wav";
  String output = "";

  int lengthOfHistory = 20;
  String instruction = "Tap the recording button to start recording";
  String notification = "";
  String PathS = "";
  bool analize = false;

  final recordingPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<bool> checkPermission() async {
    final bool permission = await _record.hasPermission();
    if (permission) {
      recordState = RecordState.ready;
    } else {
      recordState = RecordState.error;
    }
    return permission;
  }

  Future<void> startRecord(String path) async {
    try {
      await _record.start(
        path: "$path/output.$fileFormat",
        encoder: AudioEncoder.aacHe,
        bitRate: bitRate,
        samplingRate: samplingRate.toInt(),
      );
      // await flutterFft.startRecorder();
      if (kDebugMode) {
        print("$path/output.$fileFormat");
      }
      recordState = RecordState.recording;

      // freq();
      // output += "Started Recording";
    } catch (e) {
      // logger.e(e, e, s);
      recordState = RecordState.error;
    }
  }

  Future<String> stopRecord() async {
    try {
      final path = await _record.stop() ?? "";
      // await flutterFft.stopRecording();
      // output += "Stopped Recording";
      recordState = RecordState.ready;

      // if (kDebugMode) {
      //   print(path);
      // }
      return path;
    } catch (e) {
      recordState = RecordState.error;
      print("ERRORED IN STOPPING");
      return "";
    }
  }

  Future<String> apppath() async {
    // output = (await getExternalStorageDirectory())?.path.toString() ?? "";
    return (await getExternalStorageDirectory())?.absolute.path ?? "";
  }

  void getbytes() async {
    print(PathS);
    setState(() {
      notification = 'Analyzing....';
    });
    if (PathS.isNotEmpty) {
      String path = PathS;

      File file = File(path);
      Uint8List bytes = file.readAsBytesSync();
      var data = await (fetchdata('http://10.0.2.2:5000/api?array=$bytes'));
      data = jsonDecode(data);
      setState(() {
        output = "You are a ${data['output'].toString()}";
        notification = '';
      });
    } else {
      setState(() {
        notification = "Please record your voice first!";
      });
    }
  }

  void recording() async {
    String x;

    if (_pressed) {
      // if _pressed is true then stop recording
      String x = "";
      x = await stopRecord();
      setState(() {
        instruction = "Tap the recording button to start recording";
        notification = '';
      });
      getbytes();
    } else {
      x = await apppath();
      startRecord(x);
      setState(() {
        notification = "Recording ....";
        instruction = "Press again to stop recording and to analyze the audio";
      });
    }
  }

  void stopping() async {
    if (_pressed) {
      // if _pressed is true then stop recording
      String x = "";
      x = await stopRecord();
      setState(() {
        instruction =
            "Tap the analyze button to analyze the audio or record again";
        notification = '';
        analize = true;
      });
      PathS = x;
    }
  }

  void starting() async {
    if (!_pressed) {
      String x = await apppath();
      // output += x;
      // output += "<--- this is the path that is handed";
      // output += 'start record';
      startRecord(x);
      setState(() {
        analize = false;
        notification = "Recording ....";
        instruction = "Press the Stop Recording button to stop recording";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // text(output)
          children: <Widget>[
            Text(instruction),
            Text(
              output,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: BorderSide(
                      color: _pressed ? Colors.grey : Colors.green,
                    ),
                  ),
                ),
              ),
              onPressed: () => {
                // output += " _pressed value: ${_pressed}",
                starting(),
                // updateoutput(),
                setState(
                  () {
                    _pressed = !_pressed;
                  },
                ),
              },
              child: Text("Start Recording",
                  style:
                      TextStyle(color: _pressed ? Colors.grey : Colors.green)),
            ),
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: BorderSide(
                      color: _pressed ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ),
              onPressed: () => {
                // output += " _pressed value: ${_pressed}",
                stopping(),
                // updateoutput(),
                setState(
                  () {
                    _pressed = !_pressed;
                  },
                ),
              },
              child: Text("Stop Recording",
                  style:
                      TextStyle(color: _pressed ? Colors.green : Colors.grey)),
            ),
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: BorderSide(
                      color: analize ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ),
              onPressed: () => {
                getbytes(),
              },
              child: Text(
                "Analyze Recording",
                style: TextStyle(color: analize ? Colors.green : Colors.grey),
              ),
            ),
            Text(notification),
          ],
        ),
      ),
    );
  }
}

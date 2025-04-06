import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyAudioApp());
}

class MyAudioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Audio App',
      home: AudioRecorderPage(),
    );
  }
}

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  String? _recordedFilePath;
  String _transcript = '';

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    // Open the recorder
    await _recorder.openRecorder();
    setState(() {
      _isRecorderInitialized = true;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) return;
    // Get a temporary directory to save the recording
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/audio.wav';

    // Start recording using the WAV codec
    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecorderInitialized) return;
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _sendAudioToServer() async {
    if (_recordedFilePath == null) return;

    // Use the special IP for Android emulator to reach your host machine
    var uri = Uri.parse('http://10.0.2.2:5000/transcribe');
    var request = http.MultipartRequest('POST', uri);

    // Attach the audio file in a multipart form field named 'audio'
    request.files.add(
      await http.MultipartFile.fromPath('audio', _recordedFilePath!),
    );

    // Send the request
    var response = await request.send();
    if (response.statusCode == 200) {
      // Read the response (assume it's plain text or JSON)
      String responseData = await response.stream.bytesToString();
      setState(() {
        _transcript = responseData;
      });
    } else {
      setState(() {
        _transcript = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder & Transcriber'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendAudioToServer,
              child: Text('Send Audio to Node.js'),
            ),
            SizedBox(height: 16),
            Text(
              'Transcript:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _transcript,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

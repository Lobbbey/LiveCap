// Import necessary Dart and Flutter libraries.
import 'dart:async';                // For asynchronous programming and stream subscriptions.
import 'dart:typed_data';           // To work with Uint8List, which represents binary audio data.
import 'dart:convert';              // For encoding and decoding JSON messages.

import 'package:flutter/material.dart';           // Flutter's material design UI library.
import 'package:mic_stream/mic_stream.dart';        // Package to capture raw audio data from the microphone.
import 'package:permission_handler/permission_handler.dart';  // Package to request runtime permissions.
import 'package:web_socket_channel/io.dart';        // Package to connect to a WebSocket server.

// Entry point of the Flutter application.
void main() {
  runApp(MyAudioApp());
}

// Main app widget.
class MyAudioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real-time Transcription',
      home: TranscriptionPage(),  // Home page of the app.
    );
  }
}

// A stateful widget that manages the transcription UI and logic.
class TranscriptionPage extends StatefulWidget {
  @override
  _TranscriptionPageState createState() => _TranscriptionPageState();
}

// The state class for TranscriptionPage.
class _TranscriptionPageState extends State<TranscriptionPage> {
  IOWebSocketChannel? _channel;                    // WebSocket channel for communicating with the Node.js server.
  StreamSubscription<Uint8List>? _micSubscription;  // Subscription to the microphone's audio stream.
  String _transcript = '';                          // Holds the transcript text received from the server.
  bool _streaming = false;                          // Indicates whether streaming is currently active.

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Transcription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Button to start transcription; disabled if already streaming.
            ElevatedButton(
              onPressed: _streaming ? null : _startStreaming,
              child: Text('Start Transcription'),
            ),
            SizedBox(height: 16),
            // Button to stop transcription; disabled if not streaming.
            ElevatedButton(
              onPressed: _streaming ? _stopStreaming : null,
              child: Text('Stop Transcription'),
            ),
            SizedBox(height: 16),
            // Label for the transcript.
            Text(
              'Transcript:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            // A scrollable area to display the transcript text.
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

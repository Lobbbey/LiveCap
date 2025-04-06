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
  void initState() {
    super.initState();
    // Initialize microphone access and connect to the WebSocket server when the widget is created.
    _initMicAndConnect();
  }

  // This function requests microphone permission and connects to the WebSocket server.
  Future<void> _initMicAndConnect() async {
    // Request the microphone permission.
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    // Connect to the WebSocket server.
    // Use "10.0.2.2" to access your host machine from the Android emulator.
    _channel = IOWebSocketChannel.connect('ws://10.0.2.2:8080');

    // Listen for incoming messages from the WebSocket server.
    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        setState(() {
          _transcript = data['transcript'] ?? _transcript;
      });
      },
      onError: (error) => print("WebSocket error: $error"),
      onDone: () {
        print("WebSocket closed");
        setState(() => _streaming = false);
      },
    );
  }

  // Starts streaming the microphone audio to the WebSocket server.
  Future<void> _startStreaming() async {
    // Configure and start the microphone stream.
    // These settings match your Node.js server and Google Speech configuration:
    // - 48000 Hz sample rate.
    // - Mono channel.
    // - 16-bit PCM audio format.
    final stream = await MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      sampleRate: 48000,
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,
      audioFormat: AudioFormat.ENCODING_PCM_16BIT,
    );

    // Listen to the audio stream and send each audio chunk over the WebSocket.
    if (stream != null) {
      _micSubscription = stream.listen((data) {
        _channel?.sink.add(data);
      });
    } else {
      print("Mic stream is null!");
    }
      // "data" is a Uint8List containing raw PCM audio.

    // Update state to indicate that streaming has started.
    setState(() {
      _streaming = true;
    });
  }

  // Stops streaming the microphone audio and closes the WebSocket connection.
  void _stopStreaming() {
    // Cancel the subscription to the microphone stream.
    _micSubscription?.cancel();
    // Close the WebSocket connection.
    _channel?.sink.close();
    // Update state to indicate that streaming has stopped.
    setState(() {
      _streaming = false;
    });
  }

  // Dispose resources when the widget is removed from the widget tree.
  @override
  void dispose() {
    _stopStreaming();  // Ensure streaming is stopped.
    super.dispose();
  }

  // Builds the UI of the transcription page.
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
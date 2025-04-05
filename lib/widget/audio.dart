import 'dart:math'; // For max and min
import 'package:flutter/material.dart';
//import 'package:live_cap/widget/audio.dart'; // Replace with actual package

class AudioPage extends StatefulWidget {
  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  @override
  void initState() {
    super.initState();

    AudioStreamer().audioStream.listen(
      (List<double> buffer) {
        print('Max amp: ${buffer.reduce(max)}');
        print('Min amp: ${buffer.reduce(min)}');
      },
      onError: (Object error) {
        print('Stream error: $error');
      },
      cancelOnError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Audio Stream")),
      body: Center(child: Text("Listening...")),
    );
  }
}

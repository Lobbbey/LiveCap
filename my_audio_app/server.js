// server.js
const WebSocket = require('ws');
const speech = require('@google-cloud/speech');

const client = new speech.SpeechClient();

const encoding = 'LINEAR16';
const sampleRateHertz = 48000;
const languageCode = 'en-US';

const request = {
  config: {
    encoding: encoding,
    sampleRateHertz: sampleRateHertz,
    languageCode: languageCode,
    audioChannelCount: 1, // Tell Google it's mono
  },
  interimResults: true, // For smoother streaming experience
};

const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
  console.log('Client connected.');

  // Create a recognition stream from Google
  const recognizeStream = client
    .streamingRecognize(request)
    .on('data', (data) => {
      const transcript = data.results?.[0]?.alternatives?.[0]?.transcript;
      if (transcript) {
        // Send the transcript back to the Flutter client
        ws.send(JSON.stringify({ transcript }));
      }
    })
    .on('error', (err) => {
      console.error('Google Speech error:', err);
    })
    .on('end', () => {
      console.log('Google stream ended.');
    });

  // When audio data arrives from the client, write it into the recognition stream
  ws.on('message', (message) => {
    // Here, message is a Buffer containing raw PCM data.
    recognizeStream.write(message);
  });

  ws.on('close', () => {
    console.log('Client disconnected.');
    recognizeStream.end();
  });
});

console.log('WebSocket server listening on ws://localhost:8080');

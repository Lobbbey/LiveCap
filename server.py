
import os
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "livecap-key.json"

import asyncio
import websockets
import json
from google.cloud import speech_v1p1beta1 as speech

# Setup Google Speech client
client = speech.SpeechClient()

# Audio config for Google API
config = speech.RecognitionConfig(
    encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
    sample_rate_hertz=48000,
    language_code="en-US",
    audio_channel_count=1,
)

streaming_config = speech.StreamingRecognitionConfig(
    config=config,
    interim_results=True,
)

# This handles a single WebSocket client
async def handle_connection(websocket):
    print("Client connected")

    # Create an async generator for the microphone stream
    async def request_generator():
        while True:
            try:
                audio_chunk = await websocket.recv()
                yield speech.StreamingRecognizeRequest(audio_content=audio_chunk)
            except websockets.exceptions.ConnectionClosed:
                print("Client disconnected")
                break

    # Start streaming recognition
    try:
        responses = client.streaming_recognize(streaming_config, request_generator())

        async for response in responses:
            for result in response.results:
                if result.alternatives:
                    transcript = result.alternatives[0].transcript
                    await websocket.send(json.dumps({"transcript": transcript}))
    except Exception as e:
        print(f"Error in streaming: {e}")

# Start WebSocket server
async def main():
    async with websockets.serve(handle_connection, "0.0.0.0", 8080):
        print("WebSocket server listening on ws://0.0.0.0:8080")
        await asyncio.Future()  # Run forever

if __name__ == "__main__":
    asyncio.run(main())

import os
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "livecap-key.json"

import asyncio
import wave
from google.cloud import speech_v1p1beta1 as speech

# Setup the Speech-to-Text client
client = speech.SpeechClient()

# Audio configuration (must match your WAV file parameters)
config = speech.RecognitionConfig(
    encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
    sample_rate_hertz=16000,
    language_code="en-US",
    audio_channel_count=1,
)

streaming_config = speech.StreamingRecognitionConfig(
    config=config,
    interim_results=True,
)

def wav_request_generator(wav_path, chunk_size=4096):
    # Open the WAV file (make sure it is 48000 Hz, mono, 16-bit PCM)
    with wave.open(wav_path, 'rb') as wf:
        # Log the file parameters for confirmation
        print(f"WAV file parameters: {wf.getframerate()} Hz, {wf.getnchannels()} channel(s), {wf.getsampwidth() * 8} bits")
        while True:
            data = wf.readframes(chunk_size)
            if not data:
                break
            # Yield the audio data in the format expected by Google
            yield speech.StreamingRecognizeRequest(audio_content=data)
            # Optionally, add a small sleep to mimic real-time streaming:
            # await asyncio.sleep(0.1)

async def test_wav(wav_path):
    responses = client.streaming_recognize(streaming_config, wav_request_generator(wav_path))
    # Use a synchronous for loop since responses is not an async iterator.
    for response in responses:
        print("📨 Raw response:", response)
        for result in response.results:
            if result.alternatives:
                transcript = result.alternatives[0].transcript
                print("🗣️ Transcript:", transcript)


if __name__ == '__main__':
    # Replace 'test.wav' with the path to your WAV file
    wav_file_path = "test.wav"
    asyncio.run(test_wav(wav_file_path))

import assemblyai as aai
import keyboard
import random
import http.client
from playsound import playsound
import boto3
from boto3 import Session
from pipewire_recorder import PipeWireRecorder
import os
import time
import simpleaudio as sa
from pydub import AudioSegment

#poly api
session = Session(
    region_name="<location>",
    aws_access_key_id="<aws key>",
    aws_secret_access_key="<aws secret>",
)
polly_client = session.client("polly", region_name="eu-north-1")

#assembly ai api
aai.settings.api_key = "<assemblyai api>"
transcriber = aai.Transcriber()

print('Press "e" to start recording and "s" to stop')

recorder = PipeWireRecorder(44100)
transcript = None

def play_audio(file_path):
    wave_obj = sa.WaveObject.from_wave_file(file_path)
    play_obj = wave_obj.play()
    play_obj.wait_done()

def stop_recording():
    global transcript
    recorder.stop_recording()
    transcript = transcriber.transcribe(recorder.file_name)
    waifu_response = waifu()
    print(waifu_response)

    response = polly_client.synthesize_speech(
        Text=waifu_response, OutputFormat="mp3", VoiceId="Joanna"
    )
    output = f"{random.randint(1, 1000)}.mp3"
    with open(output, "wb") as file:
        file.write(response["AudioStream"].read())

    # Convert MP3 to WAV
    audio = AudioSegment.from_mp3(output)
    wav_output = f"{random.randint(1, 1000)}.wav"
    audio.export(wav_output, format='wav')

    # Play the WAV audio
    play_audio(wav_output)

def waifu():
    conn = http.client.HTTPSConnection("waifu.p.rapidapi.com")

    data = transcript.text if transcript else ""

    payload = (
        '{"message": "'
        + data
        + '", "from_name": "Boy", "to_name": "Girl", "situation": "Girl loves Boy.", "translate_from": "auto", "translate_to": "auto"}'
    )
    #waifu ai api
    headers = {
        "content-type": "application/json",
        "X-RapidAPI-Key": "<waifuai rapid api>",
        "X-RapidAPI-Host": "waifu.p.rapidapi.com",
    }

    conn.request("POST", "/path?user_id=sample_user_id", payload, headers)

    res = conn.getresponse()
    data = res.read()

    return data.decode("utf-8")


keyboard.on_press_key("e", lambda _: recorder.start_recording())
keyboard.on_press_key("s", lambda _: stop_recording())

keyboard.wait("esc")  # Wait for 'esc' key press to exit the program

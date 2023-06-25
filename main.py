import assemblyai as aai
import keyboard
import random
import http.client
from playsound import playsound
import boto3
from boto3 import Session
from pipewire_recorder import PipeWireRecorder
#import subprocess 
import os
import time

session = Session(
    region_name="eu-north-1",
    aws_access_key_id="AKIAQMPXS2JF4PFWU7VG",
    aws_secret_access_key="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",
)
polly_client = session.client("polly", region_name="eu-north-1")

aai.settings.api_key = "4df30ebed1254300af42005de8aca918"
transcriber = aai.Transcriber()

print('Press "e" to start recording and "s" to stop')

recorder = PipeWireRecorder(44100)
transcript = None

def play_audio(file_path):
    time.sleep(5)
    os.system('./script.sh')

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
    #playsound(output)
    #os.system("mpg123  " + output)	
    play_audio(output)
def waifu():
    conn = http.client.HTTPSConnection("waifu.p.rapidapi.com")

    data = transcript.text if transcript else ""

    payload = (
        '{"message": "'
        + data
        + '", "from_name": "Boy", "to_name": "Girl", "situation": "Girl loves Boy.", "translate_from": "auto", "translate_to": "auto"}'
    )

    headers = {
        "content-type": "application/json",
        "X-RapidAPI-Key": "1ad22d441fmsh6e3b6b479272ff4p18915fjsn16204f31152f",
        "X-RapidAPI-Host": "waifu.p.rapidapi.com",
    }

    conn.request("POST", "/path?user_id=sample_user_id", payload, headers)

    res = conn.getresponse()
    data = res.read()

    return data.decode("utf-8")


keyboard.on_press_key("e", lambda _: recorder.start_recording())
keyboard.on_press_key("s", lambda _: stop_recording())

keyboard.wait("esc")  # Wait for 'esc' key press to exit the program

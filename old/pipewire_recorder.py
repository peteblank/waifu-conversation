import soundfile as sf
import sounddevice as sd
import random

class PipeWireRecorder:
    def __init__(self, samplerate):
        self.samplerate = samplerate
        self.is_recording = False
        self.file_name = ""
        self.recording = None

    def start_recording(self):
        if not self.is_recording:
            self.is_recording = True
            print("Recording started")
            self.file_name = f"file{random.randint(1, 10000)}.wav"
            self.recording = sd.rec(
                int(self.samplerate * 10), samplerate=self.samplerate, channels=1
            )

    def stop_recording(self):
        if self.is_recording:
            self.is_recording = False
            print("Recording stopped")
            sd.wait()
            sf.write(self.file_name, self.recording, samplerate=self.samplerate)

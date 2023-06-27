#!/bin/bash

mp3_file="output.mp3"
s3_bucket_name="<your s3 bucket name>"
transcription_job_name="MyTranscriptionJob3"
random_number=$((1 + RANDOM % 1000))
recording_file="recording_${random_number}.wav"
waifu_rapidapi_key=""

aws configure

# Function to play audio
play_audio() {
    # Implement audio playback using appropriate Bash commands or tools
    # Example: aplay, play, etc.
    # Make sure to pass the file path as an argument to the function
    mplayer "$1"
}

# Start recording
start_recording() {
    echo "Press 'e' to start recording and 's' to stop recording."

    # Wait for 'e' key to start recording
    while true; do
        read -rsn1 key
        if [[ $key == 'e' ]]; then
            break
        fi
    done

    echo "Recording started."

    # Start audio recording using arecord
    arecord -f S16_LE -r 44100 -c 1 "$recording_file" &
    arecord_pid=$!

    # Wait for 's' key to stop recording
    while true; do
        read -rsn1 key
        if [[ $key == 's' ]]; then
            break
        fi
    done

    # Stop the audio recording
    kill -SIGINT "$arecord_pid"

    echo "Recording stopped."
}

# Upload the recording to the S3 bucket
upload_recording() {
    aws s3 cp "$recording_file" "s3://$s3_bucket_name/$mp3_file"
}

# Start the transcription job
start_transcription() {
    aws transcribe start-transcription-job \
        --transcription-job-name "$transcription_job_name" \
        --language-code "en-US" \
        --media "MediaFileUri=s3://$s3_bucket_name/$mp3_file" \
        --output-bucket-name "$s3_bucket_name"
}

# Wait for the transcription job to complete
wait_transcription() {
    aws transcribe wait transcription-job-completed --transcription-job-name "$transcription_job_name"
}

# Retrieve the JSON transcription result from the S3 bucket
retrieve_transcription_result() {
    json_output_file="$transcription_job_name.json"
    aws s3 cp "s3://$s3_bucket_name/$json_output_file" .

    # Extract the transcript value from the JSON file
    transcript=$(jq -r '.results.transcripts[0].transcript' "$json_output_file")

    # Display the transcript value
    echo "Transcript:"
    echo "$transcript"
}

# Send transcript to waifu API and get response
send_transcript_to_waifu() {
    waifu_response=$(curl --request POST \
        --url 'https://waifu.p.rapidapi.com/path?user_id=sample_user_id&message='"$transcript"'&from_name=Boy&to_name=Girl&situation=Girl%20loves%20Boy.&translate_from=auto&translate_to=auto' \
        --header 'X-RapidAPI-Host: waifu.p.rapidapi.com' \
        --header 'X-RapidAPI-Key: '$waifu_rapidapi_key \
        --header 'content-type: application/json' \
        --data '{}')

    # Display the waifu response
    echo "Waifu Response:"
    echo "$waifu_response"
}

# Synthesize speech using Polly and save as MP3
synthesize_speech() {
    polly_output_file="response.mp3"
    aws polly synthesize-speech \
        --output-format mp3 \
        --text "$waifu_response" \
        --voice-id "Joanna" \
        $polly_output_file
}

# Play the synthesized speech
play_synthesized_speech() {
    mplayer "$polly_output_file"
}

# Main script
start_recording
upload_recording
start_transcription
wait_transcription
retrieve_transcription_result
send_transcript_to_waifu
synthesize_speech
play_synthesized_speech

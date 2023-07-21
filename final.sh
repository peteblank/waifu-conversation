#!/bin/bash

mp3_file="output.mp3"
s3_bucket_name="<your s3 bucket name>"
random_number=$((1 + RANDOM % 1000))
transcription_job_name="MyTranscriptionJob${random_number}"
#recording_file="recording_${random_number}.wav"
waifu_rapidapi_key=""

#aws configure

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
new_record(){
# Start recording
    # Define the GPIO pin that the button is connected to
    button_pin=122

    # Export the GPIO pin
    sudo echo $button_pin > /sys/class/gpio/export

    # Set the GPIO pin to input mode
    sudo echo in > /sys/class/gpio/gpio$button_pin/direction

    # Initialize a variable to keep track of the button state
    button_state="start"

    echo "Press the button to start recording and press it again to stop recording."

    while true; do
        # Read the value of the GPIO pin
        value=$(cat /sys/class/gpio/gpio$button_pin/value)

        # Check if the button is pressed
        if [ "$value" == "0" ]; then
            if [ "$button_state" == "start" ]; then
                echo "Recording started."
		# Generate a random number between 1 and 1000
                random_number=$((1 + RANDOM % 1000))

                # Create the output file name
                recording_file="recording_${random_number}.wav"

                # Start audio recording using arecord
                arecord -f S16_LE -r 44100 -c 1 "$recording_file" &
                arecord_pid=$!

                button_state="stop"
            else
                echo "Recording stopped."

                # Stop the audio recording
                kill -SIGINT "$arecord_pid"

                break
            fi

            # Wait for the button to be released
            while [ "$value" == "0" ]; do
                value=$(cat /sys/class/gpio/gpio$button_pin/value)
                sleep 0.1
            done
        fi

        # Sleep for a tenth of a second
        sleep 0.1
    done

    # Unexport the GPIO pin
    sudo echo $button_pin > /sys/class/gpio/unexport

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
        --header 'X-RapidAPI-Key: $waifu_rapidapi_key' \
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
# Clean up sound files from AWS S3 bucket and local folder
clean_up() {
  # Remove sound files from AWS S3 bucket
  aws s3 rm "s3://$s3_bucket_name/$mp3_file"
  json_output_file="$transcription_job_name.json"
  aws s3 rm "s3://$s3_bucket_name/$json_output_file"

  # Remove sound files from local folder
  rm -f "$recording_file" "$json_output_file" "$polly_output_file"
}
# Main script
#start_recording
while true;do
{
new_record
upload_recording
start_transcription
wait_transcription
retrieve_transcription_result
send_transcript_to_waifu
synthesize_speech
play_synthesized_speech
clean_up
}
done

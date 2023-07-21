# waifu-conversation
talking to the waifu via mic

# how to install in bash (recommended)

copy paste the following in the command line:

sudo apt install awscli mplayer arecord jq

then run the script with ./final.sh

I added aws config in the script so you can enter your information for aws-cli.

Also remember to create an s3 bucket and put the information for the bucket in the script along with the rapidAPI for waifuAI.

https://rapidapi.com/waifuai/api/waifu

# how to install python

1.run pip install -r requirements.txt

2.run main.py

3.hope it works

You'll also need aws poly api, waifu ai rapid api and assemblyai api.

# running it on the orange pi

You're going to want to turn the script into a service so it'll start automatically everytime it boots.

Replace the exec=file portion of waifu.service with the full path of the file.

ex:/home/ubuntu/waifu-conversation/final.sh

Then enable it with:

sudo systemctl enable waifu

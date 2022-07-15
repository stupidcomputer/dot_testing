import httplib2
import json
import math
import time

# fun fact: i got bored so made this on a southwest flight

while True:
    request = httplib2.Http()
    # you have to look in the network tab in 'inspect element', and find the '_' parameter, and paste that in
    # of course, you have to be connected to southwest's onboard wifi
    _param = "fill this in"
    data = request.request("https://getconnected.southwestwifi.com/fp3d_fcgi-php/portal/public/index.php?_url=/index/getFile&path=last&_=" + _param)
    data = json.loads(data[1])
    print("-- Update --")
    print("Nautical Miles: " + str(data["distanceToDestinationNauticalMiles"]))
    print("Phase: " + data["presentPhase"])
    print("Speed: " + str(data["groundSpeedKnots"]) + "kts")
    seconds = data['timeToDestination']
    minutes = math.floor(seconds / 60)
    seconds = seconds % 60
    print("Minutes: " + str(minutes) + " Seconds: " + str(seconds))
    print("Flight Number: " + data["flightNumber"] + " Registration: " + data["tailNumber"])

    time.sleep(3)
    print('\033[H\033[2J')

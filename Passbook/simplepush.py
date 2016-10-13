#! /usr/bin/env python

import socket, ssl, json, struct
import sys

# device token returned when the iPhone application
# registers to receive alerts
# It should be the argument to this script

deviceToken = sys.argv[1]

thePayLoad = {
     'aps': {
          'sound':'default',
          },
     }

# Certificate issued by apple and converted to .pem format with openSSL
# Per Apple's Push Notification Guide (end of chapter 3), first export the cert in p12 format
# openssl pkcs12 -in cert.p12 -out cert.pem -nodes 
#   when prompted "Enter Import Password:" hit return
#
theCertfile = 'apple_push_notification.pem'
# 
theHost = ('gateway.push.apple.com', 2195)

# 
data = json.dumps(thePayLoad)

# Clear out spaces in the device token and convert to hex
deviceToken = deviceToken.replace(' ','')
#byteToken = bytes.fromhex(deviceToken) # Python 3
byteToken = deviceToken.decode('hex') # Python 2

theFormat = '!BH32sH%ds' % len(data)
theNotification = struct.pack(theFormat, 0, 32, byteToken, len(data), data)

# Create our connection using the certfile saved locally
ssl_sock = ssl.wrap_socket(socket.socket(socket.AF_INET, socket.SOCK_STREAM), certfile = theCertfile)
ssl_sock.connect(theHost)

# Write out our data
ssl_sock.write(theNotification)

# Close the connection -- apple would prefer that we keep
# a connection open and push data as needed.
ssl_sock.close()

print "notification sent for " + deviceToken

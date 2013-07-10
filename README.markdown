Ococoa: The Official App of the Ottawa-Gatineau Cocoaheads
==========================================================

Summary
-------

Ococoa ("Ottawa Cocoa") is a simple app for the Ottawa-Gatineau Cocoaheads attendees.

All are welcome; our meetings are held on the second Thursday of every month.

It performs the following tasks:

* "Rings the doorbell" at our meeting place using Push Notifications

* Shows you the next meeting's agenda

* Easily propose new meeting topics


Passbook
--------

The Ococoa app now includes a pass, built using Apple's Passbook for iOS 6 and up.

Passbook makes it easy to send notifications to your users, even without an app installed.

This implementation has both a pass (client) and webservice endpoints (server) using Google App Engine.


How-to-use
----------

1.  Get the source and build it

    * This will create the missing files
    * The build will fail. This is normal.

2.  Delete the #error in OCPrivateInfo.m

    * The app will now build and run, but Push Notifications (Ring the Doorbell) won't work

3.  (Optional) Push Notifications

    * The application uses UrbanAirship for Push Notifications, so if you are building your own you will
      need the appropriate credentials from UrbanAirship. 
    * You can create a free UrbanAirship account, create a new app, and use those credentials
    * UrbanAirship provides 1M free push notifications a month, which is fine for a local user group
    * You will also need a web server to talk to UrbanAirship using their API
    * This source code contains such a web server, written in python for Google App Engine

Notes
-----

> You can download a free version on the App Store. This Open Source repository is to encourage
    participation and sharing. The link is https://itunes.apple.com/ca/app/ococoa/id510227146?mt=8
> You __must__ edit 'OCPrivateInfo.m' before the app will build. You will need some UrbanAirship credentials,
    and a server that can handle a GET request (basically, any web server).
> If you don't attend (or plan to attend) the monthly meetings, this app will be somewhat useless to you.
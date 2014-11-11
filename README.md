## Synopsis

An app that allows the user to manually set monitored geofencing regions, and test whether or not Core Location detects the user is inside or outside of a region.

## How To Use

Choose to update your location using either GPS or cellular data.

Tap "Update Location" to update your current location.*

Tap "Set Region" to create a monitored geofence region, with the center being your current location.

To create a monitored geofence region elsewhere, just tap and hold the map at a specific location for 2 seconds.

Set the radius of a geofence via the slider.

The slider will turn Blue when you are detected inside the most recently created geofence region.

The slider will turn Red when you are detected outside. And yellow when your state is unknown.

*Your location is only updated when you manually tap the "Update Location" button. Once this retreives your location, the locationManager will stop updating.

## Motivation

To learn more about Geofencing via Apple's 'Core Location framework. And specifically, its accuracy in detecting the state of a user's location relative to a monitored region.

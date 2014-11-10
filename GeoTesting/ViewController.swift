//
//  ViewController.swift
//  GeoTesting
//
//  Created by Vik Denic on 11/4/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var setRegionButton: UIBarButtonItem!

    var coordStringArray = [String]()
    let locationManager = CLLocationManager()

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var segmentedControl: UISegmentedControl!
    var currentLocation = CLLocation()
    var usingGPS = true

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = NSString(format: "%.0f", slider.value)
        setUpLongTouchGesture()
        locationManagerSetUp()
    }

    //MARK: UITapGesture
    func setUpLongTouchGesture()
    {
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        lpgr.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(lpgr)
    }

    func handleGesture (gestureRecognizer : UITapGestureRecognizer)
    {
        if gestureRecognizer.state != UIGestureRecognizerState.Ended
        {
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            resetMonitoredRegion(touchMapCoordinate)
        }
    }

    //MARK: CLLocationManager Helpers
    func resetMonitoredRegion(coordinate : CLLocationCoordinate2D)
    {
        if let previousOverlays = mapView.overlays
        {
            mapView.removeOverlay(previousOverlays[0] as MKOverlay)
            for monitoredRegion in locationManager.monitoredRegions
            {
                locationManager.stopMonitoringForRegion(monitoredRegion as CLRegion)
            }
            slider.tintColor = UIColor.darkGrayColor()
        }

        let newCoordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let regionSpan = Double(slider.value) as CLLocationDistance
        let overlay = MKCircle(centerCoordinate: newCoordinate, radius: regionSpan)
        mapView.addOverlay(overlay)

        let circularRegion = CLCircularRegion(center: newCoordinate, radius: regionSpan, identifier: NSDate().toStringOfMeridiemTime())
        locationManager.startMonitoringForRegion(circularRegion)

        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "requestState", userInfo: nil, repeats: false)
    }

    func locationManagerSetUp()
    {
        //Requires NSLocationAlwaysUsageDescription key and value in Info.plist
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }

    //MARK: MapView Helpers
    func centerTheMap(location : CLLocation)
    {
        let center = location.coordinate
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
    }

    //MARK: CLLocationManager
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!)
    {
        currentLocation = newLocation
        let newLat = NSString(format: "%.4f", newLocation.coordinate.latitude)
        let newLong = NSString(format: "%.4f", newLocation.coordinate.longitude)

        let newCoordString = "\(newLat), \(newLong)" as String
        println(newCoordString)
        coordStringArray.append(newCoordString)

        centerTheMap(newLocation)

        if usingGPS == true
        {
            locationManager.stopUpdatingLocation()
        }
        else
        {
            locationManager.stopMonitoringSignificantLocationChanges()

        }
        println("location updated")
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("did enter")
        slider.tintColor = UIColor.blueColor()
    }

    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("did exit")
        slider.tintColor = UIColor.redColor()
    }

    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if state == .Inside
        {
            slider.tintColor = UIColor.blueColor()
            println("did determine inside")

        }
        else if state == .Outside
        {
            slider.tintColor = UIColor.redColor()
            println("did determine outside")
        }
        else
        {
            slider.tintColor = UIColor.yellowColor()
            println("did determine unknown")
        }
    }

    //MARK: Actions
    @IBAction func onRegionButtonTapped(sender: UIBarButtonItem)
    {
        resetMonitoredRegion(currentLocation.coordinate)
    }

    func requestState()
    {
        locationManager.requestStateForRegion(locationManager.monitoredRegions.allObjects[0] as CLRegion)
    }

    @IBAction func onUpdateLocationTapped(sender: UIBarButtonItem)
    {
        if segmentedControl.selectedSegmentIndex == 0
        {
            locationManager.startUpdatingLocation()
            usingGPS = true
        }
        else
        {
            locationManager.startMonitoringSignificantLocationChanges()
            usingGPS = false
        }
    }

    @IBAction func onSliderMoved(sender: UISlider)
    {
        title = NSString(format: "%.0f", slider.value)
    }

    //MARK: MKMapView
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle
        {
            let renderer = MKCircleRenderer(circle: overlay as MKCircle)
            renderer.fillColor = UIColor.cyanColor().colorWithAlphaComponent(0.2)
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
            renderer.lineWidth = 3.0
            return renderer
        }
        else
        {
            return nil
        }
    }
}

//MARK: Extensions
extension NSDate
{
    func toStringOfMeridiemTime() -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm aa ss"
        var formattedString = dateFormatter.stringFromDate(self) as NSString
        let firstCharacter = formattedString.substringToIndex(1)
        if firstCharacter == "0"
        {
            formattedString = formattedString.substringFromIndex(1)
        }
        return formattedString + "s"
    }
}
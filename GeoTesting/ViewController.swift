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

    var coordStringArray = [String]()
    let locationManager = CLLocationManager()

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var segmentedControl: UISegmentedControl!
    var currentLocation = CLLocation()
    var circularRegion = CLCircularRegion()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        title = NSString(format: "%.0f", slider.value)
        locationManagerSetUp()
    }

    func locationManagerSetUp()
    {
        //Requires NSLocationAlwaysUsageDescription key and value in Info.plist
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self

        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }

    func centerTheMap(location : CLLocation)
    {
        let center = location.coordinate
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
    }

    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!)
    {
        currentLocation = newLocation
        let newLat = NSString(format: "%.4f", newLocation.coordinate.latitude)
        let newLong = NSString(format: "%.4f", newLocation.coordinate.longitude)

        let newCoordString = "\(newLat), \(newLong)" as String
        println(newCoordString)
        coordStringArray.append(newCoordString)

        centerTheMap(newLocation)

        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("entered")
    }

    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("exited")
    }

    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        if state == .Inside
        {
            slider.tintColor = UIColor.blueColor()
        }
        else if state == .Outside
        {
            slider.tintColor = UIColor.redColor()
        }
    }

    @IBAction func onRegionButtonTapped(sender: UIBarButtonItem)
    {
        let coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        let regionSpan = Double(slider.value) as CLLocationDistance
        let overlay = MKCircle(centerCoordinate: coordinate, radius: regionSpan)
        mapView.addOverlay(overlay)

        circularRegion = CLCircularRegion(center: currentLocation.coordinate, radius: regionSpan, identifier: NSDate().toStringOfMeridiemTime())
        locationManager.startMonitoringForRegion(circularRegion)
    }

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

    @IBAction func onUpdateLocationTapped(sender: UIBarButtonItem)
    {
        if segmentedControl.selectedSegmentIndex == 0
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    @IBAction func onSliderMoved(sender: UISlider)
    {
        title = NSString(format: "%.0f", slider.value)
    }
}

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


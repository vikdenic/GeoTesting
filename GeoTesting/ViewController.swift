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

class ViewController: UIViewController, CLLocationManagerDelegate {

    var coordStringArray = [String]()
    let locationManager = CLLocationManager()

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var segmentedControl: UISegmentedControl!

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
        let newLat = NSString(format: "%.4f", newLocation.coordinate.latitude)
        let newLong = NSString(format: "%.4f", newLocation.coordinate.longitude)

        let newCoordString = "\(newLat), \(newLong)" as String
        println(newCoordString)
        coordStringArray.append(newCoordString)

        centerTheMap(newLocation)

        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
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


//
//  MapViewController.swift
//  HooEats
//
//  Created by Connor on 6/21/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate
{
    @IBOutlet var map: MKMapView
    
    var locManager: CLLocationManager?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //Prompt for map permissions
        locManager = CLLocationManager()
        
        //Doesn't work
        //It looks like the MKMapView doesn't yet support the new (and more appropriate) authorization system. It took too long to figure this out
        //locManager!.requestWhenInUseAuthorization()

        //Do this instead
        locManager!.requestAlwaysAuthorization()
        locManager!.delegate = self
        
        //Center the map around UVa
        let (lat, long) = (38.034, -78.508)
        
        //Location
        let coord = CLLocationCoordinate2DMake(lat, long)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(coord, span)
        
        //Now show
        map.setRegion(region, animated: true)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //Don't allow swipe gestures to be used while this view is visible
        if self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer"))
        {
            self.navigationController.interactivePopGestureRecognizer.enabled = false
            
            //Set the delegate to this class, which won't respond
            self.navigationController.interactivePopGestureRecognizer.delegate = self
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        //Re-enable swipe gestures on exit
        if self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer"))
        {
            self.navigationController.interactivePopGestureRecognizer.enabled = true
            self.navigationController.interactivePopGestureRecognizer.delegate = nil
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        //If user enables location tracking, set the appropriate field on the map view
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.Authorized
        {
            self.map.showsUserLocation = true
        }
    }
}

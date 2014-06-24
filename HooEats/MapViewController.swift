//
//  MapViewController.swift
//  HooEats
//
//  Created by Connor on 6/21/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, DiningDataDelegate, MKMapViewDelegate
{
    @IBOutlet var map: MKMapView
    
    var locManager: CLLocationManager?
    weak var diningModel: DiningDataModel?
    
    var selectedLocation: DiningHallOverview?
    var selectedGroup: DiningHallOverview[]?
    
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
        
        //Set map delegate as well
        self.map.delegate = self
        
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
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        //Now refresh pins
        refreshDiningPins()
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
    
    func refreshDiningPins()
    {
        if let overviews = diningModel?.diningHallOverviews
        {
            //Sort by location so same values end up together
            overviews.sort { $0.location! < $1.location! }
            
            var groups: DiningHallOverview[][] = [[]]
            var index = 0
            
            //Group pins in same location
            for x in 0..overviews.count
            {
                if x != 0 && overviews[x - 1].location! != overviews[x].location!
                {
                    index++
                    groups.append([])
                }
                
                groups[index].append(overviews[x])
            }
            
            for diningGroup in groups
            {
                if diningGroup.count > 0
                {
                    var annotation = DiningAnnotation(diningGroup: diningGroup)
                    annotation.coordinate = CLLocationCoordinate2DMake(diningGroup[0].location!.latitude, diningGroup[0].location!.longitude)
                    self.map.addAnnotation(annotation)
                }
            }
        }
    }
    
    func onOverviewDataReady()
    {
        refreshDiningPins()
    }
    
    //Show custom pins
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
        //Necessary due to compiler bug. "is" returns an Int1 instead of a Bool, thus it cannot be negated
        //with ! and the following condition is impossible. Hooray for working with in-developement languages!
        //See stackoverflow for confirmation that I'm not crazy: http://stackoverflow.com/questions/24194571/swift-compare-anyobject-with-is-syntax
        //This is one of the better-acknowledged bugs I've come across
        var isDining = (annotation is DiningAnnotation ? true : false)
        
        if !(isDining)
        {
            return nil
        }
        
        let dinAn = annotation as DiningAnnotation
        let identifier = "DiningAnnotation"
        
        var annotationView = self.map.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
        
        if (annotationView)
        {
            annotationView!.annotation = dinAn
        }
        else
        {
            annotationView = MKPinAnnotationView(annotation: dinAn, reuseIdentifier: identifier)
        }
        
        //I'll be showing my own popover
        annotationView!.canShowCallout = false
        
        //Set appropriate pin color based on whether locations are open
        var allOpen = true
        var allClosed = true
        
        //Figure out if all halls are opened or closed
        for hall in dinAn.diningGroup
        {
            if hall.isOpen()
            {
                allClosed = false
            }
            else
            {
                allOpen = false
            }
        }
        
        //If both, there were no operation hours set. This would be indicated by a red pin as well
        if allClosed
        {
            annotationView!.pinColor = MKPinAnnotationColor.Red
        }
        else if allOpen
        {
            annotationView!.pinColor = MKPinAnnotationColor.Green
        }
        else    //Mixed. Indicated with purple
        {
            annotationView!.pinColor = MKPinAnnotationColor.Purple
        }
        
        return annotationView;
    }
    
    //On pin select
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!)
    {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if let dinAn = (view.annotation as? DiningAnnotation)
        {
            //Create a popover on the iPad
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
            {
                //Instantiate one of the table views from the storyboard
                var popoverLocList = self.storyboard.instantiateViewControllerWithIdentifier("mapHallListViewController") as HallListViewController

                //Set data given to location list
                popoverLocList.tableData = MenuTableDataModel(hallList: dinAn.diningGroup)
            
                //Now create a popover to hold it
                var popover = UIPopoverController(contentViewController: popoverLocList)
            
                popover.popoverContentSize = CGSizeMake(200, 200)
            
                //Set the "on selected" block to perform the appropriate segue
                popoverLocList.onRowSelected = {
                    popover.dismissPopoverAnimated(true)
                    self.selectedLocation = popoverLocList.getSelectedOverview()
                    self.performSegueWithIdentifier("mapToHallSegue", sender: self)
                }

                //And show the popover
                popover.presentPopoverFromRect(view.frame, inView: view.superview, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            }
            //Segue to the list view on the iPhone
            else
            {
                self.selectedGroup = dinAn.diningGroup
                self.performSegueWithIdentifier("mapToHallListSegue", sender: self)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
    {
        //If transitioning to a location overview controller
        if let dest = segue!.destinationViewController as? HallOverviewController
        {
            if let loc = self.selectedLocation
            {
                //Set the dining hall being shown by the destination
                dest.diningHallOverview = loc
            }
        }
        //If transitioning to a list
        else if let dest = segue!.destinationViewController as? HallListViewController
        {
            if let selGroup = self.selectedGroup
            {
                dest.tableData = MenuTableDataModel(hallList: selGroup)
                
                
                //Tell it to segue on selection
                dest.onRowSelected = {
                    dest.performSegueWithIdentifier("hallOverviewSegue", sender: dest)
                }
            }
        }
    }
}

//A custom annotation for my pins
class DiningAnnotation: MKPointAnnotation
{
    var diningGroup: DiningHallOverview[]
    
    init(diningGroup: DiningHallOverview[])
    {
        self.diningGroup = diningGroup
    }
}

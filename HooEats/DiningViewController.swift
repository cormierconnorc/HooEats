//
//  PrimaryViewController.swift
//  HooEats
//
//  Created by Connor on 6/21/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class DiningViewController: UIViewController
{
    @IBOutlet var menuListButton: UIButton
    @IBOutlet var mapViewButton: UIButton
    
    let diningModel = DiningDataModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Start the model updating
        diningModel.getAll()
        
        //Note: No need to make this class diningModel's delegate, as it doesn't need to refresh
        //any data upon dining model's task completion
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onMapButtonPress()
    {
        self.performSegueWithIdentifier("mapSegue", sender: self)
    }
    
    @IBAction func onMenuButtonPress()
    {
        self.performSegueWithIdentifier("menuSegue", sender: self)
    }
    
    //Segue preparations
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?)
    {
        if segue?.identifier == "mapSegue"
        {
            var destView = segue!.destinationViewController as MapViewController
            
            //Set the receiving view controller's dining data model
            destView.diningModel = diningModel
            
            //Set the model's delegate to the receiving view
            diningModel.delegate = destView
        }
        else if segue?.identifier == "menuSegue"
        {
            var destView = segue!.destinationViewController as MenuViewController
            destView.diningModel = diningModel
            diningModel.delegate = destView
        }
    }

}

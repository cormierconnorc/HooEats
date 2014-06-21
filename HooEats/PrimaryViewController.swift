//
//  PrimaryViewController.swift
//  HooEats
//
//  Created by Connor on 6/21/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class PrimaryViewController: UIViewController
{
    @IBOutlet var menuListButton: UIButton
    @IBOutlet var mapViewButton: UIButton
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
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

}

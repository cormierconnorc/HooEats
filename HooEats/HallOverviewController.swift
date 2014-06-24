//
//  LocationOverviewController.swift
//  HooEats
//
//  Created by Connor on 6/23/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class HallOverviewController: UIViewController
{
    @IBOutlet var tempLabel: UILabel
    
    //Expected to be set upon load and not changed afterwards
    var diningHallOverview: DiningHallOverview!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tempLabel.text = diningHallOverview.name
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

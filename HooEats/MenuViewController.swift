//
//  MenuViewController.swift
//  HooEats
//
//  Created by Connor on 6/23/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController, DiningDataDelegate
{
    weak var diningModel: DiningDataModel?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

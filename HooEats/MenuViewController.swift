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
    {
    //Set the dining hall list prior to setting this
    willSet
    {
        tableData = MenuTableDataModel(hallList: newValue?.diningHallOverviews)
    }
    }
    
    var tableData = MenuTableDataModel(hallList: nil)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /*
    Only used if this object's delegate has been set from outside
    */
    func onAllDataReady()
    {
        //Have the table view refresh
        self.tableData = MenuTableDataModel(hallList: diningModel?.diningHallOverviews)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        return tableData.numSections
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return tableData.rowsInSection[section]
    }
    
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String
    {
        return tableData.sectionHeadings[section]
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell
    {
        let cellIdentifier = "diningCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        
        //Set value of cell
        var overview = tableData.getHallAtIndexPath(indexPath)
        
        cell.text = overview.name
        
        return cell
    }
}

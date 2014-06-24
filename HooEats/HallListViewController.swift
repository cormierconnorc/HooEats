//
//  MenuViewController.swift
//  HooEats
//
//  Created by Connor on 6/23/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class HallListViewController: UITableViewController, DiningDataDelegate
{
    //Cell identifier (get from storyboard)
    let cellIdentifier = "diningCell"
    
    //Dining model: Used when data may update after object creation
    weak var diningModel: DiningDataModel? {
    //Set the dining hall list prior to setting this
    willSet {
        tableData = MenuTableDataModel(hallList: newValue?.diningHallOverviews)
    }
    }
    
    //Table data model
    var tableData: MenuTableDataModel = MenuTableDataModel(hallList: nil) {
    didSet {
        self.tableView.reloadData()
    }
    }
    
    //Block to invoke upon row selection
    var onRowSelected: (() -> Void)? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func getSelectedOverview() -> DiningHallOverview?
    {
        if let index = self.tableView.indexPathForSelectedRow()
        {
            //Set the dining hall being shown by the destination
            return tableData.getHallAtIndexPath(index)
        }
        
        return nil
    }
    
    /*
    Only used if this object's delegate has been set from outside
    */
    func onAllDataReady()
    {
        //Have the table view refresh
        self.tableData = MenuTableDataModel(hallList: diningModel?.diningHallOverviews)
    }
    
    /*
    Handle what to do upon row selection
    */
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        var myOverview = tableData.getHallAtIndexPath(indexPath)
        
        //Now give the overview to our callback block if it exists
        self.onRowSelected?()
    }
    
    /*
    Data source methods used to populate table view upon refresh
    Self-explanatory.
    */
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
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        
        //Set value of cell
        var overview = tableData.getHallAtIndexPath(indexPath)
        
        cell.text = overview.name
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
    {
        //If transitioning to a location overview controller
        if let dest = segue!.destinationViewController as? HallOverviewController
        {
            if let view = self.getSelectedOverview()
            {
                //Set the dining hall being shown by the destination
                dest.diningHallOverview = view
            }
        }
    }
}

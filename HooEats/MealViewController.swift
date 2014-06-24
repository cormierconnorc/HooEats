//
//  MealViewController.swift
//  HooEats
//
//  Created by Connor on 6/24/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class MealViewController: UITableViewController
{
    let cellIdentifier = "itemCell"
    
    //The meal used by this controller
    var meal: Meal? = nil {
    didSet {
        self.tableView.reloadData()
    }
    }
    var selectedItem: Item? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        //Hold onto meal selection data for segue
        self.selectedItem = self.meal!.stations[indexPath.section].items[indexPath.row]
        
        //Perform the segue
        self.performSegueWithIdentifier("itemSegue", sender: self)
    }
    
    /*
    Data source methods used to populate table view upon refresh
    Self-explanatory.
    */
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        //If the meal isn't set, this will prevent any of the forced unwrappings from ever occurring
        return (self.meal ? self.meal!.stations.count : 0)
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return self.meal!.stations[section].items.count
    }
    
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String
    {
        return self.meal!.stations[section].name!
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        
        //Set value of cell. No meal info if none, otherwise meal name
        cell.text = self.meal!.stations[indexPath.section].items[indexPath.row].name
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
    {
        if let dest = (segue.destinationViewController as? ItemViewController)
        {
            if let selected = self.selectedItem
            {
                dest.item = selected
            }
        }
    }
}

//
//  ItemViewController.swift
//  HooEats
//
//  Created by Connor on 6/24/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class ItemViewController: UITableViewController
{
    let cellIdentifier = "nutCell"
    
    //Item to display
    var item: Item? = nil {
    didSet {
        self.tableView.reloadData()
    }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Can't select nutrition
        self.tableView.allowsSelection = false
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    /*
    Data source methods used to populate table view upon refresh
    Self-explanatory.
    */
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return (self.item ? self.item!.nutrition.count : 0)
    }
    
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String
    {
        return "Nutritional Information:"
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        
        //Set value of cell. No meal info if none, otherwise meal name
        var nutString = self.item!.nutrition[indexPath.row]
        
        //Split the nutrition string before the value and trim both sides
        var parts = nutString.componentsSeparatedByString(":")
        var label = parts[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var value = parts[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //Set the cell text
        cell.text = label
        cell.detailTextLabel.text = value
        
        return cell
    }
}

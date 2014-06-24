//
//  LocationOverviewController.swift
//  HooEats
//
//  Created by Connor on 6/23/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class HallOverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var infoText: UITextView
    @IBOutlet var menuTable: UITableView
    
    let cellIdentifier = "mealCell"
    
    var diningHallOverview: DiningHallOverview! //Expected to be set upon load and not changed afterwards
    var hasMenuInfo = false
    var selectedMeal: Meal? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        hasMenuInfo = diningHallOverview?.menu?.meals.count > 0
        
        infoText.attributedText = diningHallOverview.getFormattedHallInfoText()
        menuTable.delegate = self
        menuTable.dataSource = self
        menuTable.allowsSelection = hasMenuInfo
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        //Hold onto meal selection data for segue
        self.selectedMeal = self.diningHallOverview?.menu?.meals[indexPath.row]
        
        //Perform the segue
        self.performSegueWithIdentifier("mealSegue", sender: self)
    }
    
    /*
    Data source methods used to populate table view upon refresh
    Self-explanatory.
    */
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return (hasMenuInfo ? diningHallOverview!.menu!.meals.count : 1)
    }
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String
    {
        return "Meals:"
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
        
        //Set value of cell. No meal info if none, otherwise meal name
        cell.text = (hasMenuInfo ? diningHallOverview!.menu!.meals[indexPath.row].name : "No menu available for this location.")
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
    {
        if let dest = (segue.destinationViewController as? MealViewController)
        {
            if let selected = self.selectedMeal
            {
                dest.meal = selected
            }
        }
    }

}

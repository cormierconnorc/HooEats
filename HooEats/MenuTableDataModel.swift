//
//  MenuTableDataModel.swift
//  HooEats
//
//  Created by Connor on 6/23/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import Foundation


class MenuTableDataModel
{
    //Stored properties
    var sectionHeadings: String[]
    var rowsInSection: Int[]
    var halls: DiningHallOverview[]
    
    //Computed properties
    var numSections: Int
    {
    get
    {
        return sectionHeadings.count
    }
    }
    
    init(hallList: DiningHallOverview[]?)
    {
        sectionHeadings = []
        rowsInSection = []
        
        if let halls = hallList
        {
            var openHalls = DiningHallOverview[]()
            var closedHalls = DiningHallOverview[]()
            
            for hall in halls
            {
                if hall.isOpen()
                {
                    openHalls.append(hall)
                }
                else
                {
                    closedHalls.append(hall)
                }
            }
            
            //Set fields in heading
            if openHalls.count > 0
            {
                sectionHeadings.append("Open:")
                rowsInSection.append(openHalls.count)
            }
            if closedHalls.count > 0
            {
                sectionHeadings.append("Closed:")
                rowsInSection.append(closedHalls.count)
            }
            
            
            //Now put relevant values in headings
            self.halls = (openHalls + closedHalls)
        }
        else
        {
            self.halls = []
        }
    }
    
    func getHallAtIndexPath(path: NSIndexPath) -> DiningHallOverview
    {
        var index = 0
        
        for x in 0..path.section
        {
            index += rowsInSection[x]
        }
        
        index += path.row
        
        return halls[index]
    }
}
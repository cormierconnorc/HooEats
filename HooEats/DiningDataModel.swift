//
//  DiningDataModel.swift
//  HooEats
//
//  Created by Connor on 6/22/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import Foundation

//Objc attribute necessary for optional methods
//Delegate allows view holding this model to refresh as necessary upon data update
@objc protocol DiningDataDelegate
{
    @optional func onOverviewDataReady()
    @optional func onMenuDataReady()
    @optional func onAllDataReady()
}

class DiningDataModel
{
    let serverUrl = "http://75.75.48.230:8000/"
    let overviewEndpoint = "?halls=overview"
    let menuEndpoint = "?halls=all"
    let comManager = CommunicationManagerModel()
    let lockQueue = dispatch_queue_create("com.uvaapps.LockQueue", nil)
    
    //Control
    var activeThreads = 0
    var delegate: DiningDataDelegate?
    
    //Data
    var diningHallOverviews: DiningHallOverview[]
    var diningHallMenus: DiningHallMenu[]
    
    init()
    {
        diningHallOverviews = []
        diningHallMenus = []
    }
    
    func getAll()
    {
        getOverview()
        getMenu()
    }
    
    func getOverview()
    {
        activeThreads++
        comManager.doGetJson(serverUrl + overviewEndpoint, callback: handleOverviewData)
    }
    
    func getMenu()
    {
        activeThreads++
        comManager.doGetJson(serverUrl + menuEndpoint, callback: handleMenuData)
    }
    
    func handleOverviewData(oData: NSObject?)
    {
        //Try to cast to our desired format
        //Compiler doesn't like as? chaining, so breaking it up is necessary
        let data: AnyObject[]? = oData as? NSArray
        let dictRay = data as? Dictionary<String, String>[]
        
        if !dictRay
        {
            println("Broken overview data format")
            return
        }
        
        //Data's fine, so let's force cast it
        let uData = dictRay!
        
        //Clear out our existing data, keeping capacity since number of dining overviews *probably* won't decrease over repeated calls
        self.diningHallOverviews.removeAll(keepCapacity: true)
        
        for dict in uData
        {
            var dView = DiningHallOverview(dict: dict)
            
            //Add to the class's list
            self.diningHallOverviews.append(dView)
        }
        
        self.delegate?.onOverviewDataReady?()
        
        //Must synchronize to prevent race conditions
        dispatch_sync(lockQueue, handleDataReady)
    }
    
    func handleMenuData(oData: NSObject?)
    {
        //Cast to proper format, similar to above
        let data: AnyObject[]? = oData as? NSArray
        let dictRay = data as? Dictionary<String, AnyObject>[]
        
        if !dictRay
        {
            println("Broken dining data format")
            return
        }
        
        //Data's fine, so let's force cast it
        let uData = dictRay!
        
        //Clear out existing
        self.diningHallMenus.removeAll(keepCapacity: true)
        
        //Perform operations on data
        for diningHall in uData
        {
            var hall = DiningHallMenu(dict: diningHall)
            
            self.diningHallMenus.append(hall)
        }
        
        self.delegate?.onMenuDataReady?()
        
        dispatch_sync(lockQueue, handleDataReady)
    }
    
    func handleDataReady()
    {
        activeThreads--
        
        if activeThreads == 0
        {
            //Associate menu data now that everything's here
            self.associateMenuData()
            
            self.delegate?.onAllDataReady?()
        }
    }
    
    func associateMenuData()
    {
        //Format string for coming comparison, only used here
        func prepare(str: String?) -> String?
        {
            //Make lower case
            var nStr = str?.lowercaseString
            
            //Get section before menu
            nStr = nStr?.componentsSeparatedByString("menu")[0]
            
            //Replace hall/cafe/dining
            nStr = nStr?.stringByReplacingOccurrencesOfString("hall", withString: "", options: nil, range: nil).stringByReplacingOccurrencesOfString("cafe", withString: "", options: nil, range: nil).stringByReplacingOccurrencesOfString("dining", withString: "", options: nil, range: nil)
            
            //Trim whitespace
            nStr = nStr?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            return nStr
        }
        
        var associated = 0
        
        for menu in diningHallMenus
        {
            let dinName = prepare(menu.name)
            //println(dinName)
            
            //Try to find the associated overview
            for overview in diningHallOverviews
            {
                //If overview name starts with the menu name, us it.
                if overview.name && dinName && prepare(overview.name)!.hasPrefix(dinName!)
                {
                    //println("Overview name was \(overview.name!) and dinName was \(dinName!)")
                    associated++
                    overview.menu = menu
                    
                    break
                }
            }
        }
        
        println("Of \(diningHallMenus.count) menus, \(associated) were associated!")
    }
}
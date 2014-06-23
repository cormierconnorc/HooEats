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

//Not sure if the convention for Swift is one class per file or more along the lines of the Python approach, so I'll lean towards what's convenient for me and put these here:
class DiningHallOverview
{
    var name: String?
    var description: String?
    var location: LatLng?
    var hours: OperationPeriod[]?
    var mealswipeMode: Int?
    var mealswipeHours: OperationPeriod[]?
    var menu: DiningHallMenu?
    
    init(dict: Dictionary<String, String>)
    {
        for (key, val) in dict
        {
            switch key
            {
            case "name":
                self.name = val
            case "description":
                self.description = val
            case "location":
                self.location = LatLng(strLoc: val)
            case "hours":
                self.hours = OperationPeriod.fromCsvList(val)
            case "accepts_mealswipes":
                self.mealswipeMode = val.toInt()!
            default: //"mealswipe_hours"
                self.mealswipeHours = OperationPeriod.fromCsvList(val)
            }
        }
    }
}

//Now the Dining Hall Menu Data classes, starting with the parent: DiningHallMenu
class DiningHallMenu
{
    var name: String?
    var meals: Meal[]
    
    init(dict: Dictionary<String, AnyObject>)
    {
        meals = []
        
        for (key, val: AnyObject) in dict
        {
            switch key
            {
            case "name":
                self.name = val as? String
            default: //meals
                let mealRay: AnyObject[] = val as NSArray
                let mealRayDict = mealRay as Dictionary<String, AnyObject>[]
                for meal in mealRayDict
                {
                    meals.append(Meal(dict: meal))
                }
            }
        }
    }
}

class Meal
{
    var name: String?
    var stations: Station[]
    
    init(dict: Dictionary<String, AnyObject>)
    {
        stations = []
        
        for (key, val: AnyObject) in dict
        {
            switch key
            {
            case "name":
                self.name = val as? String
            default: //stations
                let statRay: AnyObject[] = val as NSArray
                let statRayDict = statRay as Dictionary<String, AnyObject>[]
                for station in statRayDict
                {
                    stations.append(Station(dict: station))
                }
            }
        }
    }
}

class Station
{
    var name: String?
    var items: Item[]
    
    init(dict: Dictionary<String, AnyObject>)
    {
        items = []
        
        for (key, val: AnyObject) in dict
        {
            switch key
            {
            case "name":
                self.name = val as? String
            default: //items
                let itemRay: AnyObject[] = val as NSArray
                let itemRayDict = itemRay as Dictionary<String, AnyObject>[]
                for item in itemRayDict
                {
                    items.append(Item(dict: item))
                }
            }
        }
    }
}

class Item
{
    var name: String?
    var nutrition: String[]
    
    init(dict: Dictionary<String, AnyObject>)
    {
        nutrition = []
        
        for (key, val: AnyObject) in dict
        {
            switch key
            {
            case "name":
                self.name = val as? String
            default: //nutrition
                let nutRay: AnyObject[] = val as NSArray
                self.nutrition = nutRay as String[]
            }
        }
    }
}

//Supporting structures
struct LatLng
{
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double)
    {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(strLoc: String)
    {
        var parts = strLoc.componentsSeparatedByString(",")
        self.latitude = parts[0].bridgeToObjectiveC().doubleValue
        self.longitude = parts[1].bridgeToObjectiveC().doubleValue
    }
}

@infix func ==(left: LatLng, right: LatLng) -> Bool
{
    return left.latitude == right.latitude && left.longitude == right.longitude
}

@infix func !=(left: LatLng, right: LatLng) -> Bool
{
    return !(left == right)
}

@infix func <(left: LatLng, right: LatLng) -> Bool
{
    return (left.latitude != right.latitude ? left.latitude < right.latitude : left.longitude < right.longitude)
}

struct OperationPeriod
{
    var startDay: Int
    var startTime: Int
    var endDay: Int
    var endTime: Int
    
    init(startDay: Int, startTime: Int, endDay: Int, endTime: Int)
    {
        self.startDay = startDay
        self.startTime = startTime
        self.endDay = endDay
        self.endTime = endTime
    }
    
    init(strRange: String)
    {
        var parts = strRange.componentsSeparatedByString(":")
        var days = parts[0].componentsSeparatedByString("-")
        var times = parts[1].componentsSeparatedByString("-")
        
        if days.count >= 2
        {
            self.startDay = days[0].toInt()!
            self.endDay = days[1].toInt()!
        }
        else
        {
            self.startDay = days[0].toInt()!
            self.endDay = days[0].toInt()!
        }
        
        if times.count >= 2
        {
            self.startTime = times[0].toInt()!
            self.endTime = times[1].toInt()!
        }
        else
        {
            self.startTime = times[0].toInt()!
            self.endTime = times[0].toInt()!
        }
    }
    
    func isCurrent() -> Bool
    {
        //Get the current date
        var date = NSDate()
        var cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(abbreviation: "EST")
        var flags = NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
        var comps = cal.components(flags, fromDate: date)
        
        //Now check if that date is within the given range, first converting apple's day-of-week numbers to mine
        //Extra calculations (add and remod) are needed to ensure positive remainder since Apple doesn't obey the convention I prefer.
        let offset = 2
        comps.weekday = ((comps.weekday - offset % 7) + 7) % 7
        var inDayRange = false
        
        if (startDay <= endDay && comps.weekday <= endDay && comps.weekday >= startDay) || (startDay > endDay && (comps.weekday >= startDay || comps.weekday <= endDay))
        {
            inDayRange = true
        }
        
        var intTime = comps.hour * 100 + comps.minute
        
        return inDayRange && intTime <= endTime && intTime >= startTime
    }
    
    func getStringDay(day: Int) -> String
    {
        switch day
        {
        case 0:
            return "Monday"
        case 1:
            return "Tuesday"
        case 2:
            return "Wednesday"
        case 3:
            return "Thursday"
        case 4:
            return "Friday"
        case 5:
            return "Saturday"
        default:
            return "Sunday"
        }
    }
    
    func getStringTime(time: Int) -> String
    {
        var hour = time / 100
        var minute = time % 100
        var part = (hour >= 12 ? "PM" : "AM")
        
        hour %= 12
        
        if hour == 0
        {
            hour = 12
        }
        
        return "\(hour):\(minute) \(part)"
    }
    
    func getFormattedPeriod() -> String
    {
        return "\(getStringDay(startDay)) - \(getStringDay(endDay)): \(getStringTime(startTime)) - \(getStringTime(endTime))"
    }
    
    static func fromCsvList(list: String) -> OperationPeriod[]
    {
        var ray = OperationPeriod[]()
        
        for val in list.componentsSeparatedByString(",")
        {
            if !val.isEmpty && val.componentsSeparatedByString(":")[1] != "-1"
            {
                ray.append(OperationPeriod(strRange: val))
            }
        }
        
        return ray
    }
}
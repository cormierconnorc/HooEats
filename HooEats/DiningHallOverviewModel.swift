//
//  DiningHallOverviewModel.swift
//  HooEats
//
//  Created by Connor on 6/23/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import Foundation

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
    
    func isOpen() -> Bool
    {
        if let hours = self.hours
        {
            for period in hours
            {
                if period.isCurrent()
                {
                    return true
                }
            }
        }
        
        return false
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

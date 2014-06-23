//
//  DiningHallMenuModel.swift
//  HooEats
//
//  Created by Connor on 6/23/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import Foundation

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
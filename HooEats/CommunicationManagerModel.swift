//
//  CommunicationManagerModel.swift
//  DiningHallApp
//
//  Created by Connor on 6/20/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import Foundation

class CommunicationManagerModel
{
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    /*
    Carry out a post request and invoke a given callback method upon completion
    NOTE ON DESIGN: I've opted for callbacks/blocks here instead of delegates.
    This was done for a number of reasons, notably allowing a single communication manager
    instance to send results to different functions depending on the context.
    I read this article and took its points into consideration prior to making this decision: http://stablekernel.com/blog/blocks-or-delegation/
    */
    func doPost(url: String, dataString: String, callback: String? -> Void)
    {
        runRequestAsync(buildPostRequest(url, dataString: dataString), callback)
    }
    
    /*
    Carry out a post request and invoke a given callback method upon completion
    */
    func doGet(url: String, callback: String? -> Void)
    {
        runRequestAsync(buildGetRequest(url), callback)
    }
    
    /*
    *Carry out a post request synchronously, returning the result
    */
    func doPostSync(url: String, dataString: String) -> String?
    {
        return runRequestSync(buildPostRequest(url, dataString: dataString))
    }
    
    /*
    *Carry out a get request synchronously, returning the result
    */
    func doGetSync(url: String) -> String?
    {
        return runRequestSync(buildGetRequest(url))
    }
    
    func buildPostRequest(url: String, dataString: String) -> NSURLRequest
    {
        let destUrl = NSURL.URLWithString(url)
        
        var request = NSMutableURLRequest(URL: destUrl)
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //Convert String to data
        let data = dataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        request.HTTPBody = data
        
        return request
    }
    
    func buildGetRequest(url: String) -> NSURLRequest
    {
        return NSURLRequest(URL: NSURL.URLWithString(url))
    }
    
    //TODO: Check error conditions
    func runRequestAsync(request: NSURLRequest, callback: String? -> Void)
    {
        var dataTask = self.session.dataTaskWithRequest(request, completionHandler: {
            (retData, response, error) in
            let retString = NSString(data: retData, encoding: NSUTF8StringEncoding)
            callback(retString)
            })
        
        dataTask.resume()
    }
    
    func runRequestSync(request: NSURLRequest) -> String?
    {
        //Use a semaphore to syncrhonize the task (will be handled differently in app, of course)
        var semaphore = dispatch_semaphore_create(0)
        
        var opString: String? = nil
        
        //Closures are fun
        func doResponse(data: NSData!, response: NSURLResponse!, error: NSError!)
        {
            opString = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            dispatch_semaphore_signal(semaphore)
        }
        
        var dataTask = self.session.dataTaskWithRequest(request, completionHandler: doResponse)
        
        dataTask.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return opString
    }
}
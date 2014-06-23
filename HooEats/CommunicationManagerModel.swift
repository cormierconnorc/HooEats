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
    Carry out a get request and invoke a given callback method upon completion
    */
    func doGet(url: String, callback: String? -> Void)
    {
        runRequestAsync(buildGetRequest(url), callback)
    }
    
    /*
    Convenience wrapper. Do a get request and get the dictionary containing parsed JSON back
    */
    func doGetJson(url: String, callback: NSObject? -> Void)
    {
        func callWrapper(response: String?)
        {
            if let r = response
            {
                callback(parseJson(r))
            }
            else
            {
                callback(nil)
            }
        }
        
        runRequestAsync(buildGetRequest(url), callWrapper)
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
    
    func runRequestAsync(request: NSURLRequest, callback: String? -> Void)
    {
        var dataTask = self.session.dataTaskWithRequest(request, completionHandler: {
            (retData, response, error) in
            let retString = NSString(data: retData, encoding: NSUTF8StringEncoding)
            
            if let e = error
            {
                print(e.localizedDescription)
                callback(nil)
            }
            else
            {
                callback(retString)
            }
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
    
    /*
    Return an array representing the parsed JSON.
    This method does not generalize to all JSON, 
    only the specification used by our server. 
    Since the outer level is always an array,
    returning an Array suffices.
    */
    func parseJson(text: String) -> NSObject?
    {
        var posEr: NSError?
        
        //Should be an NSObject upon return
        var parsedObj = NSJSONSerialization.JSONObjectWithData(text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false), options: nil, error: &posEr) as? NSObject
        
        if let error = posEr
        {
            println(error.localizedDescription)
            return nil
        }
        
        return parsedObj
    }
}
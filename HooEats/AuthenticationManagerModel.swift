//
//  AuthenticationManagerModel.swift
//  DiningHallApp
//
//  Created by Connor on 6/20/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import Foundation

protocol AuthManagerDelegate
{
    func onAuthFail()
    func onAuthSuccess()
}

class AuthenticationManagerModel
{
    var delegate: AuthManagerDelegate?
    var user: String?
    var pass: String?
    let comManager = CommunicationManagerModel()
    let fileManager = FileManagerModel()
    let saveFileName = "credentials.txt"

    init()
    {
        //Nothing to do
        
        //Temporary, this allows us to test the authentication code each time the app runs
        //We can remove it whenever you guys want to
        //fileManager.deleteFile(saveFileName)
    }
    
    func hasCredentials() -> Bool
    {
        return fileManager.exists(saveFileName)
    }
    
    func setCredentials(user: String, pass: String)
    {
        //Write credentials to file using FileManager
        fileManager.writeFile(user + "|" + pass, fileName: saveFileName)
        
        //Update fields
        self.user = user
        self.pass = pass
    }
    
    func tryAuth()
    {
        //If necessary, read username and password from file
        if !(user && pass)
        {
            self.readFile()
        }
        
        //If still no values, fail.
        if !(user && pass)
        {
            delegate?.onAuthFail()
        }
        else
        {
            let authString = "user=\(user!)&pass=\(pass!)&reply=1login"
            
            comManager.doPost("https://netbadge.virginia.edu/index.cgi", dataString: authString, callback: analyzeResponse)
            
            println("Did post with data \(authString)")
        }
    }
    
    func analyzeResponse(html: String?)
    {
        var success = false
        
        if let html = html
        {
            //Login successful! (Checks for netbadge status page text)
            //Note the need to bridge to objective C NSString for contains operation in this Swift version
            if html.bridgeToObjectiveC().containsString("Your NetBadge is valid")
            {
                success = true
            }
        }
        
        //Only bother with this shit if we have a delegate
        if let del = delegate
        {
            //Get back on the main thread, which is necessary for these UI-touching operations
            //It would be a bad idea to do this if we were already on the main thread, but we can be sure that we're not (guaranteed by Com Manager)
            dispatch_sync(dispatch_get_main_queue(), {
                if success
                {
                    del.onAuthSuccess()
                }
                else
                {
                    del.onAuthFail()
                }
            })
        }
    }
    
    func readFile() -> Bool
    {
        var posConts = fileManager.readFile(saveFileName)
        
        if let contents = posConts
        {
            var splitParts = contents.componentsSeparatedByString("|")
            
            if splitParts.count >= 2
            {
                user = splitParts[0]
                pass = splitParts[1]
                
                return true
            }
        }
        
        return false
    }
    
    func deauthenticate()
    {
        self.user = nil
        self.pass = nil
        
        fileManager.deleteFile(saveFileName)
        
        //Remove auth cookie, as well
        var cookStore = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        //Delete each cookie.
        for cookie in (cookStore.cookies as NSHTTPCookie[])
        {
            cookStore.deleteCookie(cookie)
        }
    }
}
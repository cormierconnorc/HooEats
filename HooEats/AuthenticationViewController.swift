//
//  AuthenticationViewController.swift
//  DiningHallApp
//
//  Created by Connor on 6/20/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

protocol AuthViewDelegate
{
    func updateAuthInfo(user: String, pass: String)
}

class AuthenticationViewController: UIViewController, UIWebViewDelegate
{
    @IBOutlet var webView: UIWebView
    
    let authPath = "https://netbadge.virginia.edu/"
    let subPath = "https://netbadge.virginia.edu/index.cgi"
    
    var delegate: AuthViewDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Send the webview to the netbadge auth page
        webView.loadRequest(NSURLRequest(URL: NSURL.URLWithString(authPath)))
        
        //Set this object to be our webview's delegate
        webView.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //WebViewDelegate method determines whether web view should send request or not, used
    //to capture POST data.
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool
    {
        //Initial request, allow to continue
        if (request.URL.absoluteString == authPath)
        {
            return true
        }
        //The important part
        else if (request.URL.absoluteString == subPath && request.HTTPMethod == "POST")
        {
            var data = NSString(data: request.HTTPBody, encoding: NSUTF8StringEncoding)
            
            //If data is valid (contains user and pass), extract appropriate components and then dismiss this view
            if (isValidRequest(data))
            {
                var (user, pass) = extractData(data)
                
                //Don't allow empty data. This causes the request to fail before the
                //view controller can be dismissed, causing another view controller to
                //be displayed while this one still is. We'll have to fix this race
                //condition in a more permanent way later on
                if user == "" || pass == ""
                {
                    return false
                }
                
                //Dismiss this view
                self.dismissModalViewControllerAnimated(true)
                
                //Now send the data back to the delegate
                delegate?.updateAuthInfo(user, pass: pass)
            }
        }
        
        return false
    }
    
    //HTTP Body manipulation methods. Probably violate the MVC structure a bit, but it isn't worth the overhead of creating another file just to add these in
    func isValidRequest(req: String?) -> Bool
    {
        return req?.bridgeToObjectiveC().containsString("user=") && req?.bridgeToObjectiveC().containsString("pass=")
    }
    
    func extractData(data: String) -> (String, String)
    {
        //Break up string
        var components = data.componentsSeparatedByString("&")
        
        //Extract each value
        var user = components[0].componentsSeparatedByString("=")[1]
        var pass = components[1].componentsSeparatedByString("=")[1]
        
        return (user, pass)
    }
}

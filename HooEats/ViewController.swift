//
//  ViewController.swift
//  DiningHallApp
//
//  Created by Connor on 6/20/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AuthManagerDelegate, AuthViewDelegate
{
    @IBOutlet var resultLabel: UILabel
    
    let authManager = AuthenticationManagerModel()
    
    var hasAppeared = false
    var hasTriedAuth = false
    var authHolderVal = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //Set auth manager's delegate
        authManager.delegate = self
        
        //Now have it try to authenticate
        authManager.tryAuth()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //Handle early access
        hasAppeared = true
        
        if hasTriedAuth
        {
            if authHolderVal
            {
                self.onAuthSuccess()
            }
            else
            {
                self.onAuthFail()
            }
        }
        
        //Don't let that block execute more than once
        hasTriedAuth = false
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //AuthManagerDelegate method, invoked when authenticaiton is unsuccessful
    func onAuthFail()
    {
        //Control early access
        //Kind of a hack, but putting the authentication code in "didAppear" causes it to be invoked repeatedly while putting it in didLoad causes it to try to segue prior to creation of window hierarchy. This is the best solution I could come up with at the current time.
        if !self.hasAppeared
        {
            self.hasTriedAuth = true
            self.authHolderVal = false
            return
        }
        
        //Update label to show status (temporary, of course)
        resultLabel.text = "Failure! You suck!"
        
        //Trigger Segue to auth view
        self.performSegueWithIdentifier("authenticationSegue", sender: self)
    }
    
    func onAuthSuccess()
    {
        //Access controller
        if !self.hasAppeared
        {
            self.hasTriedAuth = true
            self.authHolderVal = true
            return
        }
        
        //Move on to next view controller, once implemented
        
        //Just update a label for now. Isn't it pretty?
        resultLabel.text = "Success! Good for you!"
    }
    
    //AuthViewDelegate method, called when AuthViewController is dismissed with result
    func updateAuthInfo(user: String, pass: String)
    {
        //Update credentials and retry authentication
        authManager.setCredentials(user, pass: pass)
        authManager.tryAuth()
    }
    
    //Segue preparations
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?)
    {
        if segue?.identifier == "authenticationSegue"
        {
            var destView = segue!.destinationViewController as AuthenticationViewController
            
            //Set delegate to this object
            destView.delegate = self
        }
    }

}


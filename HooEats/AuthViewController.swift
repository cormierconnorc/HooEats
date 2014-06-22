//
//  ViewController.swift
//  DiningHallApp
//
//  Created by Connor on 6/20/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, AuthManagerDelegate, NetbadgeViewDelegate
{
    @IBOutlet var resultLabel: UILabel
    @IBOutlet var logButton: UIButton
    @IBOutlet var continueButton: UIButton
    @IBOutlet var activityIndicator: UIActivityIndicatorView
    
    let authManager = AuthenticationManagerModel()
    
    var hasAppeared = false
    var hasTriedAuth = false
    var authHolderVal = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //Set auth manager's delegate
        authManager.delegate = self
        
        //Start the working spinner
        activityIndicator.startAnimating()
        
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
        
        //Stop the spinner
        activityIndicator.stopAnimating()
        
        //Update label to show status
        if authManager.hasCredentials()
        {
            resultLabel.text = "Failure. Please Enter Correct Login."
        }
        else
        {
            resultLabel.text = "No credentials found. Please Login."
        }
        
        //Disable the continue button
        self.continueButton.enabled = false
        
        //Set button text to say log in
        self.logButton.enabled = true
        self.logButton.setTitle("Log In", forState: UIControlState.Normal)
        
        
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
        
        //Stop the spinner
        activityIndicator.stopAnimating()
        
        //Status label update
        resultLabel.text = "Successfully Logged In."
        
        //Enable continue button
        self.continueButton.enabled = true
        
        //Set button text and make sure it's enabled
        self.logButton.enabled = true
        self.logButton.setTitle("Log Out", forState: UIControlState.Normal)
        
        //Move on to next view controller, once implemented
        self.performSegueWithIdentifier("accountSegue", sender: self)
    }
    
    //AuthViewDelegate method, called when AuthViewController is dismissed with result
    func updateAuthInfo(user: String, pass: String)
    {
        resultLabel.text = "Trying to log you in. Please stand by."
        
        //Disable log in/out button and continue button
        self.logButton.enabled = false
        self.continueButton.enabled = false
        
        //Start the spinner
        activityIndicator.startAnimating()
        
        //Update credentials and retry authentication
        authManager.setCredentials(user, pass: pass)
        authManager.tryAuth()
    }
    
    @IBAction func onLogButtonClick()
    {
        let butText = logButton.titleLabel.text
        
        if butText == "Log In"
        {
            //Perform authentication
            self.performSegueWithIdentifier("authenticationSegue", sender: self)
        }
        else
        {
            //Log the user out
            self.authManager.deauthenticate()
            
            //And set the button to show it
            self.logButton.setTitle("Log In", forState: UIControlState.Normal)
            
            //Also disable continue button
            self.continueButton.enabled = false
            
            //And change label
            self.resultLabel.text = "No credentials found. Please Login."
        }
    }
    
    @IBAction func onContinueButtonClick()
    {
        //Perform segue to primary view
        self.performSegueWithIdentifier("accountSegue", sender: self)
    }
    
    //Segue preparations
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?)
    {
        if segue?.identifier == "authenticationSegue"
        {
            var destView = segue!.destinationViewController as NetbadgeViewController
            
            //Set delegate to this object
            destView.delegate = self
        }
    }

}


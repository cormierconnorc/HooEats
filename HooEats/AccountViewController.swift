//
//  AccountViewController.swift
//  HooEats
//
//  Created by Connor on 6/22/14.
//  Copyright (c) 2014 Connor. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController
{
    @IBOutlet var webView: UIWebView?
    
    let page = "https://csg-web1.eservices.virginia.edu/login/sso.php"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Load the account info page
        webView?.loadRequest(NSURLRequest(URL: NSURL.URLWithString(page)))
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}

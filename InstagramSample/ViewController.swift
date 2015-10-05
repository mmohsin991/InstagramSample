//
//  ViewController.swift
//  InstagramSample
//
//  Created by Mohsin on 05/10/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MyInstagramApiDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        MyInstagramApi.delegate = self

        
//        MyInstagramApi.getUserData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    
    
    func didSuccessfulLogin(data : [String : AnyObject]){
        println("login successfull")
        println(data)

    }
    func didUnSuccessfulLogin(){
        println("login failed")
    }
    
    
    
    @IBAction func login(sender: UIButton) {
        
        MyInstagramApi.login()
        
    }
    
    
    
    
    
}


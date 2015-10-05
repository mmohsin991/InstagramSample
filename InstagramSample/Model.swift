//
//  Model.swift
//  InstagramSample
//
//  Created by Mohsin on 05/10/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import Foundation



protocol MyInstagramApiDelegate{
    func didSuccessfulLogin(data : [String : AnyObject])
    func didUnSuccessfulLogin()

}


class MyInstagramApi{
    static let sharedManager = AFHTTPRequestOperationManager()
    private static let clientID = "9d3292986f364e25836c819aef15b922"
    private static let clientSecret = "ff4e85d36aa4477aa1b33e5432f234d5"
    private static let redirectURI = "is9d3292986f364e25836c819aef15b922://"
    
    
    static var delegate : MyInstagramApiDelegate?
    
    
    
    class func getUserData(code : String, complete : (errorDesc : String?, data : [String : String]?) -> Void){
        let loginUrl = "https://api.instagram.com/oauth/access_token"
        let params = [
            "client_id" : clientID,
            "client_secret" : clientSecret,
            "grant_type" : "authorization_code",
            "redirect_uri" : redirectURI,
            "code" : code]
        

        
        MyInstagramApi.sharedManager.POST(loginUrl, parameters: params, constructingBodyWithBlock: { (data) -> Void in
            println("data: \(data)")
            
            },
            success: { (operation, anyObj) -> Void in
                
                let jsonData = JSON(anyObj)
                var tempDic = [String : String]()
                
                if let dic = jsonData.dictionary{
                    println(dic)
                    
                    //If jsonData is .Dictionary
                    for (key,subJson):(String, JSON) in dic {
                        //If subJson is .Dictionary
                        if let dic2 = subJson.dictionary{

                            //If json is .Dictionary
                            for (key1,subJson1):(String, JSON) in dic2 {
                                
                                if let valueString = subJson1.string{
                                    tempDic[key1] = valueString
                                }
                                else if let valueInt = subJson1.number{
                                    tempDic[key1] = valueInt.description
                                }
                            }
                        }
                        else{
                            if let valueString = subJson.string{
                                tempDic[key] = valueString
                            }
                        }
                    }
                
                }
                if tempDic["id"] == nil {
                    complete(errorDesc: "some error please try again", data: nil)
                }
                else{
                    complete(errorDesc: nil, data: tempDic)
                    
                }
                
            })
            { (operation, error) -> Void in
                println("error: \(error.localizedDescription)")
                complete(errorDesc: error.localizedDescription, data: nil)
        }
    }
    
    
    
    
    
    class func getUserDataFromNSURLSession(code : String, complete : (errorDesc : String?, data : [String : String]?) -> Void){
        
        
        let loginUrl = "https://api.instagram.com/oauth/access_token"
        let params = [
            "client_id" : clientID,
            "client_secret" : clientSecret,
            "grant_type" : "authorization_code",
            "redirect_uri" : redirectURI,
            "code" : code] as Dictionary
        
        var request = NSMutableURLRequest(URL: NSURL(string: loginUrl)!)
        var session = NSURLSession.sharedSession()
        var err: NSError?
        
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            println("Response: \(response)")
            
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            println("Body: \(strData)\n\n")
            
            if data != nil {
                
                let jsonData = JSON(data: data)
                var tempDic = [String : String]()
                
                if let dic = jsonData.dictionary{
                    println(dic)
                    
                    //If jsonData is .Dictionary
                    for (key,subJson):(String, JSON) in dic {
                        //If subJson is .Dictionary
                        if let dic2 = subJson.dictionary{
                            
                            //If json is .Dictionary
                            for (key1,subJson1):(String, JSON) in dic2 {
                                
                                if let valueString = subJson1.string{
                                    tempDic[key1] = valueString
                                }
                                else if let valueInt = subJson1.number{
                                    tempDic[key1] = valueInt.description
                                }
                            }
                        }
                        else{
                            if let valueString = subJson.string{
                                tempDic[key] = valueString
                            }
                        }
                    }
                    
                }
                if tempDic["id"] == nil {
                    complete(errorDesc: "some error please try again", data: nil)
                }
                else{
                    complete(errorDesc: nil, data: tempDic)

                }
            }
            else if error != nil{
                println("error: \(error.localizedDescription)")
                complete(errorDesc: error.localizedDescription, data: nil)
            }
        })
        
        task.resume()
    
    }
    
    
    class func login(){
        let openUrl = NSURL(string: "https://api.instagram.com/oauth/authorize/?client_id=\(clientID)&redirect_uri=\(redirectURI)&response_type=code")
        
        let openPage = UIApplication.sharedApplication().openURL(openUrl!)
    }
    
    
    
    
    class func openURL(openURL: NSURL) -> Bool{
        
        println(openURL.description)
        
        if openURL.description.hasPrefix("is\(clientID)"){
            // code comes form server
            if openURL.description.hasPrefix("is\(clientID):?code=") {
                
                let code = openURL.description.stringByReplacingOccurrencesOfString("is\(clientID):?code=", withString: "")
                
                getUserDataFromNSURLSession(code, complete: { (errorDesc, data) -> Void in
                    
                    if errorDesc != nil {
                        self.delegate?.didUnSuccessfulLogin()
                    }
                    else{
                        self.delegate?.didSuccessfulLogin(data!)
                    }
                })
            }
                // error
            else{
                self.delegate?.didUnSuccessfulLogin()
            }
        }
    
        return true
    }
    
    

}
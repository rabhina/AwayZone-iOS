
//  WebserviceClass.swift
//  Challenge
//
//  Created by Ajay Kumar on 12/1/16.
//  Copyright © 2016 CQLsys. All rights reserved.
//


import UIKit

typealias JSONDictionary = [String:Any]
typealias JSONArray = [JSONDictionary]
typealias APIServiceSuccessCallback = ((Any?) -> ())
typealias JSONArrayResponseCallback = ((JSONArray?) -> ())
typealias JSONDictionaryResponseCallback = ((JSONDictionary?) -> ())
typealias CompletionHandler = ((NSDictionary, Bool) -> ())
typealias postCompletionHandler = ((NSDictionary) -> ())


class WebserviceClass {

    class var sharedInstance :WebserviceClass {
        struct SingletonClass {
            static let instance = WebserviceClass()
        }
        
        return SingletonClass.instance
    }

    //MARK:
    
    
    func apiCallWithParametersUsingGET(methodName: NSString, paramDictionary: NSDictionary?, onCompletion: (@escaping CompletionHandler)) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlStr      =  BASE_API_URL + methodName.trimmingCharacters(in: .whitespaces)
        
        var paramStr = ""
        
        if paramDictionary != nil {
            paramStr    =  self.stringFromHttpParameters(paramDictionary: paramDictionary!) as String
        }
        
        let url = "\(urlStr)?\(paramStr)" as String
        
        let session = URLSession.shared
        let urlPath = NSURL(string: url)
        let request = NSMutableURLRequest(url: urlPath! as URL)
        
        request.timeoutInterval = 60
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) ->  Void in
            
            if((error) != nil) {
                print(error!.localizedDescription)
            }
            else {
                _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                let _: NSError?
                if(data != nil && error == nil){
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false

                    do {
                        let jsonResult: AnyObject = try JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let dict = jsonResult as! NSDictionary
                        onCompletion(dict, true)
                        
                    }catch  {
                        
                        onCompletion([:], false)
                    }
                    
                }
                else {
                    NSLog("Error URL **** %@ *****", url);
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        })
        dataTask.resume()
        
    }
    
    func apiCallWithParametersUsingPOST (methodName: String, paramDictionary: NSDictionary?, onCompletion: (@escaping CompletionHandler))  {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlStr      =  BASE_API_URL + methodName.trimmingCharacters(in: .whitespaces)
        
        var paramStr = ""
        
        if paramDictionary != nil {
            paramStr    =  self.stringFromHttpParameters(paramDictionary: paramDictionary!) as String
        }
        
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "POST"
        
        let postString = paramStr
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request , completionHandler: { (data, response, error) ->  Void in
            
            if((error) != nil) {
                print(error!.localizedDescription)
            }
            else {
                _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                let _: NSError?
                if(data != nil && error == nil){
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    do {
                        let jsonResult: AnyObject = try JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let dict = jsonResult as! NSDictionary
                        onCompletion(dict, true)
                        
                    }catch  {
                        
                        onCompletion([:], false)
                    }
                }
                else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        })
        task.resume()
    }
    
    func stringFromHttpParameters(paramDictionary : NSDictionary) -> NSString {
        
        if paramDictionary == nil {
            return ""
        }
        else {
            var parametersString = ""
            for (key, value) in paramDictionary {
                if let key = key as? String,
                    let value = value as? String {
                    parametersString = parametersString + key + "=" + value + "&"
                }
            }
            parametersString = parametersString.substring(to: parametersString.index(before: parametersString.endIndex))
            return parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
        }
    }
    
    
    //MARK :
    
    func UploadRequest(methodName: String, paramDictionary: NSDictionary?, image_data: NSData, imageParameter : String, onCompletion: (@escaping CompletionHandler))
    {
        
        let urlStr      =  BASE_API_URL + methodName.trimmingCharacters(in: .whitespaces)
        var request = URLRequest(url: URL(string: urlStr)!)
        
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        
        //define the data post parameter
        
        if paramDictionary != nil {
            for (key, value) in paramDictionary! {
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
       
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(imageParameter)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data as Data)


        body.append("\r\n".data(using: String.Encoding.utf8)!)

        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            if((error) != nil) {
                print(error!.localizedDescription)
            }
            else {
                _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                let _: NSError?
                if(data != nil && error == nil){
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    do {
                        let jsonResult: AnyObject = try JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let dict = jsonResult as! NSDictionary
                        onCompletion(dict, true)
                        
                    }catch  {
                        
                        onCompletion([:], false)
                    }
                }
                else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
        }
        
        task.resume()
        
        
    }
    
    func UploadRequestForVideo(methodName: String, paramDictionary: NSDictionary?, image_data: NSData, imageParameter : String, onCompletion: (@escaping CompletionHandler))
    {
        
        let urlStr      =  BASE_API_URL + methodName.trimmingCharacters(in: .whitespaces)
        var request = URLRequest(url: URL(string: urlStr)!)
        
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        
        let fname = "video.mp4"
        let mimetype = "video/mp4"
        
        //define the data post parameter
        
        if paramDictionary != nil {
            for (key, value) in paramDictionary! {
                
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(imageParameter)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data as Data)
        
        
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            if((error) != nil) {
                print(error!.localizedDescription)
            }
            else {
                _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
                let _: NSError?
                if(data != nil && error == nil){
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    do {
                        let jsonResult: AnyObject = try JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        let dict = jsonResult as! NSDictionary
                        onCompletion(dict, true)
                        
                    }catch  {
                        
                        onCompletion([:], false)
                    }
                }
                else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
        }
        
        task.resume()
        
        
    }
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
//    // MARK: - GET Webservice
//    
//    func apiCall (methodName: String, paramDictionary: NSDictionary?, profilePicData: NSData?, coverPicData: NSData?, stringName: String?, onCompletion: (@escaping CompletionHandler)){
//        
//        
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//     
//        let session = URLSession.shared
//        let url =  BASE_API_URL + methodName.trimmingCharacters(in: .whitespaces)
//        let urlPath = NSURL(string: url)
//        let request = NSMutableURLRequest(url: urlPath! as URL)
//        request.timeoutInterval = 60
//        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
//        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "GET"
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) ->  Void in
//            
//            
//            if((error) != nil) {
//                print(error!.localizedDescription)
//            }else {
//                _ = NSString(data: data!, encoding:String.Encoding.utf8.rawValue)
//                let _: NSError?
//                if(data != nil && error == nil){
//                let jsonResult: AnyObject = try! JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//                print(jsonResult)
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                    let dict = jsonResult as! NSDictionary
//                    onCompletion(dict)
//                }
//                else {
//                    NSLog("Error URL **** %@ *****", url);
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                }
//            }
//        })
//        dataTask.resume()
//    }
//    
//// MARK: -  POST webservice with Image
// 
//    func apiCallWithImage(methodName: String, paramDictionary: NSDictionary?, imageData: NSData?,onCompletion: (@escaping postCompletionHandler)){
//     
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        let urlStr      =  BASE_API_URL + methodName.trimmingCharacters(in: .whitespaces)
//        
//        var paramStr = ""
//        
//        if paramDictionary != nil {
//            paramStr    =  self.stringFromHttpParameters(paramDictionary: paramDictionary!) as String
//        }
//        
//        var request = URLRequest(url: URL(string: urlStr)!)
//        
//        //
//        
//        //  let urlPath = NSURL(string: parms)
//        // let request = NSMutableURLRequest(url: urlPath! as URL)
//        request.httpMethod = "POST"
//        
//        let boundary = "Boundary-\(NSUUID().uuidString)"
//        
//        //define the multipart request type
//        
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let body = NSMutableData()
//        let fname = "test.png"
//        let mimetype = "image/png"
//        
//        //define the data post parameter
//        let postString = paramStr
//        
//        body.append(postString.data(using: .utf8)!)
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append(imageData! as Data)
//        body.append("\r\n".data(using: String.Encoding.utf8)!)
//        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
//        request.httpBody = body as Data
//        let session = URLSession.shared
//        
//            let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) ->  Void in
//            
//            if error != nil{
//                    print("error=\(error)")
//                    return
//                }
//            else{
//                    //Let's convert response sent from a server side script to a NSDictionary object:
//                    let jsonResult: AnyObject = try! JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//                    print("result: \(jsonResult)")
//                 let dict = jsonResult as! NSDictionary
//                  onCompletion(dict)
//
//                }
//        })
//        
//        task.resume()
//      }
//
//    func apiCallPOSTRequestUSingData (methodName: String, paramDictionary: NSDictionary?, onCompletion: (@escaping CompletionHandler))  {
//        
//        var jsonData = Data()
//        
//        do {
//            jsonData = try JSONSerialization.data(withJSONObject:paramDictionary! , options: .prettyPrinted)
//        }
//        catch {
//            print(error)
//        }
//        
//        // create post request
//        let url = NSURL(string: methodName)!
//        let request = NSMutableURLRequest(url: url as URL)
//        request.httpMethod = "POST"
//        
//        // insert json data to the request
//        request.httpBody = jsonData
//        
//        
//        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
//            if error != nil{
//                return
//            }
//            
//            let jsonResult: AnyObject = try! JSONSerialization.jsonObject(with: data!, options:    JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
//            
//            let dict = jsonResult as! NSDictionary
//            print(dict)
//        }
//        
//        task.resume()
//    }
}


/*
 Alamofire.request("https://www.loyalstarglobal.com/admin/customer/rewardch1.php", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).response { (responseData) in
 
 let utf8Text = String(data: responseData.data!, encoding: .utf8)
 
 print("Data: \(utf8Text)")
 
 }
 
 //        Alamofire.request("https://www.loyalstarglobal.com/admin/customer/rewardch1.php").response { responseData in
 //
 //            print("Data: \(responseData.response)")
 //        }
 */


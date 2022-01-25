//
//  HttpServices.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

public enum HttpRequestType : String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

public enum HttpRequestContentType : String {
    case ApplicationJson = "application/json"
    case UrlEncoded = "application/x-www-form-urlencoded"
}

public enum Constants : String {
    case fcmURL = "https://fcm.googleapis.com/fcm/send"
    case server_key = "key=AAAA3JY25tI:APA91bFk5a_uqNNYpl5-ZvC3AkhJbR9QW7TSG1z8yE2Iqn-WuHQUbmlHyhW_a4_5IJ08QXEeoxxM8BqtyZbn76ZWeziPjdiU93kvw0mOiID4wa-B_NLgIgO_U1tHB34CCB_II16-TTbf"
}

class HttpServices: NSObject {
    
    func sendHttpRequestForPushNotification(url: Constants = .fcmURL, param: [String : Any], type: HttpRequestType = .POST, _ contentType: HttpRequestContentType = .ApplicationJson, handleComplete: @escaping ( _ isSuccess: Bool, _ error: String, _ code: Int, _ data: Data?) -> ()) {
        
        let url = URL(string: url.rawValue)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = type.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.setValue(Constants.server_key.rawValue, forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: [.prettyPrinted])
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            DispatchQueue.main.async {
                var code = 200
                //check status code
                if let httpResponse = response as? HTTPURLResponse {
                    code = httpResponse.statusCode
                }
                if  error != nil {
                    print(error!.localizedDescription)
                    handleComplete(false, error!.localizedDescription, code , nil)
                } else {
                    if data != nil && data!.count > 0 {
                        let responseString = String(data: data!, encoding: .utf8)
                        handleComplete(true, responseString!, code, nil)
                    } else {
                        handleComplete(false, "Unknow Error", code, nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    public func sendHttpRequestForGetData(_ url:String, param:String? = nil, header: NSDictionary? = nil, type: HttpRequestType = .GET, _ contentType: HttpRequestContentType = .ApplicationJson, handleComplete: @escaping ( _ isSuccess: Bool, _ error: String, _ code: Int, _ data: Data?) -> ()) {
        if let urlRequest = URL(string: url) {
            var request = URLRequest(url: urlRequest)
            request.httpShouldHandleCookies = false
            request.addValue("dCuW7UQMbdvpcBDfzolAOSGFIcAec11a", forHTTPHeaderField: "app_token")
            
            if type != .GET {
                request.httpMethod = type.rawValue
                request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
                
                // add param
                request.httpBody = param!.data(using: String.Encoding.utf8)
            }
            
            //add header
            if header != nil {
                for keyObject in header!.allKeys {
                    let key = keyObject as! String
                    if !key.isEmpty {
                        if let value = header![key] as? String {
                            request.addValue(value, forHTTPHeaderField: key)
                        }
                    }
                }
            }
            
            let httpConfig = URLSessionConfiguration.default
            httpConfig.timeoutIntervalForRequest = 60
            httpConfig.timeoutIntervalForResource = 60
            
            let session = URLSession(configuration: httpConfig)
            let task = session.dataTask(with: request, completionHandler: { (data, res, error) in
                DispatchQueue.main.async {
                    var code = 200
                    //check status code
                    if let httpResponse = res as? HTTPURLResponse {
                        code = httpResponse.statusCode
                    }
                    if  error != nil {
                        print(error!.localizedDescription)
                        handleComplete(false, error!.localizedDescription, code , nil)
                    } else {
                        if data != nil && data!.count > 0 {
                            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                            let isError = jsonObj??.value(forKey: "error") as! Bool
                            let message = jsonObj??.value(forKey: "message") as! String
                            
                            if (isError) {
                                handleComplete(isError, message, code, data!)
                            } else {
                                handleComplete(isError, message, code, data!)
                            }
                        } else {
                            handleComplete(false, "Unknow Error", code, nil)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    public func sendHttpRequestForUploadData(_ url:String, param:NSDictionary? = nil, header: NSDictionary? = nil, type: HttpRequestType = .GET, _ contentType: HttpRequestContentType = .ApplicationJson, handleComplete: @escaping ( _ isSuccess: Bool, _ error: String, _ code: Int, _ data: Data?) -> ()) {
        if let urlRequest = URL(string: url) {
            var request = URLRequest(url: urlRequest)
            request.httpShouldHandleCookies = false

            if type != .GET {
                request.httpMethod = type.rawValue
                request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
                
//                add param
                var postString: String = ""
//                request.httpBody = try? JSONSerialization.data(withJSONObject: param, options: [.prettyPrinted])
                for data in (param?.keyEnumerator().allObjects)! {
                    postString += "\(data)=\(param!.value(forKey: data as! String) ?? "")"
                    request.httpBody = postString.data(using: String.Encoding.utf8)
                    print(postString)
                }
            }
            
            //add header
            if header != nil {
                for keyObject in header!.allKeys {
                    let key = keyObject as! String
                    if !key.isEmpty {
                        if let value = header![key] as? String {
                            request.addValue(value, forHTTPHeaderField: key)
                        }
                    }
                }
            }
            
            let httpConfig = URLSessionConfiguration.default
            httpConfig.timeoutIntervalForRequest = 60
            httpConfig.timeoutIntervalForResource = 60
            
            let session = URLSession(configuration: httpConfig)
            let task = session.uploadTask(with: request, from: request.httpBody, completionHandler: { (data, res, error) in
                DispatchQueue.main.async {
                    var code = 200
                    //check status code
                    if let httpResponse = res as? HTTPURLResponse {
                        code = httpResponse.statusCode
                    }
                    if  error != nil {
                        print(error!.localizedDescription)
                        handleComplete(false, error!.localizedDescription, code , nil)
                    } else {
                        if data != nil && data!.count > 0 {
                            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                            let isError = jsonObj??.value(forKey: "error") as! Bool
                            let message = jsonObj??.value(forKey: "message") as! String
                    
                            if (isError) {
                                handleComplete(isError, message, code, data!)
                            } else {
                                handleComplete(isError, message, code, data!)
                            }
                        } else {
                            handleComplete(false, "Unknow Error", code, nil)
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    public func sendHttpRequestForUploadingData(_ url:String, param:String? = nil, header: NSDictionary? = nil, type: HttpRequestType = .GET, _ contentType: HttpRequestContentType = .ApplicationJson, handleComplete: @escaping ( _ isSuccess: Bool, _ error: String, _ code: Int, _ data: Data?) -> ()) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        
        //add header
        if header != nil {
            for keyObject in header!.allKeys {
                let key = keyObject as! String
                if !key.isEmpty {
                    if let value = header![key] as? String {
                        request.addValue(value, forHTTPHeaderField: key)
                    }
                }
            }
        }
        
        if type != .GET {
            request.httpMethod = type.rawValue
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
            
            // add param
            if param != nil {
                request.httpBody = param!.data(using: String.Encoding.utf8)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            URLSession.shared.uploadTask(with: request, from: request.httpBody, completionHandler: {(data, response, error) -> Void in
                DispatchQueue.main.async {
                    if error != nil {
                        let httpStatus = response as? HTTPURLResponse
                        if httpStatus == nil || httpStatus?.statusCode != 200 {
                            // check for http errors
                            return handleComplete(false, error!.localizedDescription, httpStatus!.statusCode , nil)
                        }
                    } else {
                        let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                        let isError = jsonObj??.value(forKey: "error") as! Bool
                        let message = jsonObj??.value(forKey: "message") as! String
                        let httpStatus = response as? HTTPURLResponse
                        if isError == false {
                            
                                    handleComplete(isError, message, httpStatus!.statusCode, data!)
                            
                        } else {
                            handleComplete(isError, message, httpStatus!.statusCode, data!)
                        }
                    }
                }
            }).resume()
        }
    }
}

extension Data {
    func toNSDictionary() -> NSDictionary? {
        var jsonObj : Any?
        do {
            jsonObj = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return jsonObj as? NSDictionary
        } catch {
            return nil
        }
    }
    
    func toArray() -> NSArray? {
        var jsonObj : Any?
        do {
            jsonObj = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return jsonObj as? NSArray
        } catch {
            return nil
        }
    }
}

extension NSDictionary {
    func JsonStringWithPrettyPrint() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
        } catch {
            return nil
        }
    }
}

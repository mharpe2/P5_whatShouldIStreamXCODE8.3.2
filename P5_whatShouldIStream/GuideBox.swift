//
//  GuideBox.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/20/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation


class GuideBox: NSObject {
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    var session: URLSession
    
    //var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    
    // MARK: - All purpose task method for data
    
    func taskForResource(_ resource: String, parameters: [String : AnyObject], completionHandler: @escaping CompletionHander) -> URLSessionDataTask {
        
        var mutableParameters = parameters
        var mutableResource = resource
        
                
        // Substitute the id parameter into the resource
        if resource.range(of: ":id") != nil {
            //assert(parameters[Keys.ID] != nil)
            
            mutableResource = mutableResource.replacingOccurrences(of: ":id", with: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValue(forKey: Keys.ID)
        }
        
        
        // Substitute the id parameter into the resource
        if resource.range(of: ":showname") != nil {
            //assert(parameters[":showname"] != nil)
            
            mutableResource = mutableResource.replacingOccurrences(of: ":showname", with: "\(parameters["showname"]!)")
            mutableParameters.removeValue(forKey: ":showname")
        }

        
        let urlString = Constants.BaseUrlSSL + mutableResource + CoreNetwork.escapedParameters(mutableParameters)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        print(url)
        
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if let error = downloadError {
                let newError = GuideBox.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                
                CoreNetwork.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }) 
        
        task.resume()
        
        return task
    }
    
//    // MARK: - All purpose task method for images
//    
//    func taskForImageWithSize(size: String, filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
//        
//        let baseURL = NSURL(string: config.secureBaseImageURLString)!
//        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
//        
//        print(url)
//        
//        let request = URLRequest(URL: url)
//        
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            
//            if let error = downloadError {
//                let newError = GuideBox.errorForData(data, response: response, error: error)
//                completionHandler(imageData: nil, error: newError)
//            } else {
//                completionHandler(imageData: data, error: nil)
//            }
//        }
//        
//        task.resume()
//        
//        return task
//    }
    
    
    // MARK: - Helpers
    
    
    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error
    
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], let errorMessage = parsedResult[GuideBox.Keys.ErrorStatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "GuideBox Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }
    
       // MARK: - Shared Instance
    
    class func sharedInstance() -> GuideBox {
        
        struct Singleton {
            static var sharedInstance = GuideBox()
        }
        
        return Singleton.sharedInstance
    }
    
}

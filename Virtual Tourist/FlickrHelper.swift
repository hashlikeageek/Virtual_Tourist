//
//  FlickrHelper.swift
//  Virtual Tourist
//
//  Created by Ashutosh Kumar Sai on 08/01/17.
//  Copyright © 2017 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation

class FlickrHelper
{
    func getDT (urlString: String , completionHandler: @escaping (_ result: AnyObject? , _ error: NSError?) -> Void)
    {
        let address = URL(string: urlString)!
        let req = URLRequest(url: address)
        let session = URLSession.shared
        let task = session.dataTask(with: req) { (data, response, error) in
            guard (error == nil) else {
                completionHandler(nil, error! as NSError)
                return
            }
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(nil, NSError(domain: "Error 8", code: 0, userInfo: nil))
                return
            }
            completionHandler(parsedResult as AnyObject?, nil)
        }
        task.resume()
    }
    
    
    func escape(parameters: [String: Any]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var kVPair = [String]()
            
            for (key, value) in parameters {
                let string = "\(value)"
                let value = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                kVPair.append(key + "=" + "\(value!)")
            }
            return "?\(kVPair.joined(separator: "&"))"
        }
    }
    
    func randomPageGenerator() -> String {
        let randomPage = arc4random_uniform(UInt32(FlickrConstants.FlickrParameterValues.Pages))
        return String(randomPage)
    }
    
    func BBox(lat latitude: Double,  long longitude: Double) -> String {
        
        let minLon = max(longitude - FlickrConstants.BBox.Width, FlickrConstants.BBox.LonRange.0)
        let maxLon = min(longitude + FlickrConstants.BBox.Width, FlickrConstants.BBox.LonRange.1)
        
        let minLat = max(latitude - FlickrConstants.BBox.Height, FlickrConstants.BBox.LatRange.0)
        let maxiLat = min(latitude + FlickrConstants.BBox.Height, FlickrConstants.BBox.LatRange.1)
        
        return "\(minLon),\(minLat),\(maxLon),\(maxiLat)"
    }
    
    class func sharedInstance() -> FlickrHelper {
        struct Singleton {
            static var sharedInstance = FlickrHelper()
        }
        return Singleton.sharedInstance
    }

    
}


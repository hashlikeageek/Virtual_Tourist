//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Ashutosh Kumar Sai on 31/12/16.
//  Copyright © 2016 Ashish Rajendra Kumar Sai. All rights reserved.
//

import Foundation


class FlickrClient {
    
    
    func locationID(lat: Double, lon: Double, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.LatLonMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.Latitude: String(lat),
            FlickrConstants.FlickrParameterKeys.Longitude: String(lon),
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let url = FlickrConstants.Flickr.APIBaseUrl + FlickrHelper.sharedInstance().escape(parameters: parameters)
        
        FlickrHelper.sharedInstance().getDT(urlString: url) { (data, error) in
            
            guard (error == nil) else {
                completionHandler(nil, NSError(domain: "Error 1", code: 100, userInfo: nil))
                return
            }
            
            guard let status = data?[FlickrConstants.FlickrResponseKeys.Status] as? String, status == FlickrConstants.FlickrResponseValues.StatusOK else {
                completionHandler(nil, NSError(domain: "Error 2", code: 200, userInfo: nil))
                return
            }
           
            
            guard let places = data?[FlickrConstants.FlickrResponseKeys.PlacesResponse] as? [String:AnyObject],
                let place = places[FlickrConstants.FlickrResponseKeys.Place] as? [[String:AnyObject]] else {
                    completionHandler(nil, NSError(domain: "Error 3", code: 300, userInfo: nil))
                    return
            }
            
            guard let placeId = place[0][FlickrConstants.FlickrResponseKeys.PlaceId] as? String else {
                completionHandler(nil, NSError(domain: "Error 4", code: 400, userInfo: nil))
                return
            }
            completionHandler(placeId as AnyObject, nil)
        }
    }
    
    func urlForLoc(locationId: String, completionHandler: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.photoSearchMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.PlaceId: locationId,
            FlickrConstants.FlickrParameterKeys.PerPage: FlickrConstants.FlickrParameterValues.PerPage,
            FlickrConstants.FlickrParameterKeys.Pages:  FlickrHelper.sharedInstance().randomPageGenerator(),
            FlickrConstants.FlickrParameterKeys.Extras: FlickrConstants.FlickrParameterValues.ExtraMediumUrl,
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback,
            FlickrConstants.FlickrParameterKeys.Radius: FlickrConstants.FlickrParameterValues.RadiusKm
        ]
        
        let urlString = FlickrConstants.Flickr.APIBaseUrl +  FlickrHelper.sharedInstance().escape(parameters: parameters)
        
        FlickrHelper.sharedInstance().getDT(urlString: urlString) { (data, error) in
            
            guard (error == nil) else {
                completionHandler(nil, NSError(domain: "Error 5", code: 100, userInfo: nil))
                return
            }
            
            guard let status = data?[FlickrConstants.FlickrResponseKeys.Status] as? String, status == FlickrConstants.FlickrResponseValues.StatusOK else {
                completionHandler(nil, NSError(domain: "Error 6", code: 200, userInfo: nil))
                return
            }

           
            guard let photosDict = data?[FlickrConstants.FlickrResponseKeys.Photos] as? [String: AnyObject], let photosArray = photosDict[FlickrConstants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                completionHandler(nil, NSError(domain: "Error 7", code: 300, userInfo: nil))
                    return
            }
            
            var photoUrls = [String]()
            for eachPhoto in photosArray {
                photoUrls.append((eachPhoto[FlickrConstants.FlickrParameterValues.ExtraMediumUrl] as? String)!)
            }
            completionHandler(photoUrls as AnyObject, nil)
        }
    }
    
    func getP(urlString: String, completionHandler: @escaping(_ result: Data?, _ error: NSError?) -> Void) {
        let address = URL(string: urlString)!
        let req = URLRequest(url: address)
        let session = URLSession.shared
        let task = session.dataTask(with: req) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandler(nil, error! as NSError)
                return
            }
            completionHandler(data, nil)
        }
        task.resume()

    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
}

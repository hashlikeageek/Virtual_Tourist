//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Ashutosh Kumar Sai on 31/12/16.
//  Copyright © 2016 Ashish Rajendra Kumar Sai. All rights reserved.
//

struct FlickrConstants {
    
    struct Flickr {
        static let APIBaseUrl = "https://api.flickr.com/services/rest/"
    }
    
    struct BBox
    {
        static let Width = 1.0
        static let Height = 1.0
        static let LatRange = (-90.0, 90.0)
        static let LonRange = (-180.0, 180.0)
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let PlaceId = "place_id"
        static let Pages = "page"
        static let PerPage = "per_page"
        static let Extras = "extras"
        static let Radius = "radius"
    }
    
    struct FlickrParameterValues {
        static let LatLonMethod = "flickr.places.findByLatLon"
        static let photoSearchMethod = "flickr.photos.search"
        static let APIKey = "91241217ac800f61e5ed9888ba46e2ee"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
    
        static let PerPage = "21"
        static let Pages = 20
        static let ExtraMediumUrl = "url_m"
        static let RadiusKm = "50"
    }
    
    struct FlickrResponseKeys {
        static let PlacesResponse = "places"
        static let Place = "place"
        static let PlaceId = "place_id"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Status = "stat"
    }
    
    struct FlickrResponseValues {
        static let StatusOK = "ok"
    }
    
    
    
}


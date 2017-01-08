//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Ashutosh Kumar Sai on 31/12/16.
//  Copyright © 2016 Ashish Rajendra Kumar Sai. All rights reserved.
//

import UIKit
import MapKit
import CoreData

final class MapViewController: UIViewController, MKMapViewDelegate {



    @IBOutlet weak var mapView: MKMapView!

    let client = FlickrClient()
    
    var context: NSManagedObjectContext!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        lastregion()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.removeAnnotations(mapView.annotations)
        let pinreq = NSFetchRequest<Pin>(entityName: "Pin")
        do {
            let res = try context.fetch(pinreq)
            loadpins(pins: res)
        } catch let errors as NSError{
            print("Error 1 in MapView Controller \(errors)")
        }
    }
    

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        let reuseId = "pin"
        var pinV: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            pinV = dequeuedView
        } else {
            pinV = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinV.animatesDrop = true
            pinV.pinTintColor = UIColor.red
            pinV.canShowCallout = false
        }
        return pinV
    }
    
      
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
            guard let photoViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "PhotoCollectionViewController") as? PhotoCollectionViewController else {
                print("Error 2 in MVC")
                return
            }
            photoViewController.pinV = view
            
            guard let latitude = view.annotation?.coordinate.latitude, let longitude = view.annotation?.coordinate.longitude else {
                print("Error 3 in MVC")
                return
            }
            let prec = 0.000001
            let pinreq = NSFetchRequest<Pin>(entityName: "Pin")
            pinreq.predicate = NSPredicate(format: "(%K BETWEEN {\(latitude - prec), \(latitude + prec) }) AND (%K BETWEEN {\(longitude - prec), \(longitude + prec) })", #keyPath(Pin.latitude), #keyPath(Pin.longitude))
            
            do {
                let res = try context.fetch(pinreq)
                photoViewController.pins = res.first
            } catch let error as NSError{
                    print("Error 4 in MVC \(error)")
                    return
            }
            photoViewController.context = context
            self.navigationController?.pushViewController(photoViewController, animated:true)
        

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let region = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]

        UserDefaults.standard.set(region, forKey: "savedMapRegion")
        UserDefaults.standard.synchronize()
    }
    
    
    
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
    
        if sender.state == .began {
            let tLocation = sender.location(in: mapView)
            let cordinates = mapView.convert(tLocation, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = cordinates
            mapView.addAnnotation(annotation)
            
    
            client.locationID(lat: annotation.coordinate.latitude, lon: annotation.coordinate.longitude, completionHandler: {(data, error) in
                
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                self.savePin(coords: cordinates, locationId: data as! String)
            })
        }
    }
    
    
    
    func loadpins(pins: [Pin]) {

        for pin in pins {
            let annotations = MKPointAnnotation()
            annotations.coordinate.latitude = pin.latitude
            annotations.coordinate.longitude = pin.longitude
            mapView.addAnnotation(annotations)
        }
    }
    
   
   
    func savePin(coords: CLLocationCoordinate2D, locationId: String) {
        
        let pinE = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        let pin = Pin(entity: pinE, insertInto: context)
        pin.latitude = coords.latitude
        pin.longitude = coords.longitude
        pin.locationId = locationId

        do {
            try context.save()
        } catch let error as NSError {
            print("Error 5 in MVC \(error)")
        }
    }

    

    
    func lastregion() {
        if let region = UserDefaults.standard.dictionary(forKey: "savedMapRegion") {
            
            let longitude = region["longitude"] as! CLLocationDegrees
            let latitude = region["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = region["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = region["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            self.mapView.setRegion(savedRegion, animated: true)
        }
    }
    
    class func sharedInstance() -> MapViewController {
        struct Singleton {
            static var sharedInstance = MapViewController()
        }
        return Singleton.sharedInstance
    }

}

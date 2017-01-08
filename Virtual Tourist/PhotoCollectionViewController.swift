//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Ashutosh Kumar Sai on 31/12/16.
//  Copyright © 2016 Ashish Rajendra Kumar Sai. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    
    let client = FlickrClient()
    var context: NSManagedObjectContext!
    var pinV = MKAnnotationView()
    var pins: Pin!
    var parray = [Photo!]()
    var resultscontroller: NSFetchedResultsController<NSFetchRequestResult>!
    
    var sCellInd = [IndexPath]()
    
    var inInd: [IndexPath]!
    var dInd: [IndexPath]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView(view: pinV)
        collectionView.delegate = self
        collectionView.dataSource = self
        toolBarButton.title = "New Collection"
        if loadPhotos().isEmpty {
            urlForLoc(locationId: pins.locationId!)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pin: MKPinAnnotationView
        pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.animatesDrop = true
        pin.pinTintColor = UIColor.black
        pin.canShowCallout = false
        
        return pin
    }
    
    func setupMapView(view: MKAnnotationView) {
        mapView.isScrollEnabled = false
        mapView.addAnnotation(view.annotation!)
        let span = MKCoordinateSpan(latitudeDelta: 0.04225, longitudeDelta: 0.04225)
        let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func urlForLoc(locationId: String) {
        
        client.urlForLoc(locationId: pins.locationId!) { (data, error) in
            guard (error == nil) else {
                
                print("Error: \(error!.localizedDescription)")
                return
            }
            guard let photoUrls = data! as? NSArray else {
                return
            }
            
            if photoUrls.count == 0 {
                self.alertNoImages()
            }
            
            DispatchQueue.main.async {
                
                do {
                    for eachUrl in photoUrls {
                        let photo = Photo(context: self.context)
                        photo.pin = self.pins
                        photo.url = eachUrl as? String
                    }
                    try self.context.save()
                }catch let error as NSError {
                    print("Error 3 PCVC \(error)")
                }
            }
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteSelectedCells(_ sender: Any) {
        
        
        if !sCellInd.isEmpty {
            var photosToDelete = [Photo]()
            
            
            for eachCellSelected in sCellInd {
                photosToDelete.append(resultscontroller.object(at: eachCellSelected) as! Photo)
            }
            
            DispatchQueue.main.async {
                do {
                    for photo in photosToDelete {
                        self.context.delete(photo)
                    }
                    try self.context.save()
                }catch let error as NSError {
                    print("Error 4 PCVC \(error)")
                }
            }
        } else {
            
            DispatchQueue.main.async {
                do {
                    let all =  self.resultscontroller.fetchedObjects as! [Photo]
                    for each in all {
                        self.context.delete(each)
                    }
                    try self.context.save()
                } catch let error as NSError {
                    print("Error 5 PCVC \(error)")
                }
                self.urlForLoc(locationId: self.pins.locationId!)
            }
        }
        toolBarButton.title = "New Collection"
        sCellInd = [IndexPath]()
    }

    
    func configureCell(_ cell: PhotoCollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        if let _ = sCellInd.index(of: indexPath) {
            cell.alpha = 1.0
        } else {
            cell.alpha = 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return resultscontroller.sections![section].numberOfObjects
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        DispatchQueue.main.async {
            cell.activityIndicator.startAnimating()
            cell.photo.image = nil
        }
        let photo = resultscontroller.object(at: indexPath) as! Photo
        
        
        if let photo = photo.data {
            let image = UIImage(data: photo as Data)
            DispatchQueue.main.async {
                cell.photo.image = image
                cell.activityIndicator.stopAnimating()
            }
        } else {
            client.getP(urlString: photo.url!) { (imageData, error) in
                guard (error == nil) else {
                    print("Error 1 PCVC")
                    return
                }
                guard let image = UIImage(data: imageData!) else {
                    return
                }
            
                DispatchQueue.main.async {
                    photo.data = imageData as NSData?
                    do {
                        try self.context.save()
                    } catch let error as NSError {
                        print("Error 2 PCVC \(error)")
                    }
                    cell.photo.image = image
                    cell.activityIndicator.stopAnimating()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        if let cellIndex = sCellInd.index(of: indexPath) {
            sCellInd.remove(at: cellIndex)
        } else {
            sCellInd.append(indexPath)
        }
        
        if sCellInd.isEmpty {
            toolBarButton.title = "New Collection"
        } else {
            toolBarButton.title = "Delete Items"
        }
    }
    
    
    
    
}

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        inInd = [IndexPath]()
        dInd = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            inInd.append(newIndexPath!)
            break
        case .delete:
            dInd.append(indexPath!)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({
            
            for indexPath in self.inInd {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.dInd {
                self.collectionView.deleteItems(at: [indexPath])
            }

        }, completion: nil)
    }
    
    
    func loadPhotos() -> [Photo] {
        
        var photos = [Photo]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pins)
        fetchRequest.sortDescriptors = []
        resultscontroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        resultscontroller.delegate = self
        
        do {
            try resultscontroller.performFetch()
            if let results = resultscontroller.fetchedObjects as? [Photo] {
                photos = results
            }
        } catch {
            print("Error")
        }
        return photos
    }
    
    func alertNoImages(){
        let alert = UIAlertController(title: "Error", message: "No images found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

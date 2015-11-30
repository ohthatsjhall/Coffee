//
//  ViewController.swift
//  Coffee
//
//  Created by Justin Hall on 11/26/15.
//  Copyright © 2015 Justin Hall. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  
  @IBOutlet weak var mapView: MKMapView?
  
  var venues: Results<Venue>?
  
  var lastLocation: CLLocation?
  var locationManager: CLLocationManager?
  let distanceSpan: Double = 500
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if let mapView = self.mapView {
      mapView.delegate = self
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    if locationManager == nil {
      locationManager = CLLocationManager()
      
      locationManager!.delegate = self
      locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
      locationManager!.requestAlwaysAuthorization()
      locationManager!.distanceFilter = 50
      locationManager!.startUpdatingLocation()
    }
    
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    if let mapView = self.mapView {
      let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
      mapView.setRegion(region, animated: true)
    }
  }
  
  func refreshVenues(location: CLLocation?, getDataFromFoursquare: Bool = false) {
    if location != nil {
      lastLocation = location
    }
    
    if let location = lastLocation {
      
      if getDataFromFoursquare == true {
        
        CoffeeAPI.sharedInstance.getCoffeeShopsWithLocation(location)
        
      }
      
      let realm = try! Realm()
      
      venues = realm.objects(Venue)
      
      for venue in venues! {
        
        let annotation = CoffeeAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
        
        mapView?.addAnnotation(annotation)
      }
      
    }
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
    if annotation.isKindOfClass(MKUserLocation) {
      return nil
    }
    
    var view = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationIdentifier")
    
    if view == nil {
      view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
    }
    
    view?.canShowCallout = true
    
    return view
  }
  


}


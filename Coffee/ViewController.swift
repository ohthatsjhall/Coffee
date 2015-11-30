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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var tableView: UITableView!
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
    if let tableView = self.tableView {
      tableView.delegate = self
      tableView.dataSource = self
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
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onVenuesUpdated:", name: API.notifications.venuesUpdated, object: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return venues?.count ?? 0
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  // MARK: - UITableViewDataSource
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier")
    
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cellIdentifier")
    }
    
    if let venue = venues?[indexPath.row] {
      cell!.textLabel?.text = venue.name
      cell!.detailTextLabel?.text = venue.address
    }
    
    return cell!
  }
  
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    if let mapView = self.mapView {
      let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
      mapView.setRegion(region, animated: true)
      
      refreshVenues(newLocation, getDataFromFoursquare: true)
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
  
  func onVenuesUpdated(notification: NSNotification) {
    refreshVenues(nil)
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


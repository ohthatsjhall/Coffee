//
//  ViewController.swift
//  Coffee
//
//  Created by Justin Hall on 11/26/15.
//  Copyright © 2015 Justin Hall. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
  
  @IBOutlet weak var mapView: MKMapView?
  
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
  


}


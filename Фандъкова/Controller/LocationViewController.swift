//
//  ViewController.swift
//  userLocation
//
//  Created by Sebastian Hette on 19.09.2016.
//  Copyright © 2016 MAGNUMIUM. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol LocationDelegate {
    func setLocation(location: CLLocation, address: String)
    func locationChanged()
}

class LocationViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{
    
    @IBOutlet weak var addressField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Futura", size: 20)!]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: Map
    @IBOutlet weak var mapView: MKMapView!
    let manager = CLLocationManager()
    var userLocation = CLLocation()
    var anotationSet = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        mapView.mapType = MKMapType.standard
        if !anotationSet{
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: locValue, span: span)
            mapView.setRegion(region, animated: true)
            anotationSet = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.isDraggable = true
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool = true) {
        // Remove all annotations
        self.mapView.removeAnnotations(mapView.annotations)
        
        // Add new annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapView.centerCoordinate
        annotation.title = "Rico"
        annotation.subtitle = "illegal"
        self.mapView.addAnnotation(annotation)
        //SETTING THE USER LOCATION EVERY TIME THE REGION UPDATES
        userLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        //asynchroniously getting the
        CLGeocoder().reverseGeocodeLocation(userLocation) { (placemark, error) in
            if error != nil
            {
                print ("THERE WAS AN ERROR")
            }
            else
            {
                if let place = placemark?[0]
                {
                    if place.subThoroughfare != nil
                    {
                        //should I dispatch to main?
                        self.addressField.text = "\(place.subThoroughfare!) \n \(place.thoroughfare!) \n \(place.country!)"
                    }
                }
            }
        }
    }
    
    //MARK: Location Protocol
    var delegate: LocationDelegate?
    
    @IBAction func sendLocation(_ sender: UIBarButtonItem) {
        delegate?.setLocation(location: userLocation, address: addressField.text!)
        delegate?.locationChanged()
        _ = navigationController?.popViewController(animated: true) as? FormTableController
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}


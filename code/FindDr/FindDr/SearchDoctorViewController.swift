//
//  SearchDoctorViewController.swift
//  FindDr
//
//  Created by eduardo milpas diaz on 11/13/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

import UIKit

class SearchDoctorViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, MKMapViewDelegate, CLLocationManagerDelegate  {

    //MARK: - overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //starting variables
        locationManager = CLLocationManager()
        //spinner to indicate waiting
        self.indicator?.startAnimating()
        self.indicator?.hidden = true
        //starting view
        searchMapView.hidden = false
        searchTable.hidden   = true
        searchBar.delegate = self
        locationManager?.delegate = self
        //locate user's position
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //TODO: - revisar que enviaremos para hacer el detalle
    }

    //MARK: - class properties
    var doctors : Array<Doctor>?
    var dummyDocDB : Array<Doctor>?
    var clinics : Array<Clinic>?
    var locationManager : CLLocationManager?
    //MARK: - view properties
    @IBOutlet var searchMapView: MKMapView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchTable: UITableView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    //MARK: - view actions
    @IBAction func changeView(sender: UISegmentedControl) {
        let MAP  = 0
        let LIST = 1

        if sender.selectedSegmentIndex == MAP {
            searchMapView.hidden = false
            searchTable.hidden   = true
        }
        else {
            searchMapView.hidden = true
            searchTable.hidden   = false
        }
    }

    //MARK: - class methods

    func centerMapOnMyPosition(latitude : CDouble, longitude : CDouble) {
        //center pin
        let SPAN = 0.1
        let span = MKCoordinateSpan(latitudeDelta: SPAN, longitudeDelta: SPAN)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)

        searchMapView.setRegion(region, animated: true)
        //adding pin on my position
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()

        annotation.coordinate = location;
        annotation.title = "Me"
        annotation.subtitle = "This is where I am located"

        searchMapView.addAnnotation(annotation)
    }

    func markMap() {
        for clinic in clinics! {
            let latitude = (clinic.latitude as NSString).doubleValue
            let longitude = (clinic.longitude as NSString).doubleValue

            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()

            annotation.coordinate = location;
            annotation.title = clinic.name
            searchMapView.addAnnotation(annotation)
        }
    }

    //MARK: - MAP delegated methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MyPin")
        //adding properties
        pin.canShowCallout = true
        pin.highlighted = true
        pin.pinColor = MKPinAnnotationColor.Red

        if annotation.title == "Me" {
            pin.pinColor = MKPinAnnotationColor.Purple
        }
        else {
            pin.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIView
        }
        return pin
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        //TODO: - go to detail
    }

    //MARK: - Location delegated methods
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location: " + error.localizedDescription)
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            if error != nil {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.locationManager?.stopUpdatingLocation()
                self.centerMapOnMyPosition(pm.location.coordinate.latitude, longitude: pm.location.coordinate.longitude)
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }

    //MARK: - search Bar delegated methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) { // called when keyboard search button pressed
        let search = Search()
        //cleaning map and table
        clinics?.removeAll(keepCapacity: false)
        searchMapView.removeAnnotations(searchMapView.annotations)
        locationManager?.startUpdatingLocation()
        //showing wait image
        self.indicator?.hidden = false
        //searching by doctor name
        search.getDoctorsByName(searchBar.text, apps: { (doctors : [AnyObject]!) -> Void in
            for doc in doctors {
                search.loadClinics(doc as Doctor, results: { (clinicas : [AnyObject]!) -> Void in
                    self.clinics = Array<Clinic>()
                    for clinic in clinicas {
                        self.clinics?.append(clinic as Clinic)
                    }
                    //TODO: - add searching by clinic and specialty
                    //hidding wait image
                    self.indicator?.hidden = true
                    self.searchTable.reloadData()//printing results in table view
                    self.markMap()
                })
            }
            if doctors == nil || doctors.count <= 0 {
                //hidding wait image and cleaning table results
                self.indicator?.hidden = true
                self.searchTable.reloadData()//printing results in table view
                self.markMap()
            }
        })
    }

    //MARK: - table delegated methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clinics != nil ? clinics!.count : 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath) as UITableViewCell
        let clinic = clinics?[indexPath.row]

        cell.textLabel.textColor = UIColor.whiteColor()
        cell.textLabel.text = clinic?.name
        //cell.detailTextLabel?.text = specialtiesCad
        return cell
    }
}